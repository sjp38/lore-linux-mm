Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9660C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F14F2177B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F14F2177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47336B0003; Thu,  9 May 2019 17:06:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF8AD6B0006; Thu,  9 May 2019 17:06:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC0386B0007; Thu,  9 May 2019 17:06:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2026B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 17:06:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k15so3399603qki.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 14:06:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=Zle0EOxhkjIur0vZBNLm5bBmFk7EynbR0yS3T77Ek8k=;
        b=YFzvzj/xP73U+tIl/obiZ16Wwe5p8h+/1Nk6aJoI9yM0z9ZK0rZsUDRIVVMwrUIn7C
         dsxxIhj7yn8L+FkRA5vNlgiipGgQVImkzQ/WHZgkwjX/w3gFhsGBP/7Y9Sj7YM9em4ue
         BD9RkTnw/3JVBcobea/+zB6nKQ4nlUp5rtzeVy9lONI8GfYz6VVy4KjmVzDXEYuwaW76
         wBnPCFUYz/5uQxROEncAbEvVQkphDqNHOW1S7WVLjHL3tpRrkEEUSAFfsF5fWuOiAm8B
         yGyXOApXLWKc86iII5v11ybohMRnsWNU1IlIQyILOQ/Uo/aVOH47qhnjGGEC1DFYa2cL
         y9EQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV5N0N1Smx/Go2znfvmjwpnPE5q+pglDVq0SNH+dnBQfvOsqzIb
	N+a0biPRAWKgs/JCoKKq4fuKWAoH1vH1fIHi9hpP6mpLgACq0jPm60ftPcdzSUBEZAMFoi3Wo20
	MZKr6Hylj5KUVY3Pg6yy2PYmYt8cpZmUpkoHODDP2foPmXLQzkuDpNIch5UiWj6KqiA==
X-Received: by 2002:aed:2071:: with SMTP id 104mr6009311qta.223.1557436004260;
        Thu, 09 May 2019 14:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdUJxyF6eD2e8KjthR4KkRi7Wirgp7U1CqXNpf081uHPjpNI1uHvULwK5cccDuSqoGdBCJ
X-Received: by 2002:aed:2071:: with SMTP id 104mr6009248qta.223.1557436003389;
        Thu, 09 May 2019 14:06:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557436003; cv=none;
        d=google.com; s=arc-20160816;
        b=HWzq/zHg5TOQEPoELP4Z18c0hEpHJI9IheQpSlhK9IcDCeWPh0FNxW1LGdCgR0YsPJ
         c/3d6IjEO4PEva6v0J0HS1kbPvtYytC6v3/wxZKY5/vhrEy74Te5CwBb/mPAGG24hoVS
         s/sWCFwZ4gxQY4fQxDeNocyQwY/kJC6FlqfNqB2CfZ8VK6AM6tn3sXLFQ27jE8fA4XHy
         4gi1YhBnzrAazyv/XUCwhWjWUa0vcYHplSztObNR7ylYA8VrlyY6zAEp9/IHl4kzI/gq
         eT1TqlSOWaj7oqv0FG5j1cMGhE0VkTmBGu4Csp8dkI186vZhYS1ZDAcV7wjuV9Vzms/F
         49Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=Zle0EOxhkjIur0vZBNLm5bBmFk7EynbR0yS3T77Ek8k=;
        b=eodR64K6i68B9Vz/vfcYBkptFc+2f0fMjOK8f9CUE5dwZXa6wnzQHNsqILYLC6G8w+
         u8ELCA0fRGCdlMbILQLPtx86aTAOumwbceDjqGC5Hsn6uJgu8bTFoadB/hYoHUYjiJCa
         Mvlh19VEWDeo4XGuso+FlfWsv+CXMXL3W8pZ2bQsopcSX894WVK6epvGMA3+z75tjmg8
         /8siE9sJnivoqjBqup0yFbyzu8qfYbNy/LdUPXGiYDMIeTnLSFjmqF1J7TCPvjpZOqzX
         UP+PnF04RLF+0Hmf9eQa+GJpeuWvilPFGpV4wTtgqzfp1AEdWCf7CAFiq5atyPEGlTEY
         pg7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z31si2257011qtz.218.2019.05.09.14.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 14:06:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F1C718DF7C;
	Thu,  9 May 2019 21:06:42 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 290C460CCD;
	Thu,  9 May 2019 21:06:42 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id BFA7E18089C9;
	Thu,  9 May 2019 21:06:41 +0000 (UTC)
Date: Thu, 9 May 2019 17:06:38 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Yang Shi <yang.shi@linux.alibaba.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Nadav Amit <namit@vmware.com>, Will Deacon <will.deacon@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, npiggin@gmail.com, 
	minchan@kernel.org, Mel Gorman <mgorman@suse.de>, 
	Jan Stancek <jstancek@redhat.com>
Message-ID: <249230644.21949166.1557435998550.JavaMail.zimbra@redhat.com>
In-Reply-To: <84720bb8-bf3d-8c10-d675-0670f13b2efc@linux.alibaba.com>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com> <20190509083726.GA2209@brain-police> <20190509103813.GP2589@hirez.programming.kicks-ass.net> <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com> <20190509182435.GA2623@hirez.programming.kicks-ass.net> <84720bb8-bf3d-8c10-d675-0670f13b2efc@linux.alibaba.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.125, 10.4.195.2]
Thread-Topic: mmu_gather: remove __tlb_reset_range() for force flush
Thread-Index: lzhSy8AmrVc0ek4MkypS7izuJweOyw==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 09 May 2019 21:06:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


