Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C044BC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 554E520989
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 554E520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA2486B0003; Thu,  9 May 2019 18:12:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B5E6B0006; Thu,  9 May 2019 18:12:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CAC76B0007; Thu,  9 May 2019 18:12:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 781526B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 18:12:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id w34so4166599qtc.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 15:12:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=Sy1TZOOlBwrfOhCrhGvB6/v/LWb6w/jhR4xlSg1IVfo=;
        b=hSs1VuMur13PUnCJNt0N0QF9Cb3DxEK73R8GV32DXLM/Or+haXA7I4PGMbjT4sFjyz
         1MbY++X4G75J9PipX3YWCWCURla24616X51ApKkSJoeflDriYXq2m1vEGnHT2dpVB5oW
         V2j/FAGiG/zkX06yR0Ifje3JJWcrUm6jyI2WWGxUJemymWIV72VUs6Eu7g2d53PA6vDl
         Q36VK6M0VgE4xsjIZRrmlARB7GfCCn+fLNY6FxvYuPl62M52OnAsC85JxaEgNiE/ps0A
         M4kSIFpsSTb2Ykn5y+Vbz60OVD4Xw0zT/0BCuTE7l5Jmy6A908MxoLm1seZKZIAZDpz8
         Q1jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUR4ciItSX/ObuShqH9EMAZznRThB6pKB5WfTGnf8qxnRNCPaCl
	LfNM7iokb2wPsztK9rLvXBQ2D8CY5urvp4RXjd6hybRz8eT3aDZhQIsZoHhB/hi5JFr5Rb1IR4T
	FCDm0lSc2FlnWfg0Ckdc+vRNny8AxtdIH3k1KCKgwD8gleq5TwUVZ2d5CaIJ2fugrgg==
X-Received: by 2002:a37:7a84:: with SMTP id v126mr5757960qkc.335.1557439954231;
        Thu, 09 May 2019 15:12:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLetZNVjiI8BrbXRtGkNJaAvd+ftDi/ZN7Gec5tqBTxWfL7g/bMjssxyS5qGIH13YgPreE
X-Received: by 2002:a37:7a84:: with SMTP id v126mr5757889qkc.335.1557439953439;
        Thu, 09 May 2019 15:12:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557439953; cv=none;
        d=google.com; s=arc-20160816;
        b=ItnAW2hfwGqO6p8P6qf4cwIMgVjfJsmKRyDh41ZdUjc/LJU2qC/oHIcvKlLj7B3sid
         Xuo+yq5z4s/x3K3ldZAKhKpqMpgxx7BvJg9LcJtue6wFs3Iwa1DHypxudybRCriGtpkM
         5E80ndJhBfDYOjcHbEmK0H1bA7dLhmhsg61lJx3XK08UG/xgEJIN+O7x5wIfM0fBJhws
         ZYScqqs6XNUsESCzodn3wQ2SZemiG/GhcS8b0hAw5urpjVxc2O+kGKn+LJUZAbMGbyhF
         9d51x7z8lUiLi85ime6bwIzmdA6wQB+gnXX0E8MgmcoJuff1xfxvH2zxkx/KBh+h8fMP
         AL7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=Sy1TZOOlBwrfOhCrhGvB6/v/LWb6w/jhR4xlSg1IVfo=;
        b=mm9RrnQA+aSJDNP8P+/G4KMK2WRiukEh0h5mKhY9HuXEQvodeOVtZziww3PmwGhtm3
         q5rMrB+YG3mNR1FUS4lGEXkduikif6xdQRdfZGrjKJXk02HAqkNZMYp9NgykRAhKq8nu
         PfyVqzwQMraReWJnhaCgrdrTojEFJp6bHqUDX3XchHjjl+w7O1tl7pYknVOoQVbLGzF2
         34xTKfFJB6NRLjhBfC/JclexnLtO4wBcJrwx+fUI7tAE7hJjCiwBJ2xRJ2G6Hbg0pjYE
         fAStjfGsPzgfqAqqQyTAFrJfjvcbE6c4S8ZdP9g/CQ1xb2KXcB9Ef5gy3lajYRR6lE8x
         FRjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l23si2444052qvc.97.2019.05.09.15.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 15:12:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 57F7E8665A;
	Thu,  9 May 2019 22:12:32 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 20A752E035;
	Thu,  9 May 2019 22:12:32 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id D6BF718089C9;
	Thu,  9 May 2019 22:12:31 +0000 (UTC)
