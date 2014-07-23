Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 15BE76B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:16:20 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1517270pad.25
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:16:19 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id oq8si2157273pab.231.2014.07.23.04.16.18
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 04:16:19 -0700 (PDT)
Date: Wed, 23 Jul 2014 12:16:09 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140723111608.GC1366@localhost>
References: <1406079308-5232-1-git-send-email-lauraa@codeaurora.org>
 <1406079308-5232-4-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406079308-5232-4-git-send-email-lauraa@codeaurora.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Wed, Jul 23, 2014 at 02:35:06AM +0100, Laura Abbott wrote:
> +void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags)
> +{
> +	struct vm_struct *area = find_vm_area(cpu_addr);
> +
> +	if (!area || (area->flags & vm_flags) != vm_flags) {
> +		WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
> +		return;
> +	}
> +
> +	unmap_kernel_range((unsigned long)cpu_addr, size);
> +	vunmap(cpu_addr);
> +}

One more thing - is unmap_kernel_range() needed here? vunmap() ends up
calling vunmap_page_range(), same as unmap_kernel_range(). I think one
difference is that in the vunmap case, TLB flushing is done lazily.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
