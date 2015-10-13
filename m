Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 790316B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:15:21 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so57755777wic.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 06:15:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11si3596039wiv.13.2015.10.13.06.14.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 06:14:57 -0700 (PDT)
Date: Tue, 13 Oct 2015 15:14:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 1/2] ext4: Fix possible deadlock with local
 interrupts disabled and page-draining IPI
Message-ID: <20151013131453.GA1332@quack.suse.cz>
References: <062501d10262$d40d0a50$7c271ef0$@alibaba-inc.com>
 <56176C10.8040709@kyup.com>
 <062801d10265$5a749fc0$0f5ddf40$@alibaba-inc.com>
 <561774D2.3050002@kyup.com>
 <20151012134020.GA21302@quack.suse.cz>
 <561BC8DB.6070600@kyup.com>
 <20151013081512.GJ17050@quack.suse.cz>
 <561CDEDC.30707@kyup.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Content-Disposition: inline
In-Reply-To: <561CDEDC.30707@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Jan Kara <jack@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-fsdevel@vger.kernel.org, SiteGround Operations <operations@siteground.com>, vbabka@suse.cz, gilad@benyossef.com, mgorman@suse.de, linux-mm@kvack.org, Marian Marinov <mm@1h.com>


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 13-10-15 13:37:16, Nikolay Borisov wrote:
> 
> 
> On 10/13/2015 11:15 AM, Jan Kara wrote:
> > On Mon 12-10-15 17:51:07, Nikolay Borisov wrote:
> >> Hello and thanks for the reply,
> >>
> >> On 10/12/2015 04:40 PM, Jan Kara wrote:
> >>> On Fri 09-10-15 11:03:30, Nikolay Borisov wrote:
> >>>> On 10/09/2015 10:37 AM, Hillf Danton wrote:
> >>>>>>>> @@ -109,8 +109,8 @@ static void ext4_finish_bio(struct bio *bio)
> >>>>>>>>  			if (bio->bi_error)
> >>>>>>>>  				buffer_io_error(bh);
> >>>>>>>>  		} while ((bh = bh->b_this_page) != head);
> >>>>>>>> -		bit_spin_unlock(BH_Uptodate_Lock, &head->b_state);
> >>>>>>>>  		local_irq_restore(flags);
> >>>>>>>
> >>>>>>> What if it takes 100ms to unlock after IRQ restored?
> >>>>>>
> >>>>>> I'm not sure I understand in what direction you are going? Care to
> >>>>>> elaborate?
> >>>>>>
> >>>>> Your change introduces extra time cost the lock waiter has to pay in
> >>>>> the case that irq happens before the lock is released.
> >>>>
> >>>> [CC filesystem and mm people. For reference the thread starts here:
> >>>>  http://thread.gmane.org/gmane.linux.kernel/2056996 ]
> >>>>
> >>>> Right, I see what you mean and it's a good point but when doing the
> >>>> patches I was striving for correctness and starting a discussion, hence
> >>>> the RFC. In any case I'd personally choose correctness over performance
> >>>> always ;).
> >>>>
> >>>> As I'm not an fs/ext4 expert and have added the relevant parties (please
> >>>> use reply-all from now on so that the thread is not being cut in the
> >>>> middle) who will be able to say whether it impact is going to be that
> >>>> big. I guess in this particular code path worrying about this is prudent
> >>>> as writeback sounds like a heavily used path.
> >>>>
> >>>> Maybe the problem should be approached from a different angle e.g.
> >>>> drain_all_pages and its reliance on the fact that the IPI will always be
> >>>> delivered in some finite amount of time? But what if a cpu with disabled
> >>>> interrupts is waiting on the task issuing the IPI?
> >>>
> >>> So I have looked through your patch and also original report (thread starts
> >>> here: https://lkml.org/lkml/2015/10/8/341) and IMHO one question hasn't
> >>> been properly answered yet: Who is holding BH_Uptodate_Lock we are spinning
> >>> on? You have suggested in https://lkml.org/lkml/2015/10/8/464 that it was
> >>> __block_write_full_page_endio() call but that cannot really be the case.
> >>> BH_Uptodate_Lock is used only in IO completion handlers -
> >>> end_buffer_async_read, end_buffer_async_write, ext4_finish_bio. So there
> >>> really should be some end_io function running on some other CPU which holds
> >>> BH_Uptodate_Lock for that buffer.
> >>
> >> I did check all the call traces of the current processes on the machine
> >> at the time of the hard lockup and none of the 3 functions you mentioned
> >> were in any of the call chains. But while I was looking the code of
> >> end_buffer_async_write and in the comments I saw it was mentioned that
> >> those completion handler were called from __block_write_full_page_endio
> >> so that's what pointed my attention to that function. But you are right
> >> that it doesn't take the BH lock.
> >>
> >> Furthermore the fact that the BH_Async_Write flag is set points me in
> >> the direction that end_buffer_async_write should have been executing but
> >> as I said issuing "bt" for all the tasks didn't show this function.
> > 
> > Actually ext4_bio_write_page() also sets BH_Async_Write so that seems like
> > a more likely place where that flag got set since ext4_finish_bio() was
> > then handling IO completion.
> > 
> >> I'm beginning to wonder if it's possible that a single bit memory error
> >> has crept up, but this still seems like a long shot...
> > 
> > Yup. Possible but a long shot. Is the problem reproducible in any way?
> 
> Okay, I rule out hardware issue since a different server today 
> experienced the same hard lockup. One thing which looks 
> suspicious to me are the repetitions of bio_endio/clone_endio: 
> 
> Oct 13 03:16:54 10.80.5.48 Call Trace:
> Oct 13 03:16:54 10.80.5.48 <NMI>
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81651631>] dump_stack+0x58/0x7f
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81089a6c>] warn_slowpath_common+0x8c/0xc0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81089b56>] warn_slowpath_fmt+0x46/0x50
> Oct 13 03:16:54 10.80.5.48 [<ffffffff811015f8>] watchdog_overflow_callback+0x98/0xc0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81132d0c>] __perf_event_overflow+0x9c/0x250
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81133664>] perf_event_overflow+0x14/0x20
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81061796>] intel_pmu_handle_irq+0x1d6/0x3e0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8105b4c4>] perf_event_nmi_handler+0x34/0x60
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8104c152>] nmi_handle+0xa2/0x1a0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8104c3b4>] do_nmi+0x164/0x430
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81656e2e>] end_repeat_nmi+0x1a/0x1e
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8125be19>] ? ext4_finish_bio+0x279/0x2a0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8125be19>] ? ext4_finish_bio+0x279/0x2a0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8125be19>] ? ext4_finish_bio+0x279/0x2a0
> Oct 13 03:16:54 10.80.5.48 <<EOE>> 
> Oct 13 03:16:54 10.80.5.48 <IRQ> 
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8125c2c8>] ext4_end_bio+0xc8/0x120
> Oct 13 03:16:54 10.80.5.48 [<ffffffff811dbf1d>] bio_endio+0x1d/0x40
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546781>] dec_pending+0x1c1/0x360
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546996>] clone_endio+0x76/0xa0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff811dbf1d>] bio_endio+0x1d/0x40
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546781>] dec_pending+0x1c1/0x360
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546996>] clone_endio+0x76/0xa0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff811dbf1d>] bio_endio+0x1d/0x40
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546781>] dec_pending+0x1c1/0x360
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81546996>] clone_endio+0x76/0xa0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff811dbf1d>] bio_endio+0x1d/0x40
> Oct 13 03:16:54 10.80.5.48 [<ffffffff812fad2b>] blk_update_request+0x21b/0x450
> Oct 13 03:16:54 10.80.5.48 [<ffffffff810e7797>] ? generic_exec_single+0xa7/0xb0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff812faf87>] blk_update_bidi_request+0x27/0xb0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff810e7817>] ? __smp_call_function_single+0x77/0x120
> Oct 13 03:16:54 10.80.5.48 [<ffffffff812fcc7f>] blk_end_bidi_request+0x2f/0x80
> Oct 13 03:16:54 10.80.5.48 [<ffffffff812fcd20>] blk_end_request+0x10/0x20
> Oct 13 03:16:54 10.80.5.48 [<ffffffff813fdc1c>] scsi_io_completion+0xbc/0x620
> Oct 13 03:16:54 10.80.5.48 [<ffffffff813f57f9>] scsi_finish_command+0xc9/0x130
> Oct 13 03:16:54 10.80.5.48 [<ffffffff813fe2e7>] scsi_softirq_done+0x147/0x170
> Oct 13 03:16:54 10.80.5.48 [<ffffffff813035ad>] blk_done_softirq+0x7d/0x90
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8108ed87>] __do_softirq+0x137/0x2e0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81658a0c>] call_softirq+0x1c/0x30
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8104a35d>] do_softirq+0x8d/0xc0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff8108e925>] irq_exit+0x95/0xa0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81658f76>] do_IRQ+0x66/0xe0
> Oct 13 03:16:54 10.80.5.48 [<ffffffff816567ef>] common_interrupt+0x6f/0x6f
> Oct 13 03:16:54 10.80.5.48 <EOI> 
> Oct 13 03:16:54 10.80.5.48 [<ffffffff81656836>] ? retint_swapgs+0xe/0x13
> Oct 13 03:16:54 10.80.5.48 ---[ end trace 4a0584a583c66b92 ]---
> 
> Doing addr2line on ffffffff8125c2c8 shows:
> /home/projects/linux-stable/fs/ext4/page-io.c:335 which for me is the
> last bio_put in ext4_end_bio. However, the ? addresses, right at the
> beginning of the NMI stack (ffffffff8125be19) map to inner loop in
> bit_spin_lock:
> 
> } while (test_bit(bitnum, addr));
> 
> and this is in line with my initial bug report. 

