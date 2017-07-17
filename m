Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89D626B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:10:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 1so174078497pfi.14
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:10:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f21si12285pff.143.2017.07.17.12.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:10:50 -0700 (PDT)
Date: Mon, 17 Jul 2017 15:10:26 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 05/10] percpu: change reserved_size to end page aligned
Message-ID: <20170717191025.GA59543@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-6-dennisz@fb.com>
 <20170717164650.GJ3519177@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170717164650.GJ3519177@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Tejun,

On Mon, Jul 17, 2017 at 12:46:50PM -0400, Tejun Heo wrote:

> > +/*
> 
> Should be /**
> 

I have fixed this in v2.

> > + * pcpu_align_reserved_region - page align the end of the reserved region
> > + * @static_size: the static region size
> > + * @reserved_size: the minimum reserved region size
> > + *
> > + * This function calculates the size of the reserved region required to
> > + * make the reserved region end page aligned.
> > + *
> > + * Percpu memory offers a maximum alignment of PAGE_SIZE.  Aligning this
> > + * minimizes the metadata overhead of overlapping the static, reserved,
> > + * and dynamic regions by allowing the metadata for the static region to
> > + * not be allocated.  This lets the base_addr be moved up to a page
> > + * aligned address and disregard the static region as offsets are allocated.
> > + * The beginning of the reserved region will overlap with the static
> > + * region if the end of the static region is not page aligned.
> 
> Heh, that was pretty difficult to parse, but here's my question.  So,
> we're expanding reserved area so that its end aligns to page boundary
> which is completely fine.  We may end up with reserved area which is a
> bit larger than specified but no big deal.  However, we can't do the
> same thing with the boundary between the static and reserved chunks,
> so instead we pull down the start of the reserved area and mark off
> the overwrapping area, which is fine too.
> 
> My question is why we're doing one thing for the end of reserved area
> while we need to do a different thing for the beginning of it.  Can't
> we do the same thing in both cases?  ie. for the both boundaries
> between static and reserved, and reserved and dynamic, pull down the
> start to the page boundary and mark the overlapping areas used?

I don't have a very good answer to why I chose to do it different for
the beginning and then end. I think it came down to wanting to maximize
metadata usage at the time.

A benefit to doing it this way is that it clarifies the number of full
pages that will be allocated to the reserved region. For example, if
the reserved region is set to 8KB and the region is offset due to the
static region, the reserved region would only be given one full page.
The first and last page are shared with the static region and dynamic
region respectively. Expanding the reserved region would allocate two
4KB pages to it + the partial at the beginning if the static region is
not aligned. It's not perfect, but it makes alignment slightly easier to
understand for the reserved region.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
