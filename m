Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2DF6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:04:28 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so12366980pad.10
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 09:04:27 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id ay10si456429pdb.175.2014.07.22.09.04.26
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 09:04:27 -0700 (PDT)
Date: Tue, 22 Jul 2014 17:04:08 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140722160408.GM2219@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-4-git-send-email-lauraa@codeaurora.org>
 <20140718135349.GB4608@arm.com>
 <53CD6B1C.2010801@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD6B1C.2010801@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 21, 2014 at 08:33:48PM +0100, Laura Abbott wrote:
> On 7/18/2014 6:53 AM, Catalin Marinas wrote:
> > On Wed, Jul 02, 2014 at 07:03:36PM +0100, Laura Abbott wrote:
> >> +void *dma_common_pages_remap(struct page **pages, size_t size,
> >> +			unsigned long vm_flags, pgprot_t prot,
> >> +			const void *caller)
> >> +{
> >> +	struct vm_struct *area;
> >> +
> >> +	area = get_vm_area_caller(size, vm_flags, caller);
> >> +	if (!area)
> >> +		return NULL;
> >> +
> >> +	if (map_vm_area(area, prot, &pages)) {
> >> +		vunmap(area->addr);
> >> +		return NULL;
> >> +	}
> >> +
> >> +	return area->addr;
> >> +}
> > 
> > Why not just replace this function with vmap()? It is nearly identical.
> 
> With this version, the caller stored and printed via /proc/vmallocinfo
> is the actual caller of the DMA API whereas if we just call vmap we
> don't get any useful caller information. Going to vmap would change
> the existing behavior on ARM so it seems unwise to switch.

OK.

> Another option is to move this into vmalloc.c and add vmap_caller.

Maybe as a subsequent clean-up (once this series gets merged).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
