Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF3C8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 01:48:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so1076697oib.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 22:48:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12-v6sor43940oib.5.2018.09.11.22.48.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 22:48:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180910234400.4068.15541.stgit@localhost.localdomain>
References: <20180910232615.4068.29155.stgit@localhost.localdomain> <20180910234400.4068.15541.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Sep 2018 22:48:40 -0700
Message-ID: <CAPcyv4gm30sT_us0j27jLmNTV_Fug4d8EW4xTmiTMFdwGSjN-A@mail.gmail.com>
Subject: Re: [PATCH 4/4] nvdimm: Trigger the device probe on a cpu local to
 the device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 10, 2018 at 4:44 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This patch is based off of the pci_call_probe function used to initialize
> PCI devices. The general idea here is to move the probe call to a location
> that is local to the memory being initialized. By doing this we can shave
> significant time off of the total time needed for initialization.
>
> With this patch applied I see a significant reduction in overall init time
> as without it the init varied between 23 and 37 seconds to initialize a 3GB
> node. With this patch applied the variance is only between 23 and 26
> seconds to initialize each node.
>
> I hope to refine this further in the future by combining this logic into
> the async_schedule_domain code that is already in use. By doing that it
> would likely make this functionality redundant.

Yeah, it is a bit sad that we schedule an async thread only to move it
back somewhere else.

Could we trivially achieve the same with an
async_schedule_domain_on_cpu() variant? It seems we can and the
workqueue core will "Do the right thing".

I now notice that async uses the system_unbound_wq and work_on_cpu()
uses the system_wq.  I don't think we want long running nvdimm work on
system_wq.
