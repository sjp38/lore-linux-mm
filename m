Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C16C66B4A92
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:16:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d6-v6so15020030pfn.19
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:16:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d71sor6755346pga.73.2018.11.27.13.16.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 13:16:03 -0800 (PST)
Date: Wed, 28 Nov 2018 06:16:00 +0900
From: Stafford Horne <shorne@gmail.com>
Subject: Re: [PATCH 4/5] openrisc: simplify pte_alloc_one_kernel()
Message-ID: <20181127211600.GB3235@lianli.shorne-pla.net>
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
 <1543182277-8819-5-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543182277-8819-5-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Sun, Nov 25, 2018 at 11:44:36PM +0200, Mike Rapoport wrote:
> The pte_alloc_one_kernel() function allocates a page using
> __get_free_page(GFP_KERNEL) when mm initialization is complete and
> memblock_phys_alloc() on the earlier stages. The physical address of the
> page allocated with memblock_phys_alloc() is converted to the virtual
> address and in the both cases the allocated page is cleared using
> clear_page().
> 
> The code is simplified by replacing __get_free_page() with
> get_zeroed_page() and by replacing memblock_phys_alloc() with
> memblock_alloc().

Hello Mike,

This looks fine to me.  How do you plan to get this merged?  Will you be taking
care of the whole series or so you want me to queue this openrisc part?

> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: Stafford Horne <shorne@gmail.com>

> ---
>  arch/openrisc/mm/ioremap.c | 11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
> index c969752..cfef989 100644
> --- a/arch/openrisc/mm/ioremap.c
> +++ b/arch/openrisc/mm/ioremap.c
> @@ -123,13 +123,10 @@ pte_t __ref *pte_alloc_one_kernel(struct mm_struct *mm,
>  {
>  	pte_t *pte;
>  
> -	if (likely(mem_init_done)) {
> -		pte = (pte_t *) __get_free_page(GFP_KERNEL);
> -	} else {
> -		pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
> -	}
> +	if (likely(mem_init_done))
> +		pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
> +	else
> +		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>  
> -	if (pte)
> -		clear_page(pte);
>  	return pte;
>  }
> -- 
> 2.7.4
> 
