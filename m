Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 347DA6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 06:23:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n4-v6so3155972edr.5
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 03:23:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10-v6si730047edr.341.2018.08.10.03.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 03:23:20 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 1/4] mm: refactor do_munmap() to extract the common
 part
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e62082b8-d458-0fcb-09ab-463dc45cd049@suse.cz>
Date: Fri, 10 Aug 2018 12:20:55 +0200
MIME-Version: 1.0
In-Reply-To: <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/10/2018 01:36 AM, Yang Shi wrote:
> Introduces three new helper functions:
>   * addr_ok()
>   * munmap_lookup_vma()
>   * munlock_vmas()
> 
> They will be used by do_munmap() and the new do_munmap with zapping
> large mapping early in the later patch.
> 
> There is no functional change, just code refactor.
> 
> Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Small nit below.

> @@ -2764,13 +2812,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  	 */
>  	if (mm->locked_vm) {
>  		struct vm_area_struct *tmp = vma;
> -		while (tmp && tmp->vm_start < end) {
> -			if (tmp->vm_flags & VM_LOCKED) {
> -				mm->locked_vm -= vma_pages(tmp);
> -				munlock_vma_pages_all(tmp);
> -			}
> -			tmp = tmp->vm_next;
> -		}
> +		munlock_vmas(tmp, end);

No need for 'tmp' here.
	
>  	}
>  
>  	/*
> 
