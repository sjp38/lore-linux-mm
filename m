Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F03196B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:37:53 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xm6so131347098pab.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:37:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yp3si13565360pac.120.2016.05.05.14.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 14:37:53 -0700 (PDT)
Date: Thu, 5 May 2016 14:37:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] writeback: Avoid exhausting allocation reserves under
 memory pressure
Message-Id: <20160505143751.06aa4223e266c1d92b3323a2@linux-foundation.org>
In-Reply-To: <20160505090750.GD1970@quack2.suse.cz>
References: <1462436092-32665-1-git-send-email-jack@suse.cz>
	<20160505082433.GC4386@dhcp22.suse.cz>
	<20160505090750.GD1970@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org

On Thu, 5 May 2016 11:07:50 +0200 Jan Kara <jack@suse.cz> wrote:

> On Thu 05-05-16 10:24:33, Michal Hocko wrote:
> > > +/*
> > > + * Check whether the request to writeback some pages can be merged with some
> > > + * other request which is already pending. If yes, merge it and return true.
> > > + * If no, return false.
> > > + */
> > > +static bool wb_merge_request(struct bdi_writeback *wb, long nr_pages,
> > > +			     struct super_block *sb, bool range_cyclic,
> > > +			     enum wb_reason reason)
> > > +{
> > > +	struct wb_writeback_work *work;
> > > +	bool merged = false;
> > > +
> > > +	spin_lock_bh(&wb->work_lock);
> > > +	list_for_each_entry(work, &wb->work_list, list) {
> > 
> > Is the lenght of the list bounded somehow? In other words is it possible
> > that the spinlock would be held for too long to traverse the whole list?
> 
> I was thinking about this as well. With the merging enabled, the number of
> entries queued from wb_start_writeback() is essentially limited by the
> number of writeback reasons and there's only a couple of those. What is
> more questionable is the number of entries queued from
> __writeback_inodes_sb_nr(). Generally there should be a couple at maximum
> either but it is hard to give any guarantee since e.g. filesystems use this
> function to reduce amount of delay-allocated data when they are running out
> of space. Hum, maybe we could limit the merging to scan only the last say
> 16 entries. That should give good results in most cases... Thoughts?

If it's possible to cause a search complexity meltdown, someone will
find a way :(

Is there any reason why the requests coming out of
writeback_inodes_sb_nr() cannot also be merged?

Your wb_merge_request() doesn't check ->tagged_writepages?

Why is ->for_sync handled differently?  Needs a comment.

Suggest turning this into a separate function.  Build a local
wb_writeback_work in wb_start_writeback(), do:


	/* comment goes here */
	if (new->reason != old->reason)
		return false;
	/* comment goes here */
	if (new->range_cyclic != old->range_cyclic)
		retun false;
	return true;

then copy wb_start_writeback()'s local wb_writeback_work into the
newly-allocated one if needed (kmemdup()).  Or just pass a billion args
into that comparison function.

bdi_split_work_to_wbs() does GFP_ATOMIC as well.  Problem?  (Why the
heck don't we document the *reasons* for these things, sigh).

I suspect it would be best to be proactive here and use some smarter
data structure.  It appears that all the wb_writeback_work fields
except sb can be squeezed into a single word so perhaps a radix-tree. 
Or hash them all together and use a chained array or something.  Maybe
fiddle at it for an hour or so, see how it's looking?  It's a lot of
fuss to avoid one problematic kmalloc(), sigh.

We really don't want there to be *any* pathological workload which
results in merging failures - if that's the case then someone will hit
it.  They'll experience the ooms (perhaps) and the search complexity
issues (for sure).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
