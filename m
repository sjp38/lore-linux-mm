Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BB0A06B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 18:38:08 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id 4so79187213pfd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 15:38:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ol15si16785473pab.45.2016.03.31.15.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 15:38:07 -0700 (PDT)
Date: Thu, 31 Mar 2016 15:38:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/highmem: simplify is_highmem()
Message-Id: <20160331153806.960c2299698d40a625809e91@linux-foundation.org>
In-Reply-To: <20160330092438.GG30729@dhcp22.suse.cz>
References: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
	<20160330092438.GG30729@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chanho Min <chanho.min@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Dan Williams <dan.j.williams@intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gunho Lee <gunho.lee@lge.com>

On Wed, 30 Mar 2016 11:24:38 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 30-03-16 13:43:42, Chanho Min wrote:
> > The is_highmem() is can be simplified by use of is_highmem_idx().
> > This patch removes redundant code and will make it easier to maintain
> > if the zone policy is changed or a new zone is added.
> > 
> > Signed-off-by: Chanho Min <chanho.min@lge.com>
> > ---
> >  include/linux/mmzone.h |    5 +----
> >  1 file changed, 1 insertion(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index e23a9e7..9ac90c3 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -817,10 +817,7 @@ static inline int is_highmem_idx(enum zone_type idx)
> >  static inline int is_highmem(struct zone *zone)
> >  {
> >  #ifdef CONFIG_HIGHMEM
> > -	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> > -	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
> > -	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
> > -		zone_movable_is_highmem());
> > +	return is_highmem_idx(zone_idx(zone));
> 
> This will reintroduce the pointer arithmetic removed by ddc81ed2c5d4
> ("remove sparse warning for mmzone.h") AFAICS. I have no idea how much
> that matters though. The mentioned commit doesn't tell much about saves
> except for
> "
> 	On X86_32 this saves a sar, but code size increases by one byte per
>         is_highmem() use due to 32-bit cmps rather than 16 bit cmps.
> "

The patch shrinks my i386 allmodconfig page_alloc.o by 50 bytes, and
that has just two is_highmem() callsites.  So I think it's OK from a
code-size and performance piont of view

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
