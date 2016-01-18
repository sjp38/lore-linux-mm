Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED1B6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:07:03 -0500 (EST)
Received: by mail-qk0-f173.google.com with SMTP id o6so10423916qkc.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:07:03 -0800 (PST)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id a8si30492815qkj.103.2016.01.18.03.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 03:07:02 -0800 (PST)
Date: Mon, 18 Jan 2016 06:06:22 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <969916137.9009700.1453115182823.JavaMail.zimbra@redhat.com>
In-Reply-To: <1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] Fix: PowerNV crash with 4.4.0-rc8 at sched_init_numa
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: mingo@redhat.com, peterz@infradead.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, gkurz@linux.vnet.ibm.com, grant likely <grant.likely@linaro.org>, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org





----- Original Message -----
> From: "Raghavendra K T" <raghavendra.kt@linux.vnet.ibm.com>
> To: mingo@redhat.com, peterz@infradead.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
> anton@samba.org, akpm@linux-foundation.org
> Cc: jstancek@redhat.com, gkurz@linux.vnet.ibm.com, "grant likely" <grant.likely@linaro.org>,
> nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, "raghavendra kt" <raghavendra.kt@linux.vnet.ibm.com>,
> linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
> Sent: Friday, 15 January, 2016 8:01:23 PM
> Subject: [PATCH] Fix: PowerNV crash with 4.4.0-rc8 at sched_init_numa
> 
> Commit c118baf80256 ("arch/powerpc/mm/numa.c: do not allocate bootmem
> memory for non existing nodes") avoided bootmem memory allocation for
> non existent nodes.
> 
> When DEBUG_PER_CPU_MAPS enabled, powerNV system failed to boot because
> in sched_init_numa, cpumask_or operation was done on unallocated nodes.
> Fix that by making cpumask_or operation only on existing nodes.
> 
> [ Tested with and w/o DEBUG_PER_CPU_MAPS on x86 and powerpc ]
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>

Tested-by: Jan Stancek <jstancek@redhat.com>

I also verified with my setup, that this made the crash go away.
Report mail thread for reference:
  https://lists.ozlabs.org/pipermail/linuxppc-dev/2016-January/137691.html

Regards,
Jan

> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  kernel/sched/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 44253ad..474658b 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -6840,7 +6840,7 @@ static void sched_init_numa(void)
>  
>  			sched_domains_numa_masks[i][j] = mask;
>  
> -			for (k = 0; k < nr_node_ids; k++) {
> +			for_each_node(k) {
>  				if (node_distance(j, k) > sched_domains_numa_distance[i])
>  					continue;
>  
> --
> 1.7.11.7
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
