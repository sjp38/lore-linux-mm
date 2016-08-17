Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA216B025E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 15:25:44 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so300534096oih.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:25:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a136si1085047ita.55.2016.08.17.12.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 12:25:43 -0700 (PDT)
Subject: Re: [PATCH v3] mm/slab: Improve performance of gathering slabinfo
 stats
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <1471460636.29842.20.camel@edumazet-glaptop3.roam.corp.google.com>
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Message-ID: <a747d233-5e27-20c3-7e06-cee8d9f2bda1@oracle.com>
Date: Wed, 17 Aug 2016 12:25:33 -0700
MIME-Version: 1.0
In-Reply-To: <1471460636.29842.20.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>


On 08/17/2016 12:03 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 11:20 -0700, Aruna Ramakrishna wrote:
> ]
>> -		list_for_each_entry(page, &n->slabs_full, lru) {
>> -			if (page->active != cachep->num && !error)
>> -				error = "slabs_full accounting error";
>> -			active_objs += cachep->num;
>> -			active_slabs++;
>> -		}
>
> Since you only removed this loop, you could track only number of
> full_slabs.
>
> This would avoid messing with n->num_slabs all over the places in fast
> path.
>
> Please also update slab_out_of_memory()
>

Eric,

Right now, n->num_slabs is modified only when a slab is detached from 
slabs_free (i.e. in drain_freelist and free_block) or when a new one is 
attached in cache_grow_end. None of those 3 calls are in the fast path, 
right? Tracking just full_slabs would also involve similar changes: 
decrement when a slab moves from full to partial during free_block, and 
increment when it moves from partial/free to full after allocation in 
fixup_slab_list. So I don't see what the real difference/advantage is.

I will update slab_out_of_memory and remove the slabs_full list 
traversal there too.

Thanks,
Aruna


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
