Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 782846B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:39:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m130so390821030ioa.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:39:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d10si4111778ioj.68.2016.08.02.10.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:39:40 -0700 (PDT)
Subject: Re: [PATCH] mm/slab: Improve performance of gathering slabinfo stats
References: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160802005514.GA14725@js1304-P5Q-DELUXE>
 <4a3fe3bc-eb1d-ea18-bd70-98b8b9c6a7d7@oracle.com>
 <20160802024342.GA15062@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1608020953160.24620@east.gentwo.org>
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Message-ID: <39e8a2e9-93c9-9051-cd90-3690baa8239f@oracle.com>
Date: Tue, 2 Aug 2016 10:39:13 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1608020953160.24620@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


On 08/02/2016 07:59 AM, Christoph Lameter wrote:
> Hmm.... What SLUB does is:
>
> 1. Keep a count of the total number of allocated slab pages per node.
> 	This counter only needs to be updated when a slab page is
> 	allocated from the page allocator or when it is freed to the
> 	page allocator. At that point we already hold the per node lock,
> 	page allocator operations are extremely costly anyways and so that
> 	is ok.
>
> 2. Keep a count of the number of partially allocated slab pages per node.
> 	At that point we have to access the partial list and take a per
> 	node lock. Placing the counter into the same cacheline and
> 	the increment/decrement into the period when the lock has been taken
> 	avoids the overhead.
>

As Joonsoo mentioned in his previous comment, the partial list is pretty 
small anyway. And we cannot avoid traversal of the partial list - we 
have to count the number of active objects in each partial slab:
	
	active_objs += page->active;

So keeping a count of partially allocated slabs seems unnecessary to me.

> The number of full pages is then
>
> 	total - partial
>
>
> If both allocators would use the same scheme here then the code to
> maintain the counter can be moved into mm/slab_common.c. Plus the per node
> structures could be mostly harmonized between both allocators. Maybe even
> the page allocator operations could become common code.
>
> Aruna: Could you work on a solution like that?
>

Yup, I'll replace the 3 counters with one counter for number of slabs 
per node and send out a new patch. I'll try to make the counter 
management as similar as possible, between SLAB and SLUB.

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
