Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4857B6B0038
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 16:28:29 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so23987567pab.33
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 13:28:28 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ia9si6108907pbc.55.2014.08.26.13.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Aug 2014 13:28:27 -0700 (PDT)
Message-ID: <53FCEDEA.8080105@codeaurora.org>
Date: Tue, 26 Aug 2014 13:28:26 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [next:master 2145/2346] drivers/base/dma-mapping.c:311: undefined
 reference to `get_vm_area_caller'
References: <53fcfa84.nN6tIZ72fHAO0L0L%fengguang.wu@intel.com>
In-Reply-To: <53fcfa84.nN6tIZ72fHAO0L0L%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On 8/26/2014 2:22 PM, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   1c9e4561f3b2afffcda007eae9d0ddd25525f50e
> commit: fa44abcad042144651fa9cd0f698c7c40a59d60f [2145/2346] common: dma-mapping: introduce common remapping functions
> config: make ARCH=microblaze nommu_defconfig
> 
> All error/warnings:
> 
>    drivers/built-in.o: In function `dma_common_pages_remap':
>>> drivers/base/dma-mapping.c:311: undefined reference to `get_vm_area_caller'
>>> drivers/base/dma-mapping.c:315: undefined reference to `map_vm_area'
>    drivers/built-in.o: In function `dma_common_free_remap':
>>> drivers/base/dma-mapping.c:328: undefined reference to `find_vm_area'
> 
> vim +311 drivers/base/dma-mapping.c
> 
>    305	void *dma_common_pages_remap(struct page **pages, size_t size,
>    306				unsigned long vm_flags, pgprot_t prot,
>    307				const void *caller)
>    308	{
>    309		struct vm_struct *area;
>    310	
>  > 311		area = get_vm_area_caller(size, vm_flags, caller);
>    312		if (!area)
>    313			return NULL;
>    314	
>    315		if (map_vm_area(area, prot, pages)) {
>    316			vunmap(area->addr);
>    317			return NULL;
>    318		}
>    319	
>    320		return area->addr;
>    321	}
>    322	
>    323	/*
>    324	 * unmaps a range previously mapped by dma_common_*_remap
>    325	 */
>    326	void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags)
>    327	{
>    328		struct vm_struct *area = find_vm_area(cpu_addr);
>    329	
>    330		if (!area || (area->flags & vm_flags) != vm_flags) {
>    331			WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
> 

Based on top of my previous patch

----8<------
