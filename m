Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EACDA6B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:09:25 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p6CM9Md8011314
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:09:23 -0700
Received: from iyl8 (iyl8.prod.google.com [10.241.51.200])
	by hpaq2.eem.corp.google.com with ESMTP id p6CM96Hx019718
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:09:21 -0700
Received: by iyl8 with SMTP id 8so6667583iyl.14
        for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:09:19 -0700 (PDT)
Date: Tue, 12 Jul 2011 15:08:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
In-Reply-To: <20110618145254.1b333344.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1107121501100.2112@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140342330.29206@sister.anvils> <20110618145254.1b333344.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 18 Jun 2011, Andrew Morton wrote:
> On Tue, 14 Jun 2011 03:43:47 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > --- linux.orig/mm/filemap.c	2011-06-13 13:26:44.430284135 -0700
> > +++ linux/mm/filemap.c	2011-06-13 13:27:34.526532556 -0700
> > @@ -717,9 +717,12 @@ repeat:
> >  		page = radix_tree_deref_slot(pagep);
> >  		if (unlikely(!page))
> >  			goto out;
> > -		if (radix_tree_deref_retry(page))
> > +		if (radix_tree_exception(page)) {
> > +			if (radix_tree_exceptional_entry(page))
> > +				goto out;
> > +			/* radix_tree_deref_retry(page) */
> >  			goto repeat;
> > -
> > +		}
> >  		if (!page_cache_get_speculative(page))
> >  			goto repeat;
> 
> All the crap^Wnice changes made to filemap.c really need some comments,
> please.  Particularly when they're keyed off the bland-sounding
> "radix_tree_exception()".  Apparently they have something to do with
> swap, but how is the poor reader to know this?

The naming was intentionally bland, because other filesystems might
in future have other uses for such exceptional entries.

(I think the field size would generally defeat it, but you can,
for example, imagine a small filesystem wanting to save sector number
there when a page is evicted.)

But let's go bland when it's more familiar, and such uses materialize -
particularly since I only placed those checks in places where they're
needed now for shmem/tmpfs/swap.

I'll keep the bland naming, if that's okay, but send a patch adding
a line of comment in such places.  Mentioning shmem, tmpfs, swap.

> 
> Also, commenting out a function call might be meaningful information for
> Hugh-right-now, but for other people later on, they're just a big WTF.

Ah yes, I hadn't realized at all that those look like commented-out
function calls.  No, they're comments on what the else case is that
we have arrived at there.  I'll make those clearer too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
