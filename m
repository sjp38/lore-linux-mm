Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7859F6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:11:09 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 2so7686796ybt.7
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:11:09 -0700 (PDT)
Received: from mail-yb0-x22c.google.com (mail-yb0-x22c.google.com. [2607:f8b0:4002:c09::22c])
        by mx.google.com with ESMTPS id w81si157447yww.327.2017.07.19.12.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 12:11:07 -0700 (PDT)
Received: by mail-yb0-x22c.google.com with SMTP id c127so1480782ybf.4
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:11:07 -0700 (PDT)
Date: Wed, 19 Jul 2017 19:11:06 +0000
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 09/10] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170719191105.GC23135@li70-116.members.linode.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-10-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170716022315.19892-10-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:14PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The percpu memory allocator is experiencing scalability issues when
> allocating and freeing large numbers of counters as in BPF.
> Additionally, there is a corner case where iteration is triggered over
> all chunks if the contig_hint is the right size, but wrong alignment.
> 
> Implementation:
> This patch removes the area map allocator in favor of a bitmap allocator
> backed by metadata blocks. The primary goal is to provide consistency
> in performance and memory footprint with a focus on small allocations
> (< 64 bytes). The bitmap removes the heavy memmove from the freeing
> critical path and provides a consistent memory footprint. The metadata
> blocks provide a bound on the amount of scanning required by maintaining
> a set of hints.
> 
> The chunks previously were managed by free_size, a value maintained in
> bytes. Now, the chunks are managed in terms of bits, which is just a
> scaled value of free_size down by PCPU_MIN_ALLOC_SIZE.
> 
> There is one caveat with this implementation. In an effort to make
> freeing fast, the only time metadata is updated on the free path is if a
> whole block becomes free or the freed area spans across metadata blocks.
> This causes the chunka??s contig_hint to be potentially smaller than what
> it could allocate by up to a block. If the chunka??s contig_hint is
> smaller than a block, a check occurs and the hint is kept accurate.
> Metadata is always kept accurate on allocation and therefore the
> situation where a chunk has a larger contig_hint than available will
> never occur.
> 
> Evaluation:
> I have primarily done testing against a simple workload of allocation of
> 1 million objects of varying size. Deallocation was done by in order,
> alternating, and in reverse. These numbers were collected after rebasing
> ontop of a80099a152. I present the worst-case numbers here:
> 
>   Area Map Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        335      |     4960
>              16B    |        485      |     1150
>              64B    |        445      |      280
>             128B    |        505      |      177
>            1024B    |       3385      |      140
> 
>   Bitmap Allocator:
> 
>         Object Size | Alloc Time (ms) | Free Time (ms)
>         ----------------------------------------------
>               4B    |        725      |       70
>              16B    |        760      |       70
>              64B    |        855      |       80
>             128B    |        910      |       90
>            1024B    |       3770      |      260
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
> here is optimal for the area map allocator. The second problem of
> additional scanning can result in the area map allocator completing in
> 52 minutes. The same workload takes only 14 seconds to complete for the
> bitmap allocator. This was produced under a more contrived scenario of
> allocating 1 milion 4-byte objects with 8-byte alignment.
> 

This was a bear to review, I feel like it could be split into a few smaller
pieces.  You are changing hinting, allocating/freeing, and how you find chunks.
Those seem like good logical divisions to me.  Overall the design seems sound
and I didn't spot any major problems.  Once you've split them up I'll do another
thorough comb through and then add my reviewed by.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
