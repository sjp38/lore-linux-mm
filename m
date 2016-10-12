Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D05C6B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:25:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f193so5199544wmg.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:25:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ql1si9017517wjc.85.2016.10.12.01.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 01:25:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 123so1213737wmb.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:25:40 -0700 (PDT)
Date: Wed, 12 Oct 2016 10:25:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
Message-ID: <20161012082538.GC17128@dhcp22.suse.cz>
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
 <20161012065332.GA9504@dhcp22.suse.cz>
 <57FDE531.7060003@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FDE531.7060003@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On Wed 12-10-16 15:24:33, zijun_hu wrote:
> On 10/12/2016 02:53 PM, Michal Hocko wrote:
> > On Wed 12-10-16 08:28:17, zijun_hu wrote:
> >> On 2016/10/12 1:22, Michal Hocko wrote:
> >>> On Tue 11-10-16 21:24:50, zijun_hu wrote:
> >>>> From: zijun_hu <zijun_hu@htc.com>
> >>>>
> >>>> the LSB of a chunk->map element is used for free/in-use flag of a area
> >>>> and the other bits for offset, the sufficient and necessary condition of
> >>>> this usage is that both size and alignment of a area must be even numbers
> >>>> however, pcpu_alloc() doesn't force its @align parameter a even number
> >>>> explicitly, so a odd @align maybe causes a series of errors, see below
> >>>> example for concrete descriptions.
> >>>
> >>> Is or was there any user who would use a different than even (or power of 2)
> >>> alighment? If not is this really worth handling?
> >>>
> >>
> >> it seems only a power of 2 alignment except 1 can make sure it work very well,
> >> that is a strict limit, maybe this more strict limit should be checked
> > 
> > I fail to see how any other alignment would actually make any sense
> > what so ever. Look, I am not a maintainer of this code but adding a new
> > code to catch something that doesn't make any sense sounds dubious at
> > best to me.
> > 
> > I could understand this patch if you see a problem and want to prevent
> > it from repeating bug doing these kind of changes just in case sounds
> > like a bad idea.
> > 
> 
> thanks for your reply
> 
> should we have a generic discussion whether such patches which considers
> many boundary or rare conditions are necessary.

In general, I believe that kernel internal interfaces which have no
userspace exposure shouldn't be cluttered with sanity checks.

> i found the following code segments in mm/vmalloc.c
> static struct vmap_area *alloc_vmap_area(unsigned long size,
>                                 unsigned long align,
>                                 unsigned long vstart, unsigned long vend,
>                                 int node, gfp_t gfp_mask)
> {
> ...
> 
>         BUG_ON(!size);
>         BUG_ON(offset_in_page(size));
>         BUG_ON(!is_power_of_2(align));

See a recent Linus rant about BUG_ONs. These BUG_ONs are quite old and
from a quick look they are even unnecessary. So rather than adding more
of those, I think removing those that are not needed is much more
preferred.
 
> should we make below declarations as conventions
> 1) when we say 'alignment', it means align to a power of 2 value
>    for example, aligning value @v to @b implicit @v is power of 2
>    , align 10 to 4 is 12

alignment other than power-of-two makes only very limited sense to me.

> 2) when we say 'round value @v up/down to boundary @b', it means the 
>    result is a times of @b,  it don't requires @b is a power of 2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
