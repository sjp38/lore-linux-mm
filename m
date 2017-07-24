Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9386B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 17:15:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 184so11931218wmo.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 14:15:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l81si1785291wrc.33.2017.07.24.14.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 14:15:00 -0700 (PDT)
Date: Mon, 24 Jul 2017 17:14:41 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 00/10] percpu: replace percpu area map allocator with
 bitmap allocator
Message-ID: <20170724211440.GD91613@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170718191527.GA4009@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170718191527.GA4009@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Josef,

On Tue, Jul 18, 2017 at 03:15:28PM -0400, Josef Bacik wrote:
 
> Ok so you say that this test is better for the area map allocator, so presumably
> this is worst case for the bitmap allocator?  What does the average case look
> like?

The bitmap allocator should perform relatively consistent in most
allocation schemes. The worst case would be where constant scanning is
required like the allocation scenario of 4-bytes with 8-byte alignment.
As far as average case, I would expect similar performance on average.
These are updated values with v2.

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        310      |     4770
             16B    |        557      |     1325
             64B    |        436      |      273
            256B    |        776      |      131
           1024B    |       3280      |      122

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        490      |       70
             16B    |        515      |       75
             64B    |        610      |       80
            256B    |        950      |      100
           1024B    |       3520      |      200

> Trading 2x allocation latency for a pretty significant free latency
> reduction seems ok, but are we allocating or freeing more?  Are both allocations
> and free's done in performance critical areas, or do allocations only happen in
> performance critical areas, making the increased allocation latency hurt more?

I unfortunately do not have any data to support whether we are
allocating or freeing more in critical areas. I would defer use case
questions to those consuming percpu memory. There is one issue that
stood out though with BPF that is causing the cpu to hang due to the
percpu allocator. This leads me to believe that freeing is of more
concern. I would believe that if allocation latency is a major problem,
it is easier for the user to preallocate than it is for them to manage
delayed freeing.

> And lastly, why are we paying a 2x latency cost?  What is it about the bitmap
> allocator that makes it much worse than the area map allocator?

So it turns out v1 was making poor use of control logic and the
compiler wasn't doing me any favors. I've since done a rather large
refactor with v2 which shows better performance overall. The bitmap
allocator is paying more in that it has to manage metadata that the area
map allocator does not. In the optimal case, the area map allocator is
just an append without any heavy operations.

A worse performing scenario for the area map allocator is when the
second half of a chunk is occupied by a lot of small allocations. In
that case, each allocation has to memmove the rest of the area map. This
scenario is nontrivial to reproduce, so I provide data below for a
similar scenario where the second half of each page is filled.

  Area Map Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |       4118      |     4892
             16B    |       1651      |     1163
             64B    |        598      |      285
            256B    |        771      |      158
           1024B    |       3034      |      160

  Bitmap Allocator:

        Object Size | Alloc Time (ms) | Free Time (ms)
        ----------------------------------------------
              4B    |        481      |       67
             16B    |        506      |       69
             64B    |        636      |       75
            256B    |        892      |       90
           1024B    |       3262      |      147

This shows that in less ideal chunk states, the allocation path can fail
just like the freeing path can with non-ideal deallocation patterns.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
