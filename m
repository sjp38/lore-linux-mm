Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 61E596B0255
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 04:15:20 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so78377643wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 01:15:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id om11si3399244wic.29.2015.10.13.01.15.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 01:15:18 -0700 (PDT)
Date: Tue, 13 Oct 2015 10:15:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 1/2] ext4: Fix possible deadlock with local
 interrupts disabled and page-draining IPI
Message-ID: <20151013081512.GJ17050@quack.suse.cz>
References: <062501d10262$d40d0a50$7c271ef0$@alibaba-inc.com>
 <56176C10.8040709@kyup.com>
 <062801d10265$5a749fc0$0f5ddf40$@alibaba-inc.com>
 <561774D2.3050002@kyup.com>
 <20151012134020.GA21302@quack.suse.cz>
 <561BC8DB.6070600@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561BC8DB.6070600@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Jan Kara <jack@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-fsdevel@vger.kernel.org, SiteGround Operations <operations@siteground.com>, vbabka@suse.cz, gilad@benyossef.com, mgorman@suse.de, linux-mm@kvack.org, Marian Marinov <mm@1h.com>

On Mon 12-10-15 17:51:07, Nikolay Borisov wrote:
> Hello and thanks for the reply,
> 
> On 10/12/2015 04:40 PM, Jan Kara wrote:
> > On Fri 09-10-15 11:03:30, Nikolay Borisov wrote:
> >> On 10/09/2015 10:37 AM, Hillf Danton wrote:
> >>>>>> @@ -109,8 +109,8 @@ static void ext4_finish_bio(struct bio *bio)
> >>>>>>  			if (bio->bi_error)
> >>>>>>  				buffer_io_error(bh);
> >>>>>>  		} while ((bh = bh->b_this_page) != head);
> >>>>>> -		bit_spin_unlock(BH_Uptodate_Lock, &head->b_state);
> >>>>>>  		local_irq_restore(flags);
> >>>>>
> >>>>> What if it takes 100ms to unlock after IRQ restored?
> >>>>
> >>>> I'm not sure I understand in what direction you are going? Care to
> >>>> elaborate?
> >>>>
> >>> Your change introduces extra time cost the lock waiter has to pay in
> >>> the case that irq happens before the lock is released.
> >>
> >> [CC filesystem and mm people. For reference the thread starts here:
> >>  http://thread.gmane.org/gmane.linux.kernel/2056996 ]
> >>
> >> Right, I see what you mean and it's a good point but when doing the
> >> patches I was striving for correctness and starting a discussion, hence
> >> the RFC. In any case I'd personally choose correctness over performance
> >> always ;).
> >>
> >> As I'm not an fs/ext4 expert and have added the relevant parties (please
> >> use reply-all from now on so that the thread is not being cut in the
> >> middle) who will be able to say whether it impact is going to be that
> >> big. I guess in this particular code path worrying about this is prudent
> >> as writeback sounds like a heavily used path.
> >>
> >> Maybe the problem should be approached from a different angle e.g.
> >> drain_all_pages and its reliance on the fact that the IPI will always be
> >> delivered in some finite amount of time? But what if a cpu with disabled
> >> interrupts is waiting on the task issuing the IPI?
> > 
> > So I have looked through your patch and also original report (thread starts
> > here: https://lkml.org/lkml/2015/10/8/341) and IMHO one question hasn't
> > been properly answered yet: Who is holding BH_Uptodate_Lock we are spinning
> > on? You have suggested in https://lkml.org/lkml/2015/10/8/464 that it was
> > __block_write_full_page_endio() call but that cannot really be the case.
> > BH_Uptodate_Lock is used only in IO completion handlers -
> > end_buffer_async_read, end_buffer_async_write, ext4_finish_bio. So there
> > really should be some end_io function running on some other CPU which holds
> > BH_Uptodate_Lock for that buffer.
> 
> I did check all the call traces of the current processes on the machine
> at the time of the hard lockup and none of the 3 functions you mentioned
> were in any of the call chains. But while I was looking the code of
> end_buffer_async_write and in the comments I saw it was mentioned that
> those completion handler were called from __block_write_full_page_endio
> so that's what pointed my attention to that function. But you are right
> that it doesn't take the BH lock.
> 
> Furthermore the fact that the BH_Async_Write flag is set points me in
> the direction that end_buffer_async_write should have been executing but
> as I said issuing "bt" for all the tasks didn't show this function.

Actually ext4_bio_write_page() also sets BH_Async_Write so that seems like
a more likely place where that flag got set since ext4_finish_bio() was
then handling IO completion.

> I'm beginning to wonder if it's possible that a single bit memory error
> has crept up, but this still seems like a long shot...

Yup. Possible but a long shot. Is the problem reproducible in any way?

> Btw I think in any case the spin_lock patch is wrong as this code can be
> called from within softirq context and we do want to be interrupt safe
> at that point.

Agreed, that patch is definitely wrong.

> > BTW: I suppose the filesystem uses 4k blocksize, doesn't it?
> 
> Unfortunately I cannot tell you with 100% certainty, since on this
> server there are multiple block devices with blocksize either 1k or 4k.
> So it is one of these. If you know a way to extract this information
> from a vmcore file I'd be happy to do it.

Well, if you have a crashdump, then bh->b_size is the block size. So just
check that for the bh we are spinning on.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
