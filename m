Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2B6D830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 18:50:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k186so6171294qkb.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:50:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g2si10821365ywg.191.2016.08.29.15.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 15:50:23 -0700 (PDT)
Date: Mon, 29 Aug 2016 15:50:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
Message-Id: <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
In-Reply-To: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On Mon, 29 Aug 2016 14:31:20 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> 
> The global zero page is used to satisfy an anonymous read fault. If
> THP(Transparent HugePage) is enabled then the global huge zero page is used.
> The global huge zero page uses an atomic counter for reference counting
> and is allocated/freed dynamically according to its counter value.
> 
> CPU time spent on that counter will greatly increase if there are
> a lot of processes doing anonymous read faults. This patch proposes a
> way to reduce the access to the global counter so that the CPU load
> can be reduced accordingly.
> 
> To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
> With this flag, the process only need to touch the global counter in
> two cases:
> 1 The first time it uses the global huge zero page;
> 2 The time when mm_user of its mm_struct reaches zero.
> 
> Note that right now, the huge zero page is eligible to be freed as soon
> as its last use goes away.  With this patch, the page will not be
> eligible to be freed until the exit of the last process from which it
> was ever used.
> 
> And with the use of mm_user, the kthread is not eligible to use huge
> zero page either. Since no kthread is using huge zero page today, there
> is no difference after applying this patch. But if that is not desired,
> I can change it to when mm_count reaches zero.

I suppose we could simply never free the zero huge page - if some
process has used it in the past, others will probably use it in the
future.  One wonders how useful this optimization is...

But the patch is simple enough.

> Case used for test on Haswell EP:
> usemem -n 72 --readonly -j 0x200000 100G
> Which spawns 72 processes and each will mmap 100G anonymous space and
> then do read only access to that space sequentially with a step of 2MB.
> 
> perf report for base commit:
>     54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
> perf report for this commit:
>      0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page

Does this mean that overall usemem runtime halved?

Do we have any numbers for something which is more real-wordly?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
