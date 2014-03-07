Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id CF51F6B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 19:16:24 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id i11so3441884oag.34
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:16:24 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id f4si4083019oel.144.2014.03.06.16.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 16:16:24 -0800 (PST)
Message-ID: <1394151380.2555.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 1/7] x86: mm: clean up tlb flushing code
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 06 Mar 2014 16:16:20 -0800
In-Reply-To: <20140306004521.5D13DC05@viggo.jf.intel.com>
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>
	 <20140306004521.5D13DC05@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The
> 
> 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
> 
> line of code is not exactly the easiest to audit, especially when
> it ends up at two different indentation levels.  This eliminates
> one of the the copy-n-paste versions.  It also gives us a unified
> exit point for each path through this function.  We need this in
> a minute for our tracepoint.
> 
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/arch/x86/mm/tlb.c |   23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff -puN arch/x86/mm/tlb.c~simplify-tlb-code arch/x86/mm/tlb.c
> --- a/arch/x86/mm/tlb.c~simplify-tlb-code	2014-03-05 16:10:09.607047728 -0800
> +++ b/arch/x86/mm/tlb.c	2014-03-05 16:10:09.610047866 -0800
> @@ -161,23 +161,24 @@ void flush_tlb_current_task(void)
>  void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  				unsigned long end, unsigned long vmflag)
>  {
> +	int need_flush_others_all = 1;

nit: this can be bool.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
