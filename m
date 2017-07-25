Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED986B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:15:28 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s18so76312120qks.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:15:28 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id t29si11831396qta.166.2017.07.25.12.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:15:27 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id u139so12708488qka.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:15:27 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:15:25 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 14/23] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170725191524.GN18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-15-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-15-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:11PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The percpu memory allocator is experiencing scalability issues when
> allocating and freeing large numbers of counters as in BPF.
> Additionally, there is a corner case where iteration is triggered over
> all chunks if the contig_hint is the right size, but wrong alignment.
> 
> This patch replaces the area map allocator with a basic bitmap allocator
> implementation. Each subsequent patch will introduce new features and
> replace full scanning functions with faster non-scanning options when
> possible.
> 
> Implementation:
> This patchset removes the area map allocator in favor of a bitmap
> allocator backed by metadata blocks. The primary goal is to provide
> consistency in performance and memory footprint with a focus on small
> allocations (< 64 bytes). The bitmap removes the heavy memmove from the
> freeing critical path and provides a consistent memory footprint. The
> metadata blocks provide a bound on the amount of scanning required by
> maintaining a set of hints.
> 
> In an effort to make freeing fast, the metadata is updated on the free
> path if the new free area makes a page free, a block free, or spans
> across blocks. This causes the chunk's contig hint to potentially be
> smaller than what it could allocate by up to the smaller of a page or a
> block. If the chunk's contig hint is contained within a block, a check
> occurs and the hint is kept accurate. Metadata is always kept accurate
> on allocation, so there will not be a situation where a chunk has a
> later contig hint than available.
> 
> Evaluation:
> I have primarily done testing against a simple workload of allocation of
> 1 million objects (2^20) of varying size. Deallocation was done by in
> order, alternating, and in reverse. These numbers were collected after
> rebasing ontop of a80099a152. I present the worst-case numbers here:
> 
>   Area Map Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        310      |     4770
>              16B    |        557      |     1325
>              64B    |        436      |      273
>             256B    |        776      |      131
>            1024B    |       3280      |      122
> 
>   Bitmap Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        490      |       70
>              16B    |        515      |       75
>              64B    |        610      |       80
>             256B    |        950      |      100
>            1024B    |       3520      |      200
> 
> This data demonstrates the inability for the area map allocator to
> handle less than ideal situations. In the best case of reverse
> deallocation, the area map allocator was able to perform within range
> of the bitmap allocator. In the worst case situation, freeing took
> nearly 5 seconds for 1 million 4-byte objects. The bitmap allocator
> dramatically improves the consistency of the free path. The small
> allocations performed nearly identical regardless of the freeing
> pattern.
> 
> While it does add to the allocation latency, the allocation scenario
> here is optimal for the area map allocator. The area map allocator runs
> into trouble when it is allocating in chunks where the latter half is
> full. It is difficult to replicate this, so I present a variant where
> the pages are second half filled. Freeing was done sequentially. Below
> are the numbers for this scenario:
> 
>   Area Map Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |       4118      |     4892
>              16B    |       1651      |     1163
>              64B    |        598      |      285
>             256B    |        771      |      158
>            1024B    |       3034      |      160
> 
>   Bitmap Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        481      |       67
>              16B    |        506      |       69
>              64B    |        636      |       75
>             256B    |        892      |       90
>            1024B    |       3262      |      147
> 
> The data shows a parabolic curve of performance for the area map
> allocator. This is due to the memmove operation being the dominant cost
> with the lower object sizes as more objects are packed in a chunk and at
> higher object sizes, the traversal of the chunk slots is the dominating
> cost. The bitmap allocator suffers this problem as well. The above data
> shows the inability to scale for the allocation path with the area map
> allocator and that the bitmap allocator demonstrates consistent
> performance in general.
> 
> The second problem of additional scanning can result in the area map
> allocator completing in 52 minutes when trying to allocate 1 million
> 4-byte objects with 8-byte alignment. The same workload takes
> approximately 16 seconds to complete for the bitmap allocator.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Once you fix that init thing and the comment thing you can add

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
