Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4D26B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 06:37:59 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id yl2so64901546pac.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 03:37:59 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id dt12si4366925pac.0.2016.05.04.03.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 03:37:58 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: kmap_atomic and preemption
Message-ID: <5729D0F4.9090907@synopsys.com>
Date: Wed, 4 May 2016 16:07:40 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Russell King <linux@arm.linux.org.uk>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hi,

I was staring at some recent ARC highmem crashes and see that kmap_atomic()
disables preemption even when page is in lowmem and call returns right away.
This seems to be true for other arches as well.

arch/arc/mm/highmem.c:

void *kmap_atomic(struct page *page)
{
	int idx, cpu_idx;
	unsigned long vaddr;

	preempt_disable();
	pagefault_disable();
	if (!PageHighMem(page))
		return page_address(page);

        /* do the highmem foo ... */
..
}

I would really like to implement a inline fastpath for !PageHighMem(page) case and
do the highmem foo out-of-line.

Is preemption disabling a requirement of kmap_atomic() callers independent of
where page is or is it only needed when page is in highmem and can trigger page
faults or TLB Misses between kmap_atomic() and kunmap_atomic and wants protection
against reschedules etc.

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
