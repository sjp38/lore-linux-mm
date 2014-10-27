Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2271D6B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:17:35 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id x3so1495504qcv.4
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 07:17:34 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id h3si20918701qan.61.2014.10.27.07.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 07:17:33 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id b13so4242558qcw.6
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 07:17:33 -0700 (PDT)
Date: Mon, 27 Oct 2014 10:17:30 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] mm: memblock: change default cnt for regions from 1 to 0
Message-ID: <20141027141730.GL4436@htj.dyndns.org>
References: <1414083413-61756-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <20141023121840.f88439912f23a3c2a01eb54f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023121840.f88439912f23a3c2a01eb54f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>

Hello,

On Thu, Oct 23, 2014 at 12:18:40PM -0700, Andrew Morton wrote:
> On Thu, 23 Oct 2014 17:56:53 +0100 Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com> wrote:
> 
> > The default region counts are set to 1 with a comment saying empty
> > dummy entry.
> > 
> > If this is a dummy entry, should this be changed to 0?

My memory is hazy now but I'm pretty sure there's a bunch of stuff
assuming that the array is never empty.

> > We have faced this in mips/kernel/setup.c arch_mem_init.
> > 
> > cma uses memblock. But even with cma disabled.
> > The for_each_memblock(reserved, reg) goes inside the loop.
> > Even without any reserved regions.

Does that matter?  It's a zero-length reservation.

> > Traced it to the following, when the macro
> > for_each_memblock(memblock_type, region) is used.
> > 
> > It expands to add the cnt variable.
> > 
> > for (region = memblock.memblock_type.regions; 		\
> > 	region < (memblock.memblock_type.regions + memblock.memblock_type.cnt); \
> > 	region++)
> > 
> > In the corner case, that there are no reserved regions.
> > Due to the default 1 value of cnt.
> > The loop under for_each_memblock still runs once.
> > 
> > Even when there is no reserved region.
> > 
> > Is this by design? or unintentional?

It's by design.

> > It might be that this loop runs an extra time every instance out there?

The first actual entry replaces the dummy one and the last removal
makes the entry dummy again, so the dummy one exists iff that's the
only entry.  I don't recall the exact details right now but the choice
was an intentional one.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
