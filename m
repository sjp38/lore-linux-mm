Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E37A6B0269
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:56:50 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id a14-v6so15010484otf.1
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:56:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c85-v6sor8145219oig.27.2018.05.22.09.56.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 09:56:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <860a8c46-5171-78ac-0255-ee1d21b16ce8@deltatee.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152694212460.5484.13180030631810166467.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180521161026.709d5f2876e44f151da3d179@linux-foundation.org>
 <CAPcyv4hMwMefMu3La+hZvN6r+Q6_N5t+eOgGE0bqVou=Cjpfwg@mail.gmail.com> <860a8c46-5171-78ac-0255-ee1d21b16ce8@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 09:56:48 -0700
Message-ID: <CAPcyv4i-MAYLsmT1M4=D_fwMNF98MupDyNBjWNmOzwY5Lzz0Lw@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm, devm_memremap_pages: handle errors allocating
 final devres action
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, May 22, 2018 at 9:42 AM, Logan Gunthorpe <logang@deltatee.com> wrote:
> Hey Dan,
>
> On 21/05/18 06:07 PM, Dan Williams wrote:
>> Without this change we could fail to register the teardown of
>> devm_memremap_pages(). The likelihood of hitting this failure is tiny
>> as small memory allocations almost always succeed. However, the impact
>> of the failure is large given any future reconfiguration, or
>> disable/enable, of an nvdimm namespace will fail forever as subsequent
>> calls to devm_memremap_pages() will fail to setup the pgmap_radix
>> since there will be stale entries for the physical address range.
>
> Sorry, I don't follow this. The change only seems to prevent a warning
> from occurring in this situation. Won't pgmap_radix_release() still be
> called regardless of whether this patch is applied?

devm_add_action() does not call the release function,
devm_add_action_or_reset() does.

> But it looks to me like this patch doesn't quite solve the issue -- at
> least when looking at dax/pmem.c: If devm_add_action_or_reset() fails,
> then dax_pmem_percpu_kill() won't be registered as an action and the
> percpu_ref will never get killed. Thus, dax_pmem_percpu_release() would
> not get called and dax_pmem_percpu_exit() will hang waiting for a
> completion that will never occur. So we probably need to add a kill call
> somewhere on the failing path...

Ah, true, good catch!

We should manually kill in the !registered case. I think this means we
need to pass in the custom kill routine, because for the pmem driver
it's blk_freeze_queue_start().
