Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13BCE6B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:13:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d193so159698840pgc.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:13:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l16si2378483pfb.191.2017.07.24.13.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 13:13:53 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:13:42 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 08/10] percpu: change the number of pages marked in the
 first_chunk bitmaps
Message-ID: <20170724201341.GC91613@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-9-dennisz@fb.com>
 <20170717192602.GB585283@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170717192602.GB585283@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 17, 2017 at 03:26:02PM -0400, Tejun Heo wrote:
> > This patch changes the allocator to only mark allocated pages for the
> > region the population bitmap is used for. Prior, the bitmap was marked
> > completely used as the first chunk was allocated and immutable. This is
> > misleading because the first chunk may not be completely filled.
> > Additionally, with moving the base_addr up in the previous patch, the
> > population map no longer corresponds to what is being checked.
> 
> This in isolation makes sense although the rationale isn't clear from
> the description.  Is it a mere cleanup or is this needed to enable
> further changes?

This change is clean up to make sure there is no misunderstanding
between what part of the bitmap actually is meaningful and the actual
size of the bitmap.


> > pcpu_nr_empty_pop_pages is used to ensure there are a handful of free
> > pages around to serve atomic allocations. A new field, nr_empty_pop_pages,
> > is added to the pcpu_chunk struct to keep track of the number of empty
> > pages. This field is needed as the number of empty populated pages is
> > globally kept track of and deltas are used to update it. This new field
> > is exposed in percpu_stats.
> 
> But I can't see why this is being added or why this is in the same
> patch with the previous change.
> 

I've split this out into another patch.

> > Now that chunk->nr_pages is the number of pages the chunk is serving, it
> > is nice to use this in the work function for population and freeing of
> > chunks rather than use the global variable pcpu_unit_pages.
> 
> The same goes for the above part.  It's fine to collect misc changes
> into a patch when they're trivial and related in some ways but the
> content of this patch seems a bit random.

This change is needed in the same patch because chunk->nr_populated no
longer is set to pcpu_unit_pages. The checks would check the dynamic
chunk and then try to populate. Those checks should be checking against
the size of the region being served which is nr_pages.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
