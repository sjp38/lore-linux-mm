Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8F3A6B0284
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:03:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so233326704pfb.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:03:45 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id r9si14311pae.39.2016.06.14.01.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 01:03:44 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 62so12408717pfd.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:03:44 -0700 (PDT)
Date: Tue, 14 Jun 2016 17:03:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160614080343.GA504@swordfish>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox>
 <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox>
 <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
 <20160613044237.GC23754@bbox>
 <20160613051214.GA491@swordfish>
 <CADAEsF8icKGBcCV83BxSc2-pmK46rsZc1wgB8=Y=3m5CnN6K3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF8icKGBcCV83BxSc2-pmK46rsZc1wgB8=Y=3m5CnN6K3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

On (06/13/16 15:49), Ganesh Mahendran wrote:
[..]
> > some parts (of the info above) are already available: zram<ID> maps to
> > pool<ID> name, which maps to a sysfs file name, that can contain the rest.
> > I'm just trying to understand what kind of optimizations we are talking
> > about here and how would timings help... compaction can spin on class
> > lock, for example, if the device in question is busy, etc. etc. on the
> > other hand we have a per-class info in zsmalloc pool stats output, so
> > why not extend it instead of introducing a new debugging interface?
> 
> I've considered adding new interface in /sys/../zsmalloc/ or uasing
> trace_mm_shrink_slab_[start/end] to get such information.
> But none of them can cover all the cases:
> 1) distinguish which zs pool is compacted.
> 2) freed pages of zs_compact(), total freed pages of zs_compact()
> 3) realtime log printed

I'm not against the patch in general, just curious, do you have any
specific optimization in mind? if so, can we start with that optimization
then, otherwise, can we define what type of optimizations this tracing
will boost?

what I'm thinking of, we have a zsmalloc debugfs file, which provides
per-device->per-pool->per-class stats:

cat /sys/kernel/debug/zsmalloc/zram0/classes
 class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable

so the 'missing' thing is just one column, right? the total freed
pages number is already accounted.

thoughts?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
