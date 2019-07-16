Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD39C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90A9B2145D
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:02:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90A9B2145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C376B0003; Tue, 16 Jul 2019 08:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21B8E8E0003; Tue, 16 Jul 2019 08:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E4528E0001; Tue, 16 Jul 2019 08:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B55AE6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:02:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so15884835edt.4
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:02:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=LB9K00gYJHtJsUzaGd1myWoYwY4utnSt95G5BPCI3VI=;
        b=E/T24ES94io1mulNWH9JLOvcpacG9+V5rA+GcR0+TkqVD6Qw7zPBJELCQk1+oGvwJz
         16xybh5/IEdnjW4ZqTivhdYqXS/Q39azJfv6U6+wREiz8mm4VeZmWBV9RdYpUX3Zl6Nr
         kZTSLPGtoISMQxrlVhVq/qjMoZz9HrBjhPYRl+fA7v/f+zz5Ib5CrorVearibfVd2WMV
         6Vy9Te8z+fCYJFLXyiy+G7hps95XzmDUZ6Qh/Uhivp5FukyTeNri/AurevFrTpZtKnWn
         dyabCWTWRE93Tjvp2v1bFgflZjAV0zfpdudOEU4F3tCET941JPb+FnxGsp9n9LmAlAri
         R0uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVTvHP54nuDgJAieAf/3+Cowm+lu2n8ECH5OVrk9lEwDFgkK5sK
	FJEw5Q5bisr66BZ4U2kDvvCYbDmJHUNyHxpi9zUTjZ82lOcSuu4LuOp1uNoGyBd/Eniku+W5fTg
	hXkhgn/cvFYr8EO1wNpyZiEIyQeH88/s1mjTrH2jR4oCLzVZHRqz0QyFOGPhjOH560Q==
X-Received: by 2002:a17:906:190e:: with SMTP id a14mr13617297eje.69.1563278543922;
        Tue, 16 Jul 2019 05:02:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIeH/k6HTm6BlcD5qGWKouhn5J8HDeynFuRmgYZbKBZGG4P6jBGSLtgYMt86xYuFY/HNV0
X-Received: by 2002:a17:906:190e:: with SMTP id a14mr13617221eje.69.1563278542921;
        Tue, 16 Jul 2019 05:02:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563278542; cv=none;
        d=google.com; s=arc-20160816;
        b=DQbYjM+kJIHNYP8gWPRsy0DvdsJazeaDWmU7+I4C9WepikDdXcYYfGn39Hg5HRBTPl
         xFShRJ6hXHaxgre321NiGvr5R73TAhExCEqFpUKWf648GfXS1wposTBjqVYHU7uAMr1o
         ja9YEknXl7RylYcYnjW59f0FZoAqkPpex7qYZn6NcpQI/jILwheVEoJ9IKuapYRi4IkM
         aY8mKLX+osr1TwGFSSXYowVOQfIh3zsMpP8J2SMvsBcHI3GHDI9Y0gcP2kB0iCoxyDvm
         6GHfQRG7W3qewL/1gHPRkb+glPEpRKeWdk/2pjp/fYTpaPwtQbGTysXckM4M6f2bSNsF
         keUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject;
        bh=LB9K00gYJHtJsUzaGd1myWoYwY4utnSt95G5BPCI3VI=;
        b=Jp6x/chqSwA8DBIU0C3OuxlBnHBQOONiJVCZsenxwCblLiGpM7OuO6lqEA+fDi2LSY
         2ax9yocapgI91LjUqFJK/LLINkqqa02OoWk71zZXdindlQoHSNQaNDiKpuHaCKYOdATn
         qrqjMgd9nm2nVcpskeONrS2UehyHphN3WZ9H46G7NHITEi/UKAbkzPxFKsFsAPt8Vxde
         j5lm6TC6mB4ABaQHOTMz/GpmYi2Sqy/bMYz5kSsNNDBBJVxVPjyJTOZZkmB3Y164xClN
         HLLptnMAf8rnLQv/jQrRiDyPQAVrYoWx6hr6qVm3z+KJ9esoFMxY07sJtBeRq8BM92rW
         51bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q35si12738422eda.164.2019.07.16.05.02.22
        for <linux-mm@kvack.org>;
        Tue, 16 Jul 2019 05:02:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EA1762B;
	Tue, 16 Jul 2019 05:02:21 -0700 (PDT)
