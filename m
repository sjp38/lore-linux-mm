Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A32699003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:27:08 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so40167476wic.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:27:08 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id m7si18818877wix.86.2015.07.21.05.27.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 05:27:07 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so119110291wib.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:27:06 -0700 (PDT)
Date: Tue, 21 Jul 2015 14:27:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: trace tlb flush after disabling preemption in
 try_to_unmap_flush
Message-ID: <20150721122704.GL11967@dhcp22.suse.cz>
References: <1437075339-32715-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437075339-32715-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-07-15 15:35:39, Sasha Levin wrote:
> Commit "mm: send one IPI per CPU to TLB flush all entries after unmapping
> pages" added a trace_tlb_flush() while preemption was still enabled. This
> means that we'll access smp_processor_id() which in turn will get us quite
> a few warnings.
> 
> Fix it by moving the trace to where the preemption is disabled, one line
> down.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Reviewed-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> The diff is all lies: I've moved trace_tlb_flush() one line down rather
> than get_cpu() a line up ;)
> 
>  mm/rmap.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 30812e9..63ba46c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -613,9 +613,10 @@ void try_to_unmap_flush(void)
>  	if (!tlb_ubc->flush_required)
>  		return;
>  
> +	cpu = get_cpu();
> +
>  	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, -1UL);
>  
> -	cpu = get_cpu();
>  	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
>  		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
>  
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
