Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD5FC6B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 14:50:56 -0400 (EDT)
Received: by wgin8 with SMTP id n8so34655223wgi.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 11:50:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bq1si9003488wib.14.2015.04.06.11.50.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 11:50:52 -0700 (PDT)
Message-ID: <5522D582.8070408@redhat.com>
Date: Mon, 06 Apr 2015 14:50:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v7 1/2] mm: prototype: rid swapoff of quadratic complexity
References: <20150319105515.GA8140@kelleynnn-virtual-machine>
In-Reply-To: <20150319105515.GA8140@kelleynnn-virtual-machine>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>, linux-mm@kvack.org, riel@surriel.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On 03/19/2015 06:55 AM, Kelley Nielsen wrote:
> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
>
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.
>
> Improvement
>
> swapoff was called on a swap partition containing about 50M of data,
> and calls to the function unuse_pte_range() were counted.
>
> Present implementation....about 22.5M calls.
> Prototype.................about  7.0K   calls.
>
> Details
>
> In shmem_unuse(), iterate over the shmem_swaplist and, for each
> shmem_inode_info that contains a swap entry, pass it to shmem_unuse_inode(),
> along with the swap type. In shmem_unuse_inode(), iterate over its associated
> radix tree, and store the index of each exceptional entry in an array for
> passing to shmem_getpage_gfp() outside of the RCU critical section.
>
> In try_to_unuse(), instead of iterating over the entries in the type and
> unusing them one by one, perhaps walking all the page tables for all the
> processes for each one, iterate over the mmlist, making one pass. Pass
> each mm to unuse_mm() to begin its page table walk, and during the walk,
> unuse all the ptes that have backing store in the swap type received by
> try_to_unuse(). After the walk, check the type for orphaned swap entries
> with find_next_to_unuse(), and remove them from the swap cache. If
> find_next_to_unuse() starts over at the beginning of the type, repeat
> the check of the shmem_swaplist and the walk a maximum of three times.
>
> Change unuse_mm() and the intervening walk functions down to unuse_pte_range()
> to take the type as a parameter, and to iterate over their entire range,
> calling the next function down on every iteration. In unuse_pte_range(),
> make a swap entry from each pte in the range using the passed in type.
> If it has backing store in the type, call swapin_readahead() to retrieve
> the page, and then pass this page to unuse_pte().
>
> TODO
>
> * Handle count of unused pages for frontswap.
>
> Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>

Looks good to me. Thanks for sticking with it, Kelley!

I assume this patch passes your tests?

I see you are freeing swap entries on swapin from the last
pte referencing it, which should cause the pages to get
swapped out to other swap areas when doing swapoff under
very heavy memory pressure, and the swapoff should
eventually complete...

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
