Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A81F96B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:46:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v76so76214628qka.5
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:46:54 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id 58si15502057qtw.118.2017.07.17.09.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 09:46:53 -0700 (PDT)
Received: by mail-qk0-x236.google.com with SMTP id p73so61991289qka.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:46:53 -0700 (PDT)
Date: Mon, 17 Jul 2017 12:46:50 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 05/10] percpu: change reserved_size to end page aligned
Message-ID: <20170717164650.GJ3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-6-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-6-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hello,

On Sat, Jul 15, 2017 at 10:23:10PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Preparatory patch to modify the first chunk's static_size +
> reserved_size to end page aligned. The first chunk has a unique
> allocation scheme overlaying the static, reserved, and dynamic regions.
> The other regions of each chunk are reserved or hidden. The bitmap
> allocator would have to allocate in the bitmap the static region to
> replicate this. By having the reserved region to end page aligned, the
> metadata overhead can be saved. The consequence is that up to an
> additional page of memory will be allocated to the reserved region that
> primarily serves static percpu variables.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Sans the build warnings, generally looks good to me.  Some nits asnd
one question below.

> +/*

Should be /**

> + * pcpu_align_reserved_region - page align the end of the reserved region
> + * @static_size: the static region size
> + * @reserved_size: the minimum reserved region size
> + *
> + * This function calculates the size of the reserved region required to
> + * make the reserved region end page aligned.
> + *
> + * Percpu memory offers a maximum alignment of PAGE_SIZE.  Aligning this
> + * minimizes the metadata overhead of overlapping the static, reserved,
> + * and dynamic regions by allowing the metadata for the static region to
> + * not be allocated.  This lets the base_addr be moved up to a page
> + * aligned address and disregard the static region as offsets are allocated.
> + * The beginning of the reserved region will overlap with the static
> + * region if the end of the static region is not page aligned.

Heh, that was pretty difficult to parse, but here's my question.  So,
we're expanding reserved area so that its end aligns to page boundary
which is completely fine.  We may end up with reserved area which is a
bit larger than specified but no big deal.  However, we can't do the
same thing with the boundary between the static and reserved chunks,
so instead we pull down the start of the reserved area and mark off
the overwrapping area, which is fine too.

My question is why we're doing one thing for the end of reserved area
while we need to do a different thing for the beginning of it.  Can't
we do the same thing in both cases?  ie. for the both boundaries
between static and reserved, and reserved and dynamic, pull down the
start to the page boundary and mark the overlapping areas used?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