Date: Thu, 9 May 2019 18:12:28 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>, 
	Will Deacon <will.deacon@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, npiggin@gmail.com, 
	minchan@kernel.org, Mel Gorman <mgorman@suse.de>, 
	Jan Stancek <jstancek@redhat.com>
Message-ID: <723588321.21952404.1557439948824.JavaMail.zimbra@redhat.com>
In-Reply-To: <6f606e4f-d151-0c43-11f4-4a78e6dfabbf@linux.alibaba.com>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com> <20190509083726.GA2209@brain-police> <20190509103813.GP2589@hirez.programming.kicks-ass.net> <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com> <20190509182435.GA2623@hirez.programming.kicks-ass.net> <84720bb8-bf3d-8c10-d675-0670f13b2efc@linux.alibaba.com> <249230644.21949166.1557435998550.JavaMail.zimbra@redhat.com> <6f606e4f-d151-0c43-11f4-4a78e6dfabbf@linux.alibaba.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.125, 10.4.195.27]
Thread-Topic: mmu_gather: remove __tlb_reset_range() for force flush
Thread-Index: GURBsAdvqVJn9wCKGeKzRM66jWF8ow==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 09 May 2019 22:12:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


----- Original Message -----
> 
> 
> On 5/9/19 2:06 PM, Jan Stancek wrote:
> > ----- Original Message -----
> >>
> >> On 5/9/19 11:24 AM, Peter Zijlstra wrote:
> >>> On Thu, May 09, 2019 at 05:36:29PM +0000, Nadav Amit wrote:
> >>>>> On May 9, 2019, at 3:38 AM, Peter Zijlstra <peterz@infradead.org>
> >>>>> wrote:
> >>>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> >>>>> index 99740e1dd273..fe768f8d612e 100644
> >>>>> --- a/mm/mmu_gather.c
> >>>>> +++ b/mm/mmu_gather.c
> >>>>> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >>>>> 		unsigned long start, unsigned long end)
> >>>>> {
> >>>>> 	/*
> >>>>> -	 * If there are parallel threads are doing PTE changes on same range
> >>>>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> >>>>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> >>>>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> >>>>> -	 * forcefully if we detect parallel PTE batching threads.
> >>>>> +	 * Sensible comment goes here..
> >>>>> 	 */
> >>>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
> >>>>> -		__tlb_reset_range(tlb);
> >>>>> -		__tlb_adjust_range(tlb, start, end - start);
> >>>>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> >>>>> +		/*
> >>>>> +		 * Since we're can't tell what we actually should have
> >>>>> +		 * flushed flush everything in the given range.
> >>>>> +		 */
> >>>>> +		tlb->start = start;
> >>>>> +		tlb->end = end;
> >>>>> +		tlb->freed_tables = 1;
> >>>>> +		tlb->cleared_ptes = 1;
> >>>>> +		tlb->cleared_pmds = 1;
> >>>>> +		tlb->cleared_puds = 1;
> >>>>> +		tlb->cleared_p4ds = 1;
> >>>>> 	}
> >>>>>
> >>>>> 	tlb_flush_mmu(tlb);
> >>>> As a simple optimization, I think it is possible to hold multiple
> >>>> nesting
> >>>> counters in the mm, similar to tlb_flush_pending, for freed_tables,
> >>>> cleared_ptes, etc.
> >>>>
> >>>> The first time you set tlb->freed_tables, you also atomically increase
> >>>> mm->tlb_flush_freed_tables. Then, in tlb_flush_mmu(), you just use
> >>>> mm->tlb_flush_freed_tables instead of tlb->freed_tables.
> >>> That sounds fraught with races and expensive; I would much prefer to not
> >>> go there for this arguably rare case.
> >>>
> >>> Consider such fun cases as where CPU-0 sees and clears a PTE, CPU-1
> >>> races and doesn't see that PTE. Therefore CPU-0 sets and counts
> >>> cleared_ptes. Then if CPU-1 flushes while CPU-0 is still in mmu_gather,
> >>> it will see cleared_ptes count increased and flush that granularity,
> >>> OTOH if CPU-1 flushes after CPU-0 completes, it will not and potentiall
> >>> miss an invalidate it should have had.
> >>>
> >>> This whole concurrent mmu_gather stuff is horrible.
> >>>
> >>>     /me ponders more....
> >>>
> >>> So I think the fundamental race here is this:
> >>>
> >>> 	CPU-0				CPU-1
> >>>
> >>> 	tlb_gather_mmu(.start=1,	tlb_gather_mmu(.start=2,
> >>> 		       .end=3);			       .end=4);
> >>>
> >>> 	ptep_get_and_clear_full(2)
> >>> 	tlb_remove_tlb_entry(2);
> >>> 	__tlb_remove_page();
> >>> 					if (pte_present(2)) // nope
> >>>
> >>> 					tlb_finish_mmu();
> >>>
> >>> 					// continue without TLBI(2)
> >>> 					// whoopsie
> >>>
> >>> 	tlb_finish_mmu();
> >>> 	  tlb_flush()		->	TLBI(2)
> >> I'm not quite sure if this is the case Jan really met. But, according to
> >> his test, once correct tlb->freed_tables and tlb->cleared_* are set, his
> >> test works well.
> > My theory was following sequence:
> >
> > t1: map_write_unmap()                 t2: dummy()
> >
> >    map_address = mmap()
> >    map_address[i] = 'b'
> >    munmap(map_address)
> >    downgrade_write(&mm->mmap_sem);
> >    unmap_region()
> >    tlb_gather_mmu()
> >      inc_tlb_flush_pending(tlb->mm);
> >    free_pgtables()
> >      tlb->freed_tables = 1
> >      tlb->cleared_pmds = 1
> >
> >                                          pthread_exit()
> >                                          madvise(thread_stack, 8M,
> >                                          MADV_DONTNEED)
> 
> I'm not quite familiar with the implementation detail of pthread_exit(),
> does pthread_exit() call MADV_DONTNEED all the time? I don't see your
> test call it.