OK.

> Unfortunately I wasn't able to acquire a crashdump since the machine
> hard-locked way too fast.
>
> On a slightly different note is it possible to
> panic the machine via NMIs? Since if all the CPUs are hard lockedup they
> cannot process sysrq interrupts?

Certainly it's possible to do that - the easiest way is actually to use

nmi_watchdog=panic

Then panic will automatically trigger when watchdog fires.

> >> Btw I think in any case the spin_lock patch is wrong as this code can be
> >> called from within softirq context and we do want to be interrupt safe
> >> at that point.
> > 
> > Agreed, that patch is definitely wrong.
> > 
> >>> BTW: I suppose the filesystem uses 4k blocksize, doesn't it?
> >>
> >> Unfortunately I cannot tell you with 100% certainty, since on this
> >> server there are multiple block devices with blocksize either 1k or 4k.
> >> So it is one of these. If you know a way to extract this information
> >> from a vmcore file I'd be happy to do it.
> > 
> > Well, if you have a crashdump, then bh->b_size is the block size. So just
> > check that for the bh we are spinning on.
> 
> Turns out in my original email the bh->b_size was shown : 
> b_size = 0x400 == 1k. So the filesystem is not 4k but 1k. 

OK, then I have a theory. We can manipulate bh->b_state in a non-atomic
manner in _ext4_get_block(). If we happen to do that on the first buffer in
a page while IO completes on another buffer in the same page, we could in
theory mess up and miss clearing of BH_Uptodate_Lock flag. Can you try
whether the attached patch fixes your problem?

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--Q68bSM7Ycu6FN28Q
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-ext4-Fix-bh-b_state-corruption.patch"


--Q68bSM7Ycu6FN28Q--