----- Original Message -----
> 
> 
> On 5/9/19 11:24 AM, Peter Zijlstra wrote:
> > On Thu, May 09, 2019 at 05:36:29PM +0000, Nadav Amit wrote:
> >>> On May 9, 2019, at 3:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> >>> index 99740e1dd273..fe768f8d612e 100644
> >>> --- a/mm/mmu_gather.c
> >>> +++ b/mm/mmu_gather.c
> >>> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >>> 		unsigned long start, unsigned long end)
> >>> {
> >>> 	/*
> >>> -	 * If there are parallel threads are doing PTE changes on same range
> >>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> >>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> >>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> >>> -	 * forcefully if we detect parallel PTE batching threads.
> >>> +	 * Sensible comment goes here..
> >>> 	 */
> >>> -	if (mm_tlb_flush_nested(tlb->mm)) {
> >>> -		__tlb_reset_range(tlb);
> >>> -		__tlb_adjust_range(tlb, start, end - start);
> >>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> >>> +		/*
> >>> +		 * Since we're can't tell what we actually should have
> >>> +		 * flushed flush everything in the given range.
> >>> +		 */
> >>> +		tlb->start = start;
> >>> +		tlb->end = end;
> >>> +		tlb->freed_tables = 1;
> >>> +		tlb->cleared_ptes = 1;
> >>> +		tlb->cleared_pmds = 1;
> >>> +		tlb->cleared_puds = 1;
> >>> +		tlb->cleared_p4ds = 1;
> >>> 	}
> >>>
> >>> 	tlb_flush_mmu(tlb);
> >> As a simple optimization, I think it is possible to hold multiple nesting
> >> counters in the mm, similar to tlb_flush_pending, for freed_tables,
> >> cleared_ptes, etc.
> >>
> >> The first time you set tlb->freed_tables, you also atomically increase
> >> mm->tlb_flush_freed_tables. Then, in tlb_flush_mmu(), you just use
> >> mm->tlb_flush_freed_tables instead of tlb->freed_tables.
> > That sounds fraught with races and expensive; I would much prefer to not
> > go there for this arguably rare case.
> >
> > Consider such fun cases as where CPU-0 sees and clears a PTE, CPU-1
> > races and doesn't see that PTE. Therefore CPU-0 sets and counts
> > cleared_ptes. Then if CPU-1 flushes while CPU-0 is still in mmu_gather,
> > it will see cleared_ptes count increased and flush that granularity,
> > OTOH if CPU-1 flushes after CPU-0 completes, it will not and potentiall
> > miss an invalidate it should have had.
> >
> > This whole concurrent mmu_gather stuff is horrible.
> >
> >    /me ponders more....
> >
> > So I think the fundamental race here is this:
> >
> > 	CPU-0				CPU-1
> >
> > 	tlb_gather_mmu(.start=1,	tlb_gather_mmu(.start=2,
> > 		       .end=3);			       .end=4);
> >
> > 	ptep_get_and_clear_full(2)
> > 	tlb_remove_tlb_entry(2);
> > 	__tlb_remove_page();
> > 					if (pte_present(2)) // nope
> >
> > 					tlb_finish_mmu();
> >
> > 					// continue without TLBI(2)
> > 					// whoopsie
> >
> > 	tlb_finish_mmu();
> > 	  tlb_flush()		->	TLBI(2)
> 
> I'm not quite sure if this is the case Jan really met. But, according to
> his test, once correct tlb->freed_tables and tlb->cleared_* are set, his
> test works well.

My theory was following sequence:

t1: map_write_unmap()                 t2: dummy()

  map_address = mmap()
  map_address[i] = 'b'
  munmap(map_address)
  downgrade_write(&mm->mmap_sem);
  unmap_region()
  tlb_gather_mmu()
    inc_tlb_flush_pending(tlb->mm);
  free_pgtables()
    tlb->freed_tables = 1
    tlb->cleared_pmds = 1

                                        pthread_exit()
                                        madvise(thread_stack, 8M, MADV_DONTNEED)
                                          zap_page_range()
                                            tlb_gather_mmu()
                                              inc_tlb_flush_pending(tlb->mm);

  tlb_finish_mmu()
    if (mm_tlb_flush_nested(tlb->mm))
      __tlb_reset_range()
        tlb->freed_tables = 0
        tlb->cleared_pmds = 0
    __flush_tlb_range(last_level = 0)
  ...
  map_address = mmap()
    map_address[i] = 'b'
      <page fault loop>
      # PTE appeared valid to me,
      # so I suspected stale TLB entry at higher level as result of "freed_tables = 0"


I'm happy to apply/run any debug patches to get more data that would help.

> 
> >
> >
> > And we can fix that by having tlb_finish_mmu() sync up. Never let a
> > concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> > have completed.
> 
> Not sure if this will scale well.
> 
> >
> > This should not be too hard to make happen.
> 
> 

