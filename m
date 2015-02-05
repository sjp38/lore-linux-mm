Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AEA54828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 03:37:38 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so8609075pab.6
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 00:37:38 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id ry9si5242601pbc.147.2015.02.05.00.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 00:37:37 -0800 (PST)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 74FB620D38
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 03:37:34 -0500 (EST)
Message-ID: <54D32BCC.1010608@iki.fi>
Date: Thu, 05 Feb 2015 10:37:32 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/5] slab: Correct size_index table before replacing
 the bootstrap kmem_cache_node.
References: <E484D272A3A61B4880CDF2E712E9279F4591AFFB@hhmail02.hh.imgtec.org> <1423084015-24010-1-git-send-email-daniel.sanders@imgtec.com>
In-Reply-To: <1423084015-24010-1-git-send-email-daniel.sanders@imgtec.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Sanders <daniel.sanders@imgtec.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 02/04/2015 11:06 PM, Daniel Sanders wrote:
> This patch moves the initialization of the size_index table slightly
> earlier so that the first few kmem_cache_node's can be safely allocated
> when KMALLOC_MIN_SIZE is large.
>
> There are currently two ways to generate indices into kmalloc_caches
> (via kmalloc_index() and via the size_index table in slab_common.c)
> and on some arches (possibly only MIPS) they potentially disagree with
> each other until create_kmalloc_caches() has been called. It seems
> that the intention is that the size_index table is a fast equivalent
> to kmalloc_index() and that create_kmalloc_caches() patches the table
> to return the correct value for the cases where kmalloc_index()'s
> if-statements apply.
>
> The failing sequence was:
> * kmalloc_caches contains NULL elements
> * kmem_cache_init initialises the element that 'struct
>    kmem_cache_node' will be allocated to. For 32-bit Mips, this is a
>    56-byte struct and kmalloc_index returns KMALLOC_SHIFT_LOW (7).
> * init_list is called which calls kmalloc_node to allocate a 'struct
>    kmem_cache_node'.
> * kmalloc_slab selects the kmem_caches element using
>    size_index[size_index_elem(size)]. For MIPS, size is 56, and the
>    expression returns 6.
> * This element of kmalloc_caches is NULL and allocation fails.
> * If it had not already failed, it would have called
>    create_kmalloc_caches() at this point which would have changed
>    size_index[size_index_elem(size)] to 7.
>
> Signed-off-by: Daniel Sanders <daniel.sanders@imgtec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
