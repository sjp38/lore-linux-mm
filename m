Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 37ABF6B01BE
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 13:19:57 -0400 (EDT)
Date: Thu, 1 Jul 2010 10:17:46 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-Id: <20100701101746.3810cc3b.randy.dunlap@oracle.com>
In-Reply-To: <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
	<1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 22:55:50 -0700 Zach Pfeffer wrote:

>  arch/arm/mm/vcm.c         | 1901 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/vcm.h       |  701 +++++++++++++++++
>  include/linux/vcm_types.h |  318 ++++++++
>  3 files changed, 2920 insertions(+), 0 deletions(-)
>  create mode 100644 arch/arm/mm/vcm.c
>  create mode 100644 include/linux/vcm.h
>  create mode 100644 include/linux/vcm_types.h


> diff --git a/include/linux/vcm.h b/include/linux/vcm.h
> new file mode 100644
> index 0000000..d2a1cd1
> --- /dev/null
> +++ b/include/linux/vcm.h
> @@ -0,0 +1,701 @@
> +/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions are
> + * met:
> + *     * Redistributions of source code must retain the above copyright
> + *       notice, this list of conditions and the following disclaimer.
> + *     * Redistributions in binary form must reproduce the above
> + *       copyright notice, this list of conditions and the following
> + *       disclaimer in the documentation and/or other materials provided
> + *       with the distribution.
> + *     * Neither the name of Code Aurora Forum, Inc. nor the names of its
> + *       contributors may be used to endorse or promote products derived
> + *       from this software without specific prior written permission.
> + *
> + * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
> + * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
> + * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
> + * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> + * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> + * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> + * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
> + * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
> + * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
> + * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + */

What license (name/type) is this?

> +
> +#ifndef _VCM_H_
> +#define _VCM_H_
> +
> +/* All undefined types must be defined using platform specific headers */
> +
> +#include <linux/vcm_types.h>
> +

> +/*
> + * Creating, freeing and managing VCMs.
> + *
> + * A VCM region is a virtual space that can be reserved from and
> + * associated with one or more devices. At creation the user can
> + * specify an offset to start addresses and a length of the entire VCM
> + * region. Reservations out of a VCM region are always contiguous.
> + */
> +
> +/**
> + * vcm_create() - Create a VCM region
> + * @start_addr	The starting address of the VCM region.

 * @start_addr:		text
 * @len:		text

I.e., need a colon (':') after each param name. (in multiple places)


> + * @len		The len of the VCM region. This must be at least
> + *		vcm_get_min_page_size() bytes.
> + *
> + * A VCM typically abstracts a page table.
> + *
> + * All functions in this API are passed and return opaque things
> + * because the underlying implementations will vary. The goal
> + * is really graph management. vcm_create() creates the "device end"
> + * of an edge in the mapping graph.
> + *
> + * The return value is non-zero if a VCM has successfully been
> + * created. It will return zero if a VCM region cannot be created or
> + * len is invalid.
> + */
> +struct vcm *vcm_create(size_t start_addr, size_t len);


> +/**
> + * vcm_get_physmem_from_res() - Return a reservation's physmem_id
> + * @ res_id	An existing reservation of interest.

 * @res_id: <text>

No space between @ and res_id.

> + *
> + * The return value will be non-zero on success, otherwise it will be:
> + * -EINVAL	res is invalid
> + * -ENOMEM	res is unbacked
> + */
> +struct physmem *vcm_get_physmem_from_res(struct res *res_id);



> diff --git a/include/linux/vcm_types.h b/include/linux/vcm_types.h
> new file mode 100644
> index 0000000..2cc4770
> --- /dev/null
> +++ b/include/linux/vcm_types.h
> @@ -0,0 +1,318 @@


