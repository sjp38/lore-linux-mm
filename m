Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77EFE6B78C3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 02:31:28 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so12796228pgi.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 23:31:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y6si20639125pgb.516.2018.12.05.23.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 23:31:27 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB67OPks025306
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 02:31:26 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p6wc154c9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:31:26 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 07:31:23 -0000
Date: Thu, 6 Dec 2018 09:31:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 2/6] microblaze: prefer memblock API returning virtual
 address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-3-git-send-email-rppt@linux.ibm.com>
 <0a5e0aef-15fd-2d0c-765c-e7ba60219b00@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a5e0aef-15fd-2d0c-765c-e7ba60219b00@monstr.eu>
Message-Id: <20181206073111.GH19181@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Michal Simek <michal.simek@xilinx.com>

On Wed, Dec 05, 2018 at 04:29:40PM +0100, Michal Simek wrote:
> On 03. 12. 18 16:47, Mike Rapoport wrote:
> > Rather than use the memblock_alloc_base that returns a physical address and
> > then convert this address to the virtual one, use appropriate memblock
> > function that returns a virtual address.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  arch/microblaze/mm/init.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> > index b17fd8a..44f4b89 100644
> > --- a/arch/microblaze/mm/init.c
> > +++ b/arch/microblaze/mm/init.c
> > @@ -363,8 +363,9 @@ void __init *early_get_page(void)
> >  	 * Mem start + kernel_tlb -> here is limit
> >  	 * because of mem mapping from head.S
> >  	 */
> > -	return __va(memblock_alloc_base(PAGE_SIZE, PAGE_SIZE,
> > -				memory_start + kernel_tlb));
> > +	return memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
> > +				MEMBLOCK_LOW_LIMIT, memory_start + kernel_tlb,
> > +				NUMA_NO_NODE);
> >  }
> >  
> >  #endif /* CONFIG_MMU */
> > 
> 
> I can't see any issue with functionality when this patch is applied.
> If you want me to take this via my tree please let me know.

I thought to route this via mmotm tree.

> Otherwise:
> 
> Tested-by: Michal Simek <michal.simek@xilinx.com>

Thanks!

 
> Thanks,
> Michal
> 
> -- 
> Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel - Xilinx Microblaze
> Maintainer of Linux kernel - Xilinx Zynq ARM and ZynqMP ARM64 SoCs
> U-Boot custodian - Xilinx Microblaze/Zynq/ZynqMP/Versal SoCs
> 
> 




-- 
Sincerely yours,
Mike.
