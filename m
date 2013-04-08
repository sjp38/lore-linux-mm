Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0B5806B009D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:21:28 -0400 (EDT)
Message-ID: <51629A94.5000200@cn.fujitsu.com>
Date: Mon, 08 Apr 2013 18:23:16 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: vmemmap: x86: add vmemmap_verify check for hot-add
 node case
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com> <1365415000-10389-2-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1365415000-10389-2-git-send-email-linfeng@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, cl@linux.com
Cc: Lin Feng <linfeng@cn.fujitsu.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de, tony@atomide.com, ben@decadent.org.uk, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com

Hi all,

On 04/08/2013 05:56 PM, Lin Feng wrote:
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 474e28f..e2a7277 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1318,6 +1318,8 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
>  			if (!p)
>  				return -ENOMEM;
>  
> +			vmemmap_verify((pte_t *)p, node, addr, addr + PAGE_SIZE);
> +
>  			addr_end = addr + PAGE_SIZE;
>  			p_end = p + PAGE_SIZE;
>  		} else {
IIUC it seems that the original 'p_end = p + PAGE_SIZE' assignment is buggy, because:

1309                 if (!cpu_has_pse) {
1310                         next = (addr + PAGE_SIZE) & PAGE_MASK;
1311                         pmd = vmemmap_pmd_populate(pud, addr, node);
1312 
1313                         if (!pmd)
1314                                 return -ENOMEM;
1315 
1316                         p = vmemmap_pte_populate(pmd, addr, node);
1317 
1318                         if (!p)
1319                                 return -ENOMEM;
1320 
1321                         addr_end = addr + PAGE_SIZE;
1322                         p_end = p + PAGE_SIZE;

The return value of vmemmap_pte_populate() is the virtual address of pte, not the allocated
virtual address, which is different from vmemmap_alloc_block_buf() in cpu_has_pse case, so
the addition PAGE_SIZE in !cpu_has_pse case is nonsense.

Or am I missing something?

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