> +/**
> + * enum memtarget_t - A logical location in a VCM.
> + *
> + * VCM_START	Indicates the start of a VCM_REGION.

This is not quite kernel-doc notation (as indicated by the beginning /**).
Please see Documentation/kernel-doc-nano-HOWTO.txt for details, or ask me
if you need help with it.

> + */
> +enum memtarget_t {
> +	VCM_START
> +};
> +
> +
> +/**
> + * enum memtype_t - A logical location in a VCM.

not quite kernel-doc notation...

> + *
> + * VCM_MEMTYPE_0	Generic memory type 0
> + * VCM_MEMTYPE_1	Generic memory type 1
> + * VCM_MEMTYPE_2	Generic memory type 2
> + *
> + * A memtype encapsulates a platform specific memory arrangement. The
> + * memtype needn't refer to a single type of memory, it can refer to a
> + * set of memories that can back a reservation.
> + *
> + */
> +enum memtype_t {
> +	VCM_INVALID,
> +	VCM_MEMTYPE_0,
> +	VCM_MEMTYPE_1,
> +	VCM_MEMTYPE_2,
> +};
> +
> +
> +/**
> + * vcm_handler - The signature of the fault hook.
> + * @dev_id	The device id of the faulting device.
> + * @data	The generic data pointer.
> + * @fault_data	System specific common fault data.

ditto.

> + *
> + * The handler should return 0 for success. This indicates that the
> + * fault was handled. A non-zero return value is an error and will be
> + * propagated up the stack.
> + */
> +typedef int (*vcm_handler)(size_t dev_id, void *data, void *fault_data);
> +
> +
> +enum vcm_type {
> +	VCM_DEVICE,
> +	VCM_EXT_KERNEL,
> +	VCM_EXT_USER,
> +	VCM_ONE_TO_ONE,
> +};
> +
> +
> +/**
> + * vcm - A Virtually Contiguous Memory region.

 * struct vcm - ...

and add colon after each struct @member:

> + * @start_addr	The starting address of the VCM region.
> + * @len 	The len of the VCM region. This must be at least
> + *		vcm_min() bytes.

and missing lots of struct members here.
If some of them are private, you can use:

	/* private: */
...
	/* public: */
comments in the struct below and then don't add the private ones to the
kernel-doc notation above.

> + */
> +struct vcm {
> +	enum vcm_type type;
> +
> +	size_t start_addr;
> +	size_t len;
> +
> +	size_t dev_id; /* opaque device control */
> +
> +	/* allocator dependent */
> +	struct gen_pool *pool;
> +
> +	struct list_head res_head;
> +
> +	/* this will be a very short list */
> +	struct list_head assoc_head;
> +};
> +
> +/**
> + * avcm - A VCM to device association

not quite kernel-doc notation.

> + * @vcm		The VCM region of interest.
> + * @dev_id	The device to associate the VCM with.
> + * @attr	See 'Association Attributes'.
> + */
> +struct avcm {
> +	struct vcm *vcm_id;
> +	size_t dev_id;
> +	uint32_t attr;
> +
> +	struct list_head assoc_elm;
> +
> +	int is_active; /* is this particular association active */
> +};
> +
> +/**
> + * bound - A boundary to reserve from in a VCM region.

ditto.

> + * @vcm		The VCM that needs a bound.
> + * @len		The len of the bound.
> + */
> +struct bound {
> +	struct vcm *vcm_id;
> +	size_t len;
> +};
> +
> +
> +/**
> + * physmem - A physical memory allocation.

ditto.

> + * @memtype	The memory type of the VCM region.
> + * @len		The len of the physical memory allocation.
> + * @attr 	See 'Physical Allocation Attributes'.
> + *
> + */
> +
> +struct physmem {
> +	enum memtype_t memtype;
> +	size_t len;
> +	uint32_t attr;
> +
> +	struct phys_chunk alloc_head;
> +
> +	/* if the physmem is cont then use the built in VCM */
> +	int is_cont;
> +	struct res *res;
> +};
> +
> +/**
> + * res - A reservation in a VCM region.

ditto.

> + * @vcm		The VCM region to reserve from.
> + * @len		The length of the reservation. Must be at least vcm_min()
> + *		bytes.
> + * @attr	See 'Reservation Attributes'.
> + */
> +struct res {
> +	struct vcm *vcm_id;
> +	struct physmem *physmem_id;
> +	size_t len;
> +	uint32_t attr;
> +
> +	/* allocator dependent */
> +	size_t alignment_req;
> +	size_t aligned_len;
> +	unsigned long ptr;
> +	size_t aligned_ptr;
> +
> +	struct list_head res_elm;
> +
> +
> +	/* type VCM_EXT_KERNEL */
> +	struct vm_struct *vm_area;
> +	int mapped;
> +};
> +
> +extern int chunk_sizes[NUM_CHUNK_SIZES];
> +
> +#endif /* VCM_TYPES_H */
> -- 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
