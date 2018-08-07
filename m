Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7275A6B0271
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:21:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a3-v6so7377516pgv.10
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:21:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14-v6sor415639pgh.317.2018.08.07.08.21.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 08:21:13 -0700 (PDT)
Date: Tue, 7 Aug 2018 08:21:09 -0700
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH] proc: add percpu populated pages count to meminfo
Message-ID: <20180807152107.GB59704@dennisz-mbp.dhcp.thefacebook.com>
References: <20180807005607.53950-1-dennisszhou@gmail.com>
 <0100016514bb069d-a6532c9a-b1ca-4eba-8644-c5b3935e3bd8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016514bb069d-a6532c9a-b1ca-4eba-8644-c5b3935e3bd8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christopher,

On Tue, Aug 07, 2018 at 02:12:06PM +0000, Christopher Lameter wrote:
> On Mon, 6 Aug 2018, Dennis Zhou wrote:
> >  	show_val_kb(m, "VmallocUsed:    ", 0ul);
> >  	show_val_kb(m, "VmallocChunk:   ", 0ul);
> > +	show_val_kb(m, "PercpuPopulated:", pcpu_nr_populated_pages());
> 
> Populated? Can we avoid this for simplicities sake: "Percpu"?

Yeah, I've dropped populated.

> 
> We do not count pages that are not present elsewhere either and those
> counters do not have "populated" in them.

I see, that makes sense. I think I was trying to keep an external
distinction between what we reserve and what we actually have populated
that really isn't useful outside of playing with the allocator itself.

> >  int pcpu_nr_empty_pop_pages;
> >
> > +/*
> > + * The number of populated pages in use by the allocator, protected by
> > + * pcpu_lock.  This number is kept per a unit per chunk (i.e. when a page gets
> > + * allocated/deallocated, it is allocated/deallocated in all units of a chunk
> > + * and increments/decrements this count by 1).
> > + */
> > +static int pcpu_nr_populated;
> 
> pcpu_nr_pages?
> 

I'd rather keep it as pcpu_nr_populated because internally in pcpu_chunk
we maintain nr_pages and nr_populated. That way we keep the same meaning
at the chunk and global level.

Thanks,
Dennis
