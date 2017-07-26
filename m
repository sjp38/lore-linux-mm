Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57CB26B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:22:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x64so9206631wmg.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 02:22:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 98si8119930wrl.5.2017.07.26.02.22.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 02:22:31 -0700 (PDT)
Date: Wed, 26 Jul 2017 10:22:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170726092228.pyjxamxweslgaemi@suse.de>
References: <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170726054306.GA11100@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
> > I'm relying on the fact you are the madv_free author to determine if
> > it's really necessary. The race in question is CPU 0 running madv_free
> > and updating some PTEs while CPU 1 is also running madv_free and looking
> > at the same PTEs. CPU 1 may have writable TLB entries for a page but fail
> > the pte_dirty check (because CPU 0 has updated it already) and potentially
> > fail to flush. Hence, when madv_free on CPU 1 returns, there are still
> > potentially writable TLB entries and the underlying PTE is still present
> > so that a subsequent write does not necessarily propagate the dirty bit
> > to the underlying PTE any more. Reclaim at some unknown time at the future
> > may then see that the PTE is still clean and discard the page even though
> > a write has happened in the meantime. I think this is possible but I could
> > have missed some protection in madv_free that prevents it happening.
> 
> Thanks for the detail. You didn't miss anything. It can happen and then
> it's really bug. IOW, if application does write something after madv_free,
> it must see the written value, not zero.
> 
> How about adding [set|clear]_tlb_flush_pending in tlb batchin interface?
> With it, when tlb_finish_mmu is called, we can know we skip the flush
> but there is pending flush, so flush focefully to avoid madv_dontneed
> as well as madv_free scenario.
> 

I *think* this is ok as it's simply more expensive on the KSM side in
the event of a race but no other harmful change is made assuming that
KSM is the only race-prone. The check for mm_tlb_flush_pending also
happens under the PTL so there should be sufficient protection from the
mm struct update being visible at teh right time.

Check using the test program from "mm: Always flush VMA ranges affected
by zap_page_range v2" if it handles the madvise case as well as that
would give some degree of safety. Make sure it's tested against 4.13-rc2
instead of mmotm which already includes the madv_dontneed fix. If yours
works for both then it supersedes the mmotm patch.

It would also be interesting if Nadav would use his slowdown hack to see
if he can still force the corruption.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
