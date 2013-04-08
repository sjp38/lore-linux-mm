Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E161D6B00A0
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:56:37 -0400 (EDT)
Date: Mon, 8 Apr 2013 11:55:57 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] mm: vmemmap: arm64: add vmemmap_verify check for
 hot-add node case
Message-ID: <20130408105556.GB17476@mudshark.cambridge.arm.com>
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
 <1365415000-10389-3-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365415000-10389-3-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "cl@linux.com" <cl@linux.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "yinghai@kernel.org" <yinghai@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "arnd@arndb.de" <arnd@arndb.de>, "tony@atomide.com" <tony@atomide.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>

Hello,

On Mon, Apr 08, 2013 at 10:56:40AM +0100, Lin Feng wrote:
> In hot add node(memory) case, vmemmap pages are always allocated from other
> node, but the current logic just skip vmemmap_verify check. 
> So we should also issue "potential offnode page_structs" warning messages
> if we are the case.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  arch/arm64/mm/mmu.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 70b8cd4..9f1e417 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -427,8 +427,8 @@ int __meminit vmemmap_populate(struct page *start_page,
>  				return -ENOMEM;
>  
>  			set_pmd(pmd, __pmd(__pa(p) | prot_sect_kernel));
> -		} else
> -			vmemmap_verify((pte_t *)pmd, node, addr, next);
> +		}
> +		vmemmap_verify((pte_t *)pmd, node, addr, next);
>  	} while (addr = next, addr != end);
>  
>  	return 0;

Given that we don't have NUMA support or memory-hotplug on arm64 yet, I'm
not sure that this change makes much sense at the moment. early_pfn_to_nid
will always return 0 and we only ever have one node.

To be honest, I'm not sure what that vmemmap_verify check is trying to
achieve anyway. ia64 does some funky node affinity initialisation early on
but, for the rest of us, it looks like we always just check the distance
from node 0.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
