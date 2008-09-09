Date: Tue, 9 Sep 2008 06:08:21 -0700 (PDT)
From: David Anders <dave123_aml@yahoo.com>
Reply-To: dave123_aml@yahoo.com
Subject: Re: Remove warning in compilation of ioremap
In-Reply-To: <48C63E28.6060605@evidence.eu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <78442.11257.qm@web54403.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arm-kernel@lists.arm.linux.org.uk, Claudio Scordino <claudio@evidence.eu.com>
Cc: linux-mm@kvack.org, Phil Blundell <philb@gnu.org>, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
List-ID: <linux-mm.kvack.org>

Claudio,

i hope you have a better time getting this fixed than i have, i've been submitting patches as far back as 2.6.16:

http://lists.arm.linux.org.uk/lurker/message/20070906.135142.6c5e4d6f.en.html
http://lists.arm.linux.org.uk/lurker/message/20070906.140649.79f143a0.en.html

2.6.23 was when i gave up.

Dave Anders




--- On Tue, 9/9/08, Claudio Scordino <claudio@evidence.eu.com> wrote:

> From: Claudio Scordino <claudio@evidence.eu.com>
> Subject: Remove warning in compilation of ioremap
> To: linux-arm-kernel@lists.arm.linux.org.uk
> Cc: linux-mm@kvack.org, "Phil Blundell" <philb@gnu.org>, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
> Date: Tuesday, September 9, 2008, 4:13 AM
> Hi all.
> 
> [We already discussed this issue in linux-mm ML, but people
> suggested 
> to post to linux-arm-kernel...]
> 
> When compiling Linux (latest kernel from Linus' git) on
> ARM, I noticed
> the following warning:
> 
> CC      arch/arm/mm/ioremap.o
> arch/arm/mm/ioremap.c: In function
> '__arm_ioremap_pfn':
> arch/arm/mm/ioremap.c:83: warning: control may reach end of
> non-void
> function 'remap_area_pte' being inlined
> 
> If you look at the code, the problem is in a path including
> a BUG().
> 
> AFAIK, on ARM the code following BUG() is never executed:
> it's a NULL
> pointer dereference, so the handler of pagefault eventually
> calls
> do_exit(). Therefore, we may want to remove the goto as
> shown in the
> patch in attachment.
> 
> It's obviously a minor issue. But I don't like
> having meaningless
> warnings during compilation: they just confuse output, and
> developers 
> may miss some important warning message...
> 
> The need for the goto exists only if BUG() can return. If
> it doesn't,
> we can safely remove it as shown in the patch.
> 
> Is this possible ? Should we update this piece of code ?
> Who's in
> charge of maintaining it ?
> 
> Many thanks,
> 
>            Claudio
> 
> 
> 
> 
> 
> >From 08d2e6f14230bf2252c54f5421d92def5e70f6dc Mon Sep
> 17 00:00:00 2001
> From: Claudio Scordino <claudio@evidence.eu.com>
> Date: Mon, 8 Sep 2008 16:03:38 +0200
> Subject: [PATCH 1/1] Fix compilation warning in
> remap_area_pte
> 
> 
> Signed-off-by: Claudio Scordino
> <claudio@evidence.eu.com>
> ---
>  arch/arm/mm/ioremap.c |   11 ++++-------
>  1 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
> index b81dbf9..bc6eca0 100644
> --- a/arch/arm/mm/ioremap.c
> +++ b/arch/arm/mm/ioremap.c
> @@ -52,18 +52,15 @@ static int remap_area_pte(pmd_t *pmd,
> unsigned long addr, unsigned long end,
>  		return -ENOMEM;
>  
>  	do {
> -		if (!pte_none(*pte))
> -			goto bad;
> -
> +		if (unlikely(!pte_none(*pte))){
> +			printk(KERN_CRIT "%s: page already
> exists\n", __FUNCTION__);
> +			BUG();
> +		}
>  		set_pte_ext(pte, pfn_pte(phys_addr >> PAGE_SHIFT,
> prot),
>  			    type->prot_pte_ext);
>  		phys_addr += PAGE_SIZE;
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	return 0;
> -
> - bad:
> -	printk(KERN_CRIT "remap_area_pte: page already
> exists\n");
> -	BUG();
>  }
>  
>  static inline int remap_area_pmd(pgd_t *pgd, unsigned long
> addr,
> -- 
> 1.5.4.3
> 
> 
> 
> -------------------------------------------------------------------
> List admin:
> http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
> FAQ:       
> http://www.arm.linux.org.uk/mailinglists/faq.php
> Etiquette: 
> http://www.arm.linux.org.uk/mailinglists/etiquette.php


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
