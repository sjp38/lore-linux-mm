Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3875D6B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 18:58:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z1so12995881pfl.9
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 15:58:30 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id s7si8965918pgr.336.2017.12.10.15.58.25
        for <linux-mm@kvack.org>;
        Sun, 10 Dec 2017 15:58:26 -0800 (PST)
Date: Mon, 11 Dec 2017 10:57:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171210235745.GR5858@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207003843.GG4094@dastard>
 <20171208230131.GC32293@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208230131.GC32293@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 08, 2017 at 03:01:31PM -0800, Matthew Wilcox wrote:
> On Thu, Dec 07, 2017 at 11:38:43AM +1100, Dave Chinner wrote:
> > > > cmpxchg is for replacing a known object in a store - it's not really
> > > > intended for doing initial inserts after a lookup tells us there is
> > > > nothing in the store.  The radix tree "insert only if empty" makes
> > > > sense here, because it naturally takes care of lookup/insert races
> > > > via the -EEXIST mechanism.
> > > > 
> > > > I think that providing xa_store_excl() (which would return -EEXIST
> > > > if the entry is not empty) would be a better interface here, because
> > > > it matches the semantics of lookup cache population used all over
> > > > the kernel....
> > > 
> > > I'm not thrilled with xa_store_excl(), but I need to think about that
> > > a bit more.
> > 
> > Not fussed about the name - I just think we need a function that
> > matches the insert semantics of the code....
> 
> I think I have something that works better for you than returning -EEXIST
> (because you don't actually want -EEXIST, you want -EAGAIN):
> 
>         /* insert the new inode */
> -       spin_lock(&pag->pag_ici_lock);
> -       error = radix_tree_insert(&pag->pag_ici_root, agino, ip);
> -       if (unlikely(error)) {
> -               WARN_ON(error != -EEXIST);
> -               XFS_STATS_INC(mp, xs_ig_dup);
> -               error = -EAGAIN;
> -               goto out_preload_end;
> -       }
> -       spin_unlock(&pag->pag_ici_lock);
> -       radix_tree_preload_end();
> +       curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
> +       error = __xa_race(curr, -EAGAIN);
> +       if (error)
> +               goto out_unlock;
> 
> ...
> 
> -out_preload_end:
> -       spin_unlock(&pag->pag_ici_lock);
> -       radix_tree_preload_end();
> +out_unlock:
> +       if (error == -EAGAIN)
> +               XFS_STATS_INC(mp, xs_ig_dup);
> 
> I've changed the behaviour slightly in that returning an -ENOMEM used to
> hit a WARN_ON, and I don't think that's the right response -- GFP_NOFS
> returning -ENOMEM probably gets you a nice warning already from the
> mm code.

It's been a couple of days since I first looked at this, and my
initial reaction of "that's horrible!" hasn't changed.

What you are proposing here might be a perfectly reasonable
*internal implemention* of xa_store_excl(), but it makes for a
terrible external API because the sematics and behaviour are so
vague. e.g. what does "race" mean here with respect to an insert
failure?

i.e.  the fact the cmpxchg failed may not have anything to do with a
race condtion - it failed because the slot wasn't empty like we
expected it to be. There can be any number of reasons the slot isn't
empty - the API should not "document" that the reason the insert
failed was a race condition. It should document the case that we
"couldn't insert because there was an existing entry in the slot".
Let the surrounding code document the reason why that might have
happened - it's not for the API to assume reasons for failure.

i.e. this API and potential internal implementation makes much
more sense:

int
xa_store_iff_empty(...)
{
	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
	if (!curr)
		return 0;	/* success! */
	if (!IS_ERR(curr))
		return -EEXIST;	/* failed - slot not empty */
	return PTR_ERR(curr);	/* failed - XA internal issue */
}

as it replaces the existing preload and insert code in the XFS code
paths whilst letting us handle and document the "insert failed
because slot not empty" case however we want. It implies nothing
about *why* the slot wasn't empty, just that we couldn't do the
insert because it wasn't empty.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
