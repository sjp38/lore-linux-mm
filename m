Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86B6D6B026B
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 09:40:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z11-v6so5690133edq.17
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 06:40:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20-v6si610764edt.361.2018.07.02.06.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 06:40:44 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:40:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 2/5] mm: introduce VM_DEAD flag
Message-ID: <20180702134043.GW19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530311985-31251-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat 30-06-18 06:39:42, Yang Shi wrote:
> VM_DEAD flag is used to mark a vma is being unmapped, access to this
> area will trigger SIGSEGV.
> 
> This flag will be used by the optimization for unmapping large address
> space (>= 1GB) in the later patch. It is 64 bit only at the moment,
> since:
>   * we used up vm_flags bit for 32 bit
>   * 32 bit machine typically will not have such large mapping
> 
> All architectures, which support 64 bit, need check this flag in their
> page fault handler. This is implemented in later patches.

Please add a new flag with its users. There is simply no way to tell the
semantic from the above description and the patch as well.
 
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/mm.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9f..28a3906 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -242,6 +242,12 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
>  #endif
>  #endif /* CONFIG_ARCH_HAS_PKEYS */
>  
> +#ifdef CONFIG_64BIT
> +#define VM_DEAD			BIT(37)	/* bit only usable on 64 bit kernel */
> +#else
> +#define VM_DEAD			0
> +#endif
> +
>  #if defined(CONFIG_X86)
>  # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
>  #elif defined(CONFIG_PPC)
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
