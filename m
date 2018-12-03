Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B32E6B69E3
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:11:08 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id d24so1555796lfa.23
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:11:08 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id 9-v6si11225242ljo.136.2018.12.03.08.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:11:06 -0800 (PST)
Date: Mon, 3 Dec 2018 17:10:52 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2 3/6] sh: prefer memblock APIs returning virtual address
Message-ID: <20181203161052.GA4244@ravnborg.org>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-4-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543852035-26634-4-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

Hi Mike.

On Mon, Dec 03, 2018 at 05:47:12PM +0200, Mike Rapoport wrote:
> Rather than use the memblock_alloc_base that returns a physical address and
> then convert this address to the virtual one, use appropriate memblock
> function that returns a virtual address.
> 
> There is a small functional change in the allocation of then NODE_DATA().
> Instead of panicing if the local allocation failed, the non-local
> allocation attempt will be made.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/sh/mm/init.c | 18 +++++-------------
>  arch/sh/mm/numa.c |  5 ++---
>  2 files changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index c8c13c77..3576b5f 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -192,24 +192,16 @@ void __init page_table_range_init(unsigned long start, unsigned long end,
>  void __init allocate_pgdat(unsigned int nid)
>  {
>  	unsigned long start_pfn, end_pfn;
> -#ifdef CONFIG_NEED_MULTIPLE_NODES
> -	unsigned long phys;
> -#endif
>  
>  	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
>  
>  #ifdef CONFIG_NEED_MULTIPLE_NODES
> -	phys = __memblock_alloc_base(sizeof(struct pglist_data),
> -				SMP_CACHE_BYTES, end_pfn << PAGE_SHIFT);
> -	/* Retry with all of system memory */
> -	if (!phys)
> -		phys = __memblock_alloc_base(sizeof(struct pglist_data),
> -					SMP_CACHE_BYTES, memblock_end_of_DRAM());
> -	if (!phys)
> +	NODE_DATA(nid) = memblock_alloc_try_nid_nopanic(
> +				sizeof(struct pglist_data),
> +				SMP_CACHE_BYTES, MEMBLOCK_LOW_LIMIT,
> +				MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> +	if (!NODE_DATA(nid))
>  		panic("Can't allocate pgdat for node %d\n", nid);
> -
> -	NODE_DATA(nid) = __va(phys);
> -	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
The new code will always assign NODE_DATA(nid), where the old
code only assigned NODE_DATA(nid) in the good case.
I dunno if this is an issue, just noticed the difference and
wanted to point it out.

	Sam
