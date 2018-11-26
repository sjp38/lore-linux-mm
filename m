Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7C546B40D8
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:26:01 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so21021803plr.8
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:26:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1-v6si41673484plg.274.2018.11.25.23.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 23:26:00 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAQ7NqiE127740
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:26:00 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p0ba32ght-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:25:59 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 26 Nov 2018 07:25:57 -0000
Date: Mon, 26 Nov 2018 09:25:46 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 5/5] arch: simplify several early memory allocations
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
 <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
 <7a92357c-6251-fe84-d724-16fdc49d03a3@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7a92357c-6251-fe84-d724-16fdc49d03a3@c-s.fr>
Message-Id: <20181126072546.GB14863@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-sh@vger.kernel.org, linux-mm@kvack.org, Rich Felker <dalias@libc.org>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Vincent Chen <deanbo422@gmail.com>, Jonas Bonn <jonas@southpole.se>, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Russell King <linux@armlinux.org.uk>, Mark Salter <msalter@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Mon, Nov 26, 2018 at 08:03:55AM +0100, Christophe LEROY wrote:
> 
> 
> Le 25/11/2018 � 22:44, Mike Rapoport a �crit�:
> >There are several early memory allocations in arch/ code that use
> >memblock_phys_alloc() to allocate memory, convert the returned physical
> >address to the virtual address and then set the allocated memory to zero.
> >
> >Exactly the same behaviour can be achieved simply by calling
> >memblock_alloc(): it allocates the memory in the same way as
> >memblock_phys_alloc(), then it performs the phys_to_virt() conversion and
> >clears the allocated memory.
> >
> >Replace the longer sequence with a simpler call to memblock_alloc().
> >
> >Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >---
> >  arch/arm/mm/mmu.c                     |  4 +---
> >  arch/c6x/mm/dma-coherent.c            |  9 ++-------
> >  arch/nds32/mm/init.c                  | 12 ++++--------
> >  arch/powerpc/kernel/setup-common.c    |  4 ++--
> >  arch/powerpc/mm/pgtable_32.c          |  4 +---
> >  arch/powerpc/mm/ppc_mmu_32.c          |  3 +--
> >  arch/powerpc/platforms/powernv/opal.c |  3 +--
> >  arch/sparc/kernel/prom_64.c           |  7 ++-----
> >  arch/sparc/mm/init_64.c               |  9 +++------
> >  arch/unicore32/mm/mmu.c               |  4 +---
> >  10 files changed, 18 insertions(+), 41 deletions(-)
> >
> [...]
> 
> >diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
> >index bda3c6f..9931e68 100644
> >--- a/arch/powerpc/mm/pgtable_32.c
> >+++ b/arch/powerpc/mm/pgtable_32.c
> >@@ -50,9 +50,7 @@ __ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
> >  	if (slab_is_available()) {
> >  		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
> >  	} else {
> >-		pte = __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
> >-		if (pte)
> >-			clear_page(pte);
> >+		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> 
> memblock_alloc() uses memset to zeroize the block.
> 
> clear_page() is more performant than memset().

As far as I can tell, the majority of the page table pages will be anyway
allocated with __get_free_page() so I think the performance loss here will
negligible.
 
> Christophe
> 
> [...]
> 

-- 
Sincerely yours,
Mike.
