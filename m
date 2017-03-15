Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDB26B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:42:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t143so23743145pgb.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:42:47 -0700 (PDT)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id m3si1598970pld.162.2017.03.15.02.42.46
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 02:42:46 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com> <1489568404-7817-3-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-3-git-send-email-aaron.lu@intel.com>
Subject: Re: [PATCH v2 2/5] mm: parallel free pages
Date: Wed, 15 Mar 2017 17:42:42 +0800
Message-ID: <0a2501d29d70$7eb0f530$7c12df90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Aaron Lu' <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@intel.com>, 'Tim Chen' <tim.c.chen@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Ying Huang' <ying.huang@intel.com>


On March 15, 2017 5:00 PM Aaron Lu wrote: 
>  void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
> +	struct batch_free_struct *batch_free, *n;
> +
s/*n/*next/

>  	tlb_flush_mmu(tlb);
> 
>  	/* keep the page table cache within bounds */
>  	check_pgt_cache();
> 
> +	list_for_each_entry_safe(batch_free, n, &tlb->worker_list, list) {
> +		flush_work(&batch_free->work);

Not sure, list_del before free?

> +		kfree(batch_free);
> +	}
> +
>  	tlb_flush_mmu_free_batches(tlb->local.next, true);
>  	tlb->local.next = NULL;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