Received: from [10.1.197.57] (e110467-lin.cambridge.arm.com [10.1.197.57])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 80CF63F71A;
	Tue, 16 Jul 2019 05:02:20 -0700 (PDT)
Subject: Re: cma_remap when using dma_alloc_attr :- DMA_ATTR_NO_KERNEL_MAPPING
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
References: <CACDBo56EoKca9FJCnbztWZAARdUQs+B=dmCs+UxW27yHNu5pzQ@mail.gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 iommu@lists.linux-foundation.org, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@kernel.org>, pankaj.suryawanshi@einfochips.com,
 minchan@kernel.org, minchan.kim@gmail.com, Christoph Hellwig <hch@lst.de>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <57f8aa35-d460-9933-a547-fbf578ea42d3@arm.com>
Date: Tue, 16 Jul 2019 13:02:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CACDBo56EoKca9FJCnbztWZAARdUQs+B=dmCs+UxW27yHNu5pzQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/07/2019 19:30, Pankaj Suryawanshi wrote:
> Hello,
> 
> When we allocate cma memory using dma_alloc_attr using
> DMA_ATTR_NO_KERNEL_MAPPING attribute. It will return physical address
> without virtual mapping and thats the use case of this attribute. but lets
> say some vpu/gpu drivers required virtual mapping of some part of the
> allocation. then we dont have anything to remap that allocated memory to
> virtual memory. and in 32-bit system it difficult for devices like android
> to work all the time with virtual mapping, it degrade the performance.
> 
> For Example :
> 
> Lets say 4k video allocation required 300MB cma memory but not required
> virtual mapping for all the 300MB, its require only 20MB virtually mapped
> at some specific use case/point of video, and unmap virtual mapping after
> uses, at that time this functions will be useful, it works like ioremap()
> for cma_alloc() using dma apis.

Hmm, is there any significant reason that this case couldn't be handled 
with just get_vm_area() plus dma_mmap_attrs(). I know it's only 
*intended* for userspace mappings, but since the basic machinery is there...

Robin.

> /*
>           * function call(s) to create virtual map of given physical memory
>           * range [base, base+size) of CMA memory.
> */
> void *cma_remap(__u32 base, __u32 size)
> {
>          struct page *page = phys_to_page(base);
>          void *virt;
> 
>          pr_debug("cma: request to map 0x%08x for size 0x%08x\n",
>                          base, size);
> 
>          size = PAGE_ALIGN(size);
> 
>          pgprot_t prot = get_dma_pgprot(DMA_ATTR, PAGE_KERNEL);
> 
>          if (PageHighMem(page)){
>                  virt = dma_alloc_remap(page, size, GFP_KERNEL, prot,
> __builtin_return_address(0));
>          }
>          else
>          {
>                  dma_remap(page, size, prot);
>                  virt = page_address(page);
>          }
> 
>          if (!virt)
>                  pr_err("\x1b[31m" " cma: failed to map 0x%08x" "\x1b[0m\n",
>                                  base);
>          else
>                  pr_debug("cma: 0x%08x is virtually mapped to 0x%08x\n",
>                                  base, (__u32) virt);
> 
>          return virt;
> }
> 
> /*
>           * function call(s) to remove virtual map of given virtual memory
>           * range [virt, virt+size) of CMA memory.
> */
> 
> void cma_unmap(void *virt, __u32 size)
> {
>          size = PAGE_ALIGN(size);
>          unsigned long pfn = virt_to_pfn(virt);
>          struct page *page = pfn_to_page(pfn);
> 
>                  if (PageHighMem(page))
>                          dma_free_remap(virt, size);
>                  else
>                          dma_remap(page, size, PAGE_KERNEL);
> 
>          pr_debug(" cma: virtual address 0x%08x is unmapped\n",
>                          (__u32) virt);
> }
> 
> This functions should be added in arch/arm/mm/dma-mapping.c file.
> 
> Please let me know if i am missing anything.
> 
> Regards,
> Pankaj
> 

