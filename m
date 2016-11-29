Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1DF6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:23:59 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c21so305558658ioj.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:23:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q16si3409065itc.58.2016.11.29.14.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:23:58 -0800 (PST)
Subject: Re: [PATCHv4 06/10] xen: Switch to using __pa_symbol
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-7-git-send-email-labbott@redhat.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <935fefbf-97dc-83fc-b7c3-ba3f19f2087f@oracle.com>
Date: Tue, 29 Nov 2016 17:26:18 -0500
MIME-Version: 1.0
In-Reply-To: <1480445729-27130-7-git-send-email-labbott@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org

On 11/29/2016 01:55 PM, Laura Abbott wrote:
> __pa_symbol is the correct macro to use on kernel
> symbols. Switch to this from __pa.
>
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> Found during a sweep of the kernel. Untested.
> ---
>  drivers/xen/xenbus/xenbus_dev_backend.c | 2 +-
>  drivers/xen/xenfs/xenstored.c           | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenb=
us/xenbus_dev_backend.c
> index 4a41ac9..31ca2bf 100644
> --- a/drivers/xen/xenbus/xenbus_dev_backend.c
> +++ b/drivers/xen/xenbus/xenbus_dev_backend.c
> @@ -99,7 +99,7 @@ static int xenbus_backend_mmap(struct file *file, str=
uct vm_area_struct *vma)
>  		return -EINVAL;
> =20
>  	if (remap_pfn_range(vma, vma->vm_start,
> -			    virt_to_pfn(xen_store_interface),
> +			    PHYS_PFN(__pa_symbol(xen_store_interface)),
>  			    size, vma->vm_page_prot))
>  		return -EAGAIN;
> =20
> diff --git a/drivers/xen/xenfs/xenstored.c b/drivers/xen/xenfs/xenstore=
d.c
> index fef20db..21009ea 100644
> --- a/drivers/xen/xenfs/xenstored.c
> +++ b/drivers/xen/xenfs/xenstored.c
> @@ -38,7 +38,7 @@ static int xsd_kva_mmap(struct file *file, struct vm_=
area_struct *vma)
>  		return -EINVAL;
> =20
>  	if (remap_pfn_range(vma, vma->vm_start,
> -			    virt_to_pfn(xen_store_interface),
> +			    PHYS_PFN(__pa_symbol(xen_store_interface)),
>  			    size, vma->vm_page_prot))
>  		return -EAGAIN;
> =20


I suspect this won't work --- xen_store_interface doesn't point to a
kernel symbol.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
