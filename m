Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 867846B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 04:45:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v17-v6so1424934wmc.0
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:45:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 101-v6si8736247wrk.266.2018.07.02.01.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 01:45:13 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w628iIiO115931
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 04:45:12 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jygdhh1w6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:45:11 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 2 Jul 2018 09:45:10 +0100
Subject: Re: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 2 Jul 2018 10:45:03 +0200
MIME-Version: 1.0
In-Reply-To: <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 30/06/2018 00:39, Yang Shi wrote:
> Check VM_DEAD flag of vma in page fault handler, if it is set, trigger
> SIGSEGV.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  arch/x86/mm/fault.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 9a84a0d..3fd2da5 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1357,6 +1357,10 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
>  		bad_area(regs, error_code, address);
>  		return;
>  	}
> +	if (unlikely(vma->vm_flags & VM_DEAD)) {
> +		bad_area(regs, error_code, address);
> +		return;
> +	}

This will have to be done for all the supported architectures, what about doing
this check in handle_mm_fault() and return VM_FAULT_SIGSEGV ?

>  	if (error_code & X86_PF_USER) {
>  		/*
>  		 * Accessing the stack below %sp is always a bug.
> 
