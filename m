Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0286F6B02C6
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 15:02:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f23so16357737qkh.21
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:02:24 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id n125si10277684qkd.262.2017.04.21.12.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 12:02:24 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id y63so48943141qkd.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:02:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN_72e3WpZXP3kGPeWjEpsfigGjnURLFTVsUf_P7ozzT8cN+bA@mail.gmail.com>
References: <CAN_72e3WpZXP3kGPeWjEpsfigGjnURLFTVsUf_P7ozzT8cN+bA@mail.gmail.com>
From: Pavel Roskin <plroskin@gmail.com>
Date: Fri, 21 Apr 2017 12:02:23 -0700
Message-ID: <CAN_72e2fz+XKb7cuKhiit6rwzRDSN89ODvTT8MZjeuQF8RDdtw@mail.gmail.com>
Subject: Re: Allocating mock memory resources
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello

On Sat, Apr 15, 2017 at 11:31 PM, Pavel Roskin <plroskin@gmail.com> wrote:

> I'm working on a device driver for hardware that is being developed.
> I'm coding against the specification and hoping for the best. It would
> be very handy to have a mock implementation of the hardware so I could
> test the driver against it. In the end, it would be an integration
> test for the driver, which could be useful even after the hardware
> arrives. For example, I could emulate hardware failures and see how
> the driver reacts. Moreover, a driver test framework would be useful
> for others.
>
> One issue I'm facing is creating resources for the device. Luckily,
> the driver only needs memory resources. It should be simple to
> allocate such resources in system RAM, but I could not find a good way
> to do it. Either the resource allocation fails, or the kernel panics
> right away, or it panics when I run "cat /proc/iomem"

In case anybody cares, here's my working solution.

The RAM resource is needed because request_region() cannot traverse
busy RAM region, but request_resource() doesn't check if any resources
are busy. I don't like iterating over resources in a driver, but I
don't know a better approach. I assume that all system RAM resources
are direct children of iomem_resource.

SetPageReserved() is needed to allow ioremap() on the region (by the
way, CamelCase in the kernel code looks so weird).

I'm surprised there is no universal phys_to_page() macro, so I'm using
virtual addresses to iterate over pages.

The only limitation on the driver under test is that it should not be
using request_region() on iomem_resource, as the RAM resource is busy
and cannot be traversed.


static struct resource *fff_get_ram_resource(struct resource *res)
{
    resource_size_t start = res->start;
    resource_size_t end = res->end;
    struct resource *p;

    for (p = iomem_resource.child; p && p->start <= end; p = p->sibling) {
        if (p->end >= start)
            return p;
    }

    return NULL;
}

static int __init fff_emu_alloc_resources(void)
{
    struct page *pg;
    char *pg_base, *p;
    struct resource *ram_res;
    int ret;

    pg = alloc_pages(GFP_KERNEL | __GFP_ZERO, get_order(EMU_MEM_SIZE));
    if (!pg) {
        pr_err("Cannot allocate memory for emulator resource\n");
        return -ENOMEM;
    }

    pg_base = page_to_virt(pg);

    emu_mem.start = page_to_phys(pg);
    emu_mem.end = emu_mem.start + EMU_MEM_SIZE - 1;

    ram_res = fff_get_ram_resource(&emu_mem);
    if (!ram_res) {
        pr_err("no RAM resource found for %pR\n", &emu_mem);
        ret = -ENXIO;
        goto out_mem;
    }

    ret = request_resource(ram_res, &emu_mem);
    if (ret) {
        pr_err("request_resource failed on %pR under %pR: error %d\n",
               &emu_mem, ram_res, ret);
        goto out_mem;
    }

    for (p = pg_base; p < pg_base + EMU_MEM_SIZE; p += PAGE_SIZE)
        SetPageReserved(virt_to_page(p));

    return 0;

out_mem:
    free_pages((unsigned long)pg_base, get_order(EMU_MEM_SIZE));
    return ret;
}

static void fff_emu_free_resources(void)
{
    char *pg_base, *p;

    pg_base = __va(emu_mem.start);
    release_resource(&emu_mem);

    for (p = pg_base; p < pg_base + EMU_MEM_SIZE; p += PAGE_SIZE)
        ClearPageReserved(virt_to_page(p));

    free_pages((unsigned long)pg_base, get_order(EMU_MEM_SIZE));
}



-- 
Regards,
Pavel Roskin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
