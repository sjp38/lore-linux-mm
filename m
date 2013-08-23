Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5D97E6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 13:17:39 -0400 (EDT)
Date: Fri, 23 Aug 2013 18:16:05 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] ARM64: Create 4K page size mmu memory map at init time
 will trigger exception.
Message-ID: <20130823171605.GH10971@arm.com>
References: <BFAC7FA8F7636E45AB9ECBAC17346F3434557683@SZXEML508-MBS.china.huawei.com>
 <20130822161614.GE1352@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130822161614.GE1352@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Leizhen (ThunderTown, Euler)" <thunder.leizhen@huawei.com>
Cc: Russell King <linux@arm.linux.org.uk>, "Liujiang (Gerry)" <jiang.liu@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Huxinwei <huxinwei@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lizefan <lizefan@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Aug 22, 2013 at 05:16:14PM +0100, Catalin Marinas wrote:
> On Thu, Aug 22, 2013 at 04:35:29AM +0100, Leizhen (ThunderTown, Euler) wrote:
> > This problem is on ARM64. When CONFIG_ARM64_64K_PAGES is not opened, the memory
> > map size can be 2M(section) and 4K(PAGE). First, OS will create map for pgd
> > (level 1 table) and level 2 table which in swapper_pg_dir. Then, OS register
> > mem block into memblock.memory according to memory node in fdt, like memory@0,
> > and create map in setup_arch-->paging_init. If all mem block start address and
> > size is integral multiple of 2M, there is no problem, because we will create 2M
> > section size map whose entries locate in level 2 table. But if it is not
> > integral multiple of 2M, we should create level 3 table, which granule is 4K.
> > Now, current implementtion is call early_alloc-->memblock_alloc to alloc memory
> > for level 3 table. This function will find a 4K free memory which locate in
> > memblock.memory tail(high address), but paging_init is create map from low
> > address to high address, so new alloced memory is not mapped, write page talbe
> > entry to it will trigger exception.
> 
> I see how this can happen. There is a memblock_set_current_limit to
> PGDIR_SIZE (1GB, we have a pre-allocated pmd) and in my tests I had at
> least 1GB of RAM which got mapped first and didn't have this problem.
> I'll come up with a patch tomorrow.

Could you please try this patch?

-------------------------8<---------------------------------------
