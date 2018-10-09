Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85C766B000D
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 20:21:06 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id l89-v6so6482845otc.6
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 17:21:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor6315555otj.190.2018.10.08.17.21.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 17:21:05 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4jX5WYmMYzGCBrnaqT7tqHGSVPwm7Dpi-XpuM9ns84+0w@mail.gmail.com>
 <20181008233404.1909.37302.stgit@localhost.localdomain>
In-Reply-To: <20181008233404.1909.37302.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 8 Oct 2018 17:20:54 -0700
Message-ID: <CAPcyv4jB5S7DbYr+LmMNpD0teKrO2aoVfJxnSFPrswPCcs-Snw@mail.gmail.com>
Subject: Re: [mm PATCH] memremap: Fix reference count for pgmap in devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Oct 8, 2018 at 4:34 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> In the earlier patch "mm: defer ZONE_DEVICE page initialization to the
> point where we init pgmap" I had overlooked the reference count that was
> being held per page on the pgmap. As a result on running the ndctl test
> "create.sh" we would call into devm_memremap_pages_release and encounter
> the following percpu reference count error and hang:
>   WARNING: CPU: 30 PID: 0 at lib/percpu-refcount.c:155
>   percpu_ref_switch_to_atomic_rcu+0xf3/0x120
>
> This patch addresses that by performing an update for all of the device
> PFNs in a single call. In my testing this seems to resolve the issue while
> still allowing us to retain the improvements seen in memory initialization.
>
> Reported-by: Dan Williams <dan.j.williams@intel.com>

Tested-by: Dan Williams <dan.j.williams@intel.com>

Thanks Alex!
