Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584496B6AC1
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 14:47:51 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id t13so6146976otk.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:47:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor6928027otu.127.2018.12.03.11.47.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 11:47:50 -0800 (PST)
MIME-Version: 1.0
References: <154386493754.27193.1300965403157243427.stgit@ahduyck-desk1.amr.corp.intel.com>
 <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154386513120.27193.7977541941078967487.stgit@ahduyck-desk1.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Dec 2018 11:47:37 -0800
Message-ID: <CAPcyv4gZkx9zRsKkVhrmPG7SyjPEycp0neFnECmSADZNLuDOpQ@mail.gmail.com>
Subject: Re: [PATCH RFC 2/3] mm: Add support for exposing if dev_pagemap
 supports refcount pinning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Paolo Bonzini <pbonzini@redhat.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Barret Rhoden <brho@google.com>, KVM list <kvm@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, David Hildenbrand <david@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Dec 3, 2018 at 11:25 AM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> Add a means of exposing if a pagemap supports refcount pinning. I am doing
> this to expose if a given pagemap has backing struct pages that will allow
> for the reference count of the page to be incremented to lock the page
> into place.
>
> The KVM code already has several spots where it was trying to use a
> pfn_valid check combined with a PageReserved check to determien if it could
> take a reference on the page. I am adding this check so in the case of the
> page having the reserved flag checked we can check the pagemap for the page
> to determine if we might fall into the special DAX case.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  drivers/nvdimm/pfn_devs.c |    2 ++
>  include/linux/memremap.h  |    5 ++++-
>  include/linux/mm.h        |   11 +++++++++++
>  3 files changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 6f22272e8d80..7a4a85bcf7f4 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -640,6 +640,8 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
>         } else
>                 return -ENXIO;
>
> +       pgmap->support_refcount_pinning = true;
> +

There should be no dev_pagemap instance instance where this isn't
true, so I'm missing why this is needed?