It's called by glibc:
  https://sourceware.org/git/?p=glibc.git;a=blob;f=nptl/allocatestack.c;h=fcbc46f0d796abce8d58970d4a1d3df685981e33;hb=refs/heads/master#l380
  https://sourceware.org/git/?p=glibc.git;a=blob;f=nptl/pthread_create.c;h=18b7bbe7659c027dfd7b0ce3b0c83f54a6f15b18;hb=refs/heads/master#l569

(gdb) bt
#0  madvise () at ../sysdeps/unix/syscall-template.S:78
#1  0x0000ffffbe7679f8 in advise_stack_range (guardsize=<optimized out>, pd=281474976706191, size=<optimized out>, mem=0xffffbddd0000)
    at allocatestack.c:392
#2  start_thread (arg=0xffffffffee8f) at pthread_create.c:576
#3  0x0000ffffbe6b157c in thread_start () at ../sysdeps/unix/sysv/linux/aarch64/clone.S:78

Dump of assembler code for function madvise:
=> 0x0000ffffbe6adaf0 <+0>:     mov     x8, #0xe9                       // #233
   0x0000ffffbe6adaf4 <+4>:     svc     #0x0
   0x0000ffffbe6adaf8 <+8>:     cmn     x0, #0xfff
   0x0000ffffbe6adafc <+12>:    b.cs    0xffffbe6adb04 <madvise+20>  // b.hs, b.nlast
   0x0000ffffbe6adb00 <+16>:    ret
   0x0000ffffbe6adb04 <+20>:    b       0xffffbe600e18 <__GI___syscall_error>


> If so this pattern is definitely possible.
> 
> >                                            zap_page_range()
> >                                              tlb_gather_mmu()
> >                                                inc_tlb_flush_pending(tlb->mm);
> >
> >    tlb_finish_mmu()
> >      if (mm_tlb_flush_nested(tlb->mm))
> >        __tlb_reset_range()
> >          tlb->freed_tables = 0
> >          tlb->cleared_pmds = 0
> >      __flush_tlb_range(last_level = 0)
> >    ...
> >    map_address = mmap()
> >      map_address[i] = 'b'
> >        <page fault loop>
> >        # PTE appeared valid to me,
> >        # so I suspected stale TLB entry at higher level as result of
> >        "freed_tables = 0"
> >
> >
> > I'm happy to apply/run any debug patches to get more data that would help.
> >
> >>>
> >>> And we can fix that by having tlb_finish_mmu() sync up. Never let a
> >>> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> >>> have completed.
> >> Not sure if this will scale well.
> >>
> >>> This should not be too hard to make happen.
> >>
> 
> 

