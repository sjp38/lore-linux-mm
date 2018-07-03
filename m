Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC046B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 15:57:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3-v6so1518025pfn.13
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 12:57:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c6-v6si1740991pgn.143.2018.07.03.12.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 12:57:24 -0700 (PDT)
Date: Tue, 3 Jul 2018 12:57:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
Message-Id: <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
In-Reply-To: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

On Tue,  3 Jul 2018 20:05:06 +0300 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Most functions in memblock already use phys_addr_t to represent a physical
> address with __memblock_free_late() being an exception.
> 
> This patch replaces u64 with phys_addr_t in __memblock_free_late() and
> switches several format strings from %llx to %pa to avoid casting from
> phys_addr_t to u64.
>
> ...
> 
> @@ -1343,9 +1343,9 @@ void * __init memblock_virt_alloc_try_nid_raw(
>  {
>  	void *ptr;
>  
> -	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
> -		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
> -		     (u64)max_addr, (void *)_RET_IP_);
> +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> +		     &max_addr, (void *)_RET_IP_);
>  

Did you see all this checkpatch noise?

: WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
: #54: FILE: mm/memblock.c:1348:
: +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
: +		     __func__, (u64)size, (u64)align, nid, &min_addr,
: +		     &max_addr, (void *)_RET_IP_);
: ...
: 

 * - 'S' For symbolic direct pointers (or function descriptors) with offset
 * - 's' For symbolic direct pointers (or function descriptors) without offset
 * - 'F' Same as 'S'
 * - 'f' Same as 's'

I'm not sure why or when all that happened.

I suppose we should do that as a separate patch sometime.
