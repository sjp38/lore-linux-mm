Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C63006B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:33:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m5so12677225pgn.1
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:33:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z22si885934pll.211.2017.06.14.15.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:33:38 -0700 (PDT)
Subject: Re: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
References: <cover.1497415951.git.luto@kernel.org>
 <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cc8596e6-8c6c-eb0c-4d59-ee3b97fe881f@intel.com>
Date: Wed, 14 Jun 2017 15:33:36 -0700
MIME-Version: 1.0
In-Reply-To: <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
> -	if (cpumask_test_cpu(cpu, &batch->cpumask))
> +	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
> +		local_irq_disable();
>  		flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
> +		local_irq_enable();
> +	}
> +

Could you talk a little about why this needs to be local_irq_disable()
and not preempt_disable()?  Is it about the case where somebody is
trying to call flush_tlb_func_*() from an interrupt handler?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
