Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4D446B02C3
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 23:54:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k8so56459563pfk.11
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 20:54:48 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 100si5217106pld.116.2017.06.23.20.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 20:54:47 -0700 (PDT)
Subject: Re: [HMM 09/15] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE v5
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-10-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <64f74f48-ca5e-e16d-7546-0d57163f6f93@nvidia.com>
Date: Fri, 23 Jun 2017 20:54:44 -0700
MIME-Version: 1.0
In-Reply-To: <20170524172024.30810-10-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>Evgeny Baskakov <ebaskakov@nvidia.com>

On 05/24/2017 10:20 AM, J=C3=A9r=C3=B4me Glisse wrote:
[...]
> +/*
> + * hmm_devmem_fault_range() - migrate back a virtual range of memory
> + *
> + * @devmem: hmm_devmem struct use to track and manage the ZONE_DEVICE me=
mory
> + * @vma: virtual memory area containing the range to be migrated
> + * @ops: migration callback for allocating destination memory and copyin=
g
> + * @src: array of unsigned long containing source pfns
> + * @dst: array of unsigned long containing destination pfns
> + * @start: start address of the range to migrate (inclusive)
> + * @addr: fault address (must be inside the range)
> + * @end: end address of the range to migrate (exclusive)
> + * @private: pointer passed back to each of the callback
> + * Returns: 0 on success, VM_FAULT_SIGBUS on error
> + *
> + * This is a wrapper around migrate_vma() which checks the migration sta=
tus
> + * for a given fault address and returns the corresponding page fault ha=
ndler
> + * status. That will be 0 on success, or VM_FAULT_SIGBUS if migration fa=
iled
> + * for the faulting address.
> + *
> + * This is a helper intendend to be used by the ZONE_DEVICE fault handle=
r.
> + */
> +int hmm_devmem_fault_range(struct hmm_devmem *devmem,
> +			   struct vm_area_struct *vma,
> +			   const struct migrate_vma_ops *ops,
> +			   unsigned long *src,
> +			   unsigned long *dst,
> +			   unsigned long start,
> +			   unsigned long addr,
> +			   unsigned long end,
> +			   void *private)
> +{
> +	if (migrate_vma(ops, vma, start, end, src, dst, private))
> +		return VM_FAULT_SIGBUS;
> +
> +	if (dst[(addr - start) >> PAGE_SHIFT] & MIGRATE_PFN_ERROR)
> +		return VM_FAULT_SIGBUS;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(hmm_devmem_fault_range);
> +#endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
>=20

Hi Jerome (+Evgeny),

After some time and testing, I'd like to recommend that we delete the above=
=20
hmm_dev_fault_range() function from the patchset. Reasons:

1. Our driver code is actually easier to follow if we call migrate_vma() di=
rectly, for CPU=20
faults. That's because there are a lot of hmm_* calls in both directions (d=
river <-->=20
core), already, and it takes some time to remember which direction each one=
 goes.

2. The helper is a little confusing to use, what with a start, end, *and* a=
n addr argument.

3. ...and it doesn't add anything that the driver can't trivially do itself=
.

So, let's just remove it. Less is more this time. :)

thanks,
--
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
