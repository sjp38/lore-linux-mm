Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C57906B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 11:17:07 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so13123468qge.8
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:17:07 -0700 (PDT)
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
        by mx.google.com with ESMTPS id l73si22628331qga.11.2014.06.03.08.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 08:17:07 -0700 (PDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so13332351qga.14
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 08:17:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5384DD67.3010408@intel.com>
References: <1401199802-10212-1-git-send-email-matt.fleming@intel.com>
	<5384DD67.3010408@intel.com>
Date: Tue, 3 Jun 2014 16:17:06 +0100
Message-ID: <CAL01qpvbDRnE0mHBttomcqYtT6i9OaG_kvnj6BMXtqYn4cP1FQ@mail.gmail.com>
Subject: Re: [PATCH] mm: bootmem: Check pfn_valid() before accessing struct page
From: "Fleming, Matt" <matt.fleming@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>

On 27 May 2014 19:45, Dave Hansen <dave.hansen@intel.com> wrote:
>
> I don't think this is quite right.  pfn_valid() tells us whether we have
> a 'struct page' there or not.  *BUT*, it does not tell us whether it is
> RAM that we can actually address and than can be freed in to the buddy
> allocator.
>
> I think sparsemem is where this matters.  Let's say mem= caused lowmem
> to end in the middle of a section (or that 896MB wasn't
> section-aligned).  Then someone calls free_bootmem_late() on an area
> that is in the last section, but _above_ max_mapnr.  It'll be
> pfn_valid(), we'll free it in to the buddy allocator, and we'll blam the
> first time we try to write to a bogus vaddr after a phys_to_virt().

Ah, the sparsemem case wasn't something I'd considered. Thanks Dave.

> At a higher level, I don't like the idea of the bootmem code papering
> over bugs when somebody calls in to it trying to _free_ stuff that's not
> memory (as far as the kernel is concerned).
>
> I think the right thing to do is to call in to the e820 code and see if
> the range is E820_RAM before trying to bootmem-free it.

OK, this makes sense. I'll try that approach and see if it also fixes
Alan's problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
