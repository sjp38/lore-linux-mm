Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 686C96B0075
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 15:03:44 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so29717130pdb.2
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 12:03:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z2si6463478pdj.39.2015.06.12.12.03.43
        for <linux-mm@kvack.org>;
        Fri, 12 Jun 2015 12:03:43 -0700 (PDT)
Date: Fri, 12 Jun 2015 12:03:35 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
Message-ID: <20150612190335.GA21994@agluck-desk.sc.intel.com>
References: <55704A7E.5030507@huawei.com>
 <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 12, 2015 at 08:42:33AM +0000, Naoya Horiguchi wrote:
> 4?) I don't have the whole picture of how address ranging mirroring works,
> but I'm curious about what happens when an uncorrected memory error happens
> on the a mirror page. If HW/FW do some useful work invisible from kernel,
> please document it somewhere. And my questions are:
>  - can the kernel with this patchset really continue its operation without
>    breaking consistency? More specifically, the corrupted page is replaced with
>    its mirror page, but can any other pages which have references (like struct
>    page or pfn) for the corrupted page properly switch these references to the
>    mirror page? Or no worry about that?  (This is difficult for kernel pages
>    like slab, and that's why currently hwpoison doesn't handle any kernel pages.)

The mirror is operated by h/w (perhaps with some platform firmware
intervention when things start breaking badly).

In normal operation there are two DIMM addresses backing each
system physical address in the mirrored range (thus total system
memory capacity is reduced when mirror is enabled).  Memory writes
are directed to both locations. Memory reads are interleaved to
maintain bandwidth, so could come from either address.

When a read returns with an ECC failure the h/w automatically:
 1) Re-issues the read to the other DIMM address. If that also fails - then
    we do the normal machine check processing for an uncorrected error
 2) But if the other side of the mirror is good, we can send the good
    data to the reader (cpu, or dma) and, in parallel try to fix the
    bad side by writing the good data to it.
 3) A corrected error will be logged, it may indicate whether the
    attempt to fix succeeded or not.
 4) If platform firmware wants, it can be notified of the correction
    and it may keep statistics on the rate of errors, correction status,
    etc.  If things get very bad it may "break" the mirror and direct
    all future reads to the remaining "good" side. If does this it will
    likely tell the OS via some ACPI method.

All of this is done at much less than page granularity. Cache coherence
is maintained ... apart from some small performance glitches and the corrected
error logs, the OS is unware of all of this.

Note that in current implementations the mirror copies are both behind
the same memory controller ... so this isn't intended to cope with high
level failure of a memory controller ... just to deal with randomly
distributed ECC errors.

>  - How can we test/confirm that the whole scheme works fine?  Is current memory
>    error injection framework enough?

Still working on that piece. To validate you need to be able to
inject errors to just one side of the mirror, and I'm not really
sure that the ACPI/EINJ interface is up to the task.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
