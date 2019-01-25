Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44FC18E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:03:09 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id 18so2633189wmw.6
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:03:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor74827920wru.28.2019.01.25.13.03.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 13:03:07 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231442.EFD29EE0@viggo.jf.intel.com>
In-Reply-To: <20190124231442.EFD29EE0@viggo.jf.intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 25 Jan 2019 15:02:55 -0600
Message-ID: <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk failures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, Jerome Glisse <jglisse@redhat.com>

On Thu, Jan 24, 2019 at 5:21 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> walk_system_ram_range() can return an error code either becuase *it*
> failed, or because the 'func' that it calls returned an error.  The
> memory hotplug does the following:
>
>         ret = walk_system_ram_range(..., func);
>         if (ret)
>                 return ret;
>
> and 'ret' makes it out to userspace, eventually.  The problem is,
> walk_system_ram_range() failues that result from *it* failing (as
> opposed to 'func') return -1.  That leads to a very odd -EPERM (-1)
> return code out to userspace.
>
> Make walk_system_ram_range() return -EINVAL for internal failures to
> keep userspace less confused.
>
> This return code is compatible with all the callers that I audited.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Jerome Glisse <jglisse@redhat.com>
> ---
>
>  b/kernel/resource.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
> --- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1      2019-01-24 15:13:13.950199540 -0800
> +++ b/kernel/resource.c 2019-01-24 15:13:13.954199540 -0800
> @@ -375,7 +375,7 @@ static int __walk_iomem_res_desc(resourc
>                                  int (*func)(struct resource *, void *))
>  {
>         struct resource res;
> -       int ret = -1;
> +       int ret = -EINVAL;
>
>         while (start < end &&
>                !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
>         unsigned long flags;
>         struct resource res;
>         unsigned long pfn, end_pfn;
> -       int ret = -1;
> +       int ret = -EINVAL;

Can you either make a similar change to the powerpc version of
walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
not needed?  It *seems* like we'd want both versions of
walk_system_ram_range() to behave similarly in this respect.

>         start = (u64) start_pfn << PAGE_SHIFT;
>         end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> _
