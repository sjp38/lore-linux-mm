Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3376B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:13:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d193so15331120pgc.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:13:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m29si683464pgn.176.2017.07.19.15.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 15:13:28 -0700 (PDT)
Date: Wed, 19 Jul 2017 18:13:14 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 09/10] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170719221313.GB92176@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-10-dennisz@fb.com>
 <20170719191635.GD23135@li70-116.members.linode.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170719191635.GD23135@li70-116.members.linode.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Josef,

Thanks for taking a look at my code.

On Wed, Jul 19, 2017 at 07:16:35PM +0000, Josef Bacik wrote:
> 
> Actually I decided I do want to complain about this.  Have you considered making
> chunks statically sized, like slab does?  We could avoid this whole bound_map
> thing completely and save quite a few cycles trying to figure out how big our
> allocation was.  Thanks,

I did consider something along the lines of a slab allocator, but
ultimately utilization and fragmentation were why I decided against it.

Percpu memory is handled by giving each cpu its own copy of the object
to use. This means cpus can avoid cache coherence when accessing and
manipulating the object. To do this, the percpu allocator creates chunks
to serve each allocation out of. Because each cpu has its own copy, there
is a high cost for having each chunk lying around (and this memory in
general).

With slab allocation, it takes liberty in caching often used sizes and
accepting internal fragmentation for performance. Unfortunately, the
percpu memory allocator does not necessarily know what is going to get
allocated. It would need to keep many slabs around to serve each
allocation which can be quite expensive. In the worst-case, long living
percpu allocations can keep entire slabs alive as there is no way to
perform consolidation once addresses are given out. Additionally, any
internal fragmentation caused by ill-fit objects is amplified by the
number of possible cpus.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
