Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED056B02FD
	for <linux-mm@kvack.org>; Mon, 29 May 2017 19:49:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a9so6214559qkb.4
        for <linux-mm@kvack.org>; Mon, 29 May 2017 16:49:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p57si11325710qta.203.2017.05.29.16.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 16:49:25 -0700 (PDT)
Message-ID: <1496101762.29205.75.camel@redhat.com>
Subject: Re: [PATCH v4 3/8] x86/mm: Refactor flush_tlb_mm_range() to merge
 local and remote cases
From: Rik van Riel <riel@redhat.com>
Date: Mon, 29 May 2017 19:49:22 -0400
In-Reply-To: <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
	 <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:

> +
> +	if (mm == current->active_mm)
> +		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> +	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> A 		flush_tlb_others(mm_cpumask(mm), &info);

What excludes "cpu" from the cpumask before calling
(native_)flush_tlb_others?

Otherwise smp_call_function_many will simply call
flush_tbl_func_remote for the local CPU as well, and
you get local CPU TLB flushing overhead twice.

What am I missing?

> -	preempt_enable();
> +	put_cpu();
> A }
> A 
> A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
