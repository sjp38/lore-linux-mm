Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0F9C66B0036
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 03:43:31 -0400 (EDT)
Date: Sat, 29 Jun 2013 17:25:49 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 2/4] powerpc: Contiguous memory allocator based hash
 page allocation
Message-ID: <20130629072549.GC8687@iris.ozlabs.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1372410662-3748-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372410662-3748-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, linuxppc-dev@lists.ozlabs.org

On Fri, Jun 28, 2013 at 02:41:00PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Use CMA for allocation of guest hash page.

"page table" not just "page".  This patch description seems a bit
brief for a patch of this length.  Please describe a little more of
the motivation and the design decisions.

> +	if (selected_size) {
> +		pr_debug("%s: reserving %ld MiB for global area\n", __func__,
> +			 (unsigned long)selected_size / SZ_1M);
> +		align_size = hpt_align_pages << PAGE_SHIFT;
> +		kvm_cma_declare_contiguous(selected_size, align_size);

The alignment you declare here has to be at least as large as the
largest alignment that we will be requesting for any block later on.
This alignment is fine for POWER7, but PPC970 requires the HPT to be
aligned on a multiple of its size.  For PPC970 we should make sure
align_size is at least as large as any block that we could allocate.
Thus align_size should be at least __rounddown_pow_of_two(selected_size)
for PPC970.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
