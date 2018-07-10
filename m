Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD0A76B0006
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:17:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w11-v6so7617162pfk.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:17:47 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g61-v6si16729524plb.169.2018.07.10.03.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 03:17:46 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v35 1/5] mm: support to get hints of free page blocks
Date: Tue, 10 Jul 2018 10:16:57 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396E91B6@SHSMSX101.ccr.corp.intel.com>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
 <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1531215067-35472-2-git-send-email-wei.w.wang@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Tuesday, July 10, 2018 5:31 PM, Wang, Wei W wrote:
> Subject: [PATCH v35 1/5] mm: support to get hints of free page blocks
>=20
> This patch adds support to get free page blocks from a free page list.
> The physical addresses of the blocks are stored to a list of buffers pass=
ed
> from the caller. The obtained free page blocks are hints about free pages=
,
> because there is no guarantee that they are still on the free page list a=
fter the
> function returns.
>=20
> One use example of this patch is to accelerate live migration by skipping=
 the
> transfer of free pages reported from the guest. A popular method used by
> the hypervisor to track which part of memory is written during live migra=
tion
> is to write-protect all the guest memory. So, those pages that are hinted=
 as
> free pages but are written after this function returns will be captured b=
y the
> hypervisor, and they will be added to the next round of memory transfer.
>=20
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  include/linux/mm.h |  3 ++
>  mm/page_alloc.c    | 98
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 101 insertions(+)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h index a0fbb9f..5ce65=
4f
> 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2007,6 +2007,9 @@ extern void free_area_init(unsigned long *
> zones_size);  extern void free_area_init_node(int nid, unsigned long *
> zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
> extern void free_initmem(void);
> +unsigned long max_free_page_blocks(int order); int
> +get_from_free_page_list(int order, struct list_head *pages,
> +			    unsigned int size, unsigned long *loaded_num);
>=20
>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 1521100..b67839b
> 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5043,6 +5043,104 @@ void show_free_areas(unsigned int filter,
> nodemask_t *nodemask)
>  	show_swap_cache_info();
>  }
>=20
> +/**
> + * max_free_page_blocks - estimate the max number of free page blocks
> + * @order: the order of the free page blocks to estimate
> + *
> + * This function gives a rough estimation of the possible maximum
> +number of
> + * free page blocks a free list may have. The estimation works on an
> +assumption
> + * that all the system pages are on that list.
> + *
> + * Context: Any context.
> + *
> + * Return: The largest number of free page blocks that the free list can=
 have.
> + */
> +unsigned long max_free_page_blocks(int order) {
> +	return totalram_pages / (1 << order);
> +}
> +EXPORT_SYMBOL_GPL(max_free_page_blocks);
> +
> +/**
> + * get_from_free_page_list - get hints of free pages from a free page
> +list
> + * @order: the order of the free page list to check
> + * @pages: the list of page blocks used as buffers to load the
> +addresses
> + * @size: the size of each buffer in bytes
> + * @loaded_num: the number of addresses loaded to the buffers
> + *
> + * This function offers hints about free pages. The addresses of free
> +page
> + * blocks are stored to the list of buffers passed from the caller.
> +There is
> + * no guarantee that the obtained free pages are still on the free page
> +list
> + * after the function returns. pfn_to_page on the obtained free pages
> +is
> + * strongly discouraged and if there is an absolute need for that, make
> +sure
> + * to contact MM people to discuss potential problems.
> + *
> + * The addresses are currently stored to a buffer in little endian.
> +This
> + * avoids the overhead of converting endianness by the caller who needs
> +data
> + * in the little endian format. Big endian support can be added on
> +demand in
> + * the future.
> + *
> + * Context: Process context.
> + *
> + * Return: 0 if all the free page block addresses are stored to the buff=
ers;
> + *         -ENOSPC if the buffers are not sufficient to store all the
> + *         addresses; or -EINVAL if an unexpected argument is received (=
e.g.
> + *         incorrect @order, empty buffer list).
> + */
> +int get_from_free_page_list(int order, struct list_head *pages,
> +			    unsigned int size, unsigned long *loaded_num) {


Hi Linus,

We  took your original suggestion - pass in pre-allocated buffers to load t=
he addresses (now we use a list of pre-allocated page blocks as buffers). H=
ope that suggestion is still acceptable (the advantage of this method was e=
xplained here: https://lkml.org/lkml/2018/6/28/184).
Look forward to getting your feedback. Thanks.

Best,
Wei=20
