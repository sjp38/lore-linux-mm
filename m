Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88BD86B0253
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 18:10:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so15908662pff.18
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 15:10:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 190si5375135pgi.574.2017.10.23.15.10.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 15:10:07 -0700 (PDT)
Subject: Re: [RFC] mmap(MAP_CONTIG)
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b2dee13d-a19a-2b53-7317-7227749375d9@intel.com>
Date: Mon, 23 Oct 2017 15:10:05 -0700
MIME-Version: 1.0
In-Reply-To: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>

On 10/03/2017 04:56 PM, Mike Kravetz wrote:
> mmap(MAP_CONTIG) would have the following semantics:
> - The entire mapping (length size) would be backed by physically contiguous
>   pages.
> - If 'length' physically contiguous pages can not be allocated, then mmap
>   will fail.
> - MAP_CONTIG only works with MAP_ANONYMOUS mappings.
> - MAP_CONTIG will lock the associated pages in memory.  As such, the same
>   privileges and limits that apply to mlock will also apply to MAP_CONTIG.
> - A MAP_CONTIG mapping can not be expanded.

Do you also need to lock out the NUMA migration APIs somehow?  What
about KSM (or does it already ignore VM_LOCKED)?

> - At fork time, private MAP_CONTIG mappings will be converted to regular
>   (non-MAP_CONTIG) mapping in the child.  As such a COW fault in the child
>   will not require a contiguous allocation.
Maybe we should just define it as acting as if it had MADV_DONTFORK set
on it, and also that it doesn't allow MADV_DONTFORK to be called on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
