Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEA26B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:23:55 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id k4-v6so14981764otf.16
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:23:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 76-v6sor7194574oii.178.2018.04.25.07.23.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 07:23:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180425112415.12327-3-pagupta@redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-3-pagupta@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 25 Apr 2018 07:23:53 -0700
Message-ID: <CAPcyv4gpZzKfE7jY1peYOVd6sVhNz7jce1s_xNH_2Lt8AjRK-Q@mail.gmail.com>
Subject: Re: [RFC v2 2/2] pmem: device flush over VIRTIO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@surriel.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Christoph Hellwig <hch@infradead.org>, Marcel Apfelbaum <marcel@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, niteshnarayanlal@hotmail.com, Igor Mammedov <imammedo@redhat.com>, lcapitulino@redhat.com

On Wed, Apr 25, 2018 at 4:24 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
> This patch adds functionality to perform
> flush from guest to hosy over VIRTIO
> when 'ND_REGION_VIRTIO'flag is set on
> nd_negion. Flag is set by 'virtio-pmem'
> driver.
>
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> ---
>  drivers/nvdimm/region_devs.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
> index a612be6..6c6454e 100644
> --- a/drivers/nvdimm/region_devs.c
> +++ b/drivers/nvdimm/region_devs.c
> @@ -20,6 +20,7 @@
>  #include <linux/nd.h>
>  #include "nd-core.h"
>  #include "nd.h"
> +#include <linux/virtio_pmem.h>
>
>  /*
>   * For readq() and writeq() on 32-bit builds, the hi-lo, lo-hi order is
> @@ -1074,6 +1075,12 @@ void nvdimm_flush(struct nd_region *nd_region)
>         struct nd_region_data *ndrd = dev_get_drvdata(&nd_region->dev);
>         int i, idx;
>
> +       /* call PV device flush */
> +       if (test_bit(ND_REGION_VIRTIO, &nd_region->flags)) {
> +               virtio_pmem_flush(&nd_region->dev);
> +               return;
> +       }
> +

I'd rather introduce a ->flush() operation hanging off of 'struct
nd_region' so that this multiplexing can be a static setting.
