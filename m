Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D942C6B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:43:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c184so5264327wmd.6
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:43:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v14si420249wra.423.2017.07.21.07.43.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Jul 2017 07:43:23 -0700 (PDT)
Date: Fri, 21 Jul 2017 16:43:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm/vmalloc: add a node corresponding to
 cached_hole_size
Message-ID: <20170721144318.GD5944@dhcp22.suse.cz>
References: <1500631301-17444-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20170721113948.GB18303@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170721113948.GB18303@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

On Fri 21-07-17 04:39:48, Matthew Wilcox wrote:
> On Fri, Jul 21, 2017 at 06:01:41PM +0800, Zhaoyang Huang wrote:
> > we just record the cached_hole_size now, which will be used when
> > the criteria meet both of 'free_vmap_cache == NULL' and 'size <
> > cached_hole_size'. However, under above scenario, the search will
> > start from the rb_root and then find the node which just in front
> > of the cached hole.
> > 
> > free_vmap_cache miss:
> >       vmap_area_root
> >           /      \
> >        _next     U
> >         /  (T1)
> >  cached_hole_node
> >        /
> >      ...   (T2)
> >       /
> >     first
> > 
> > vmap_area_list->first->......->cached_hole_node->cached_hole_node.list.next
> >                   |-------(T3)-------| | <<< cached_hole_size >>> |
> > 
> > vmap_area_list->......->cached_hole_node->cached_hole_node.list.next
> >                                | <<< cached_hole_size >>> |
> > 
> > The time cost to search the node now is T = T1 + T2 + T3.
> > The commit add a cached_hole_node here to record the one just in front of
> > the cached_hole_size, which can help to avoid walking the rb tree and
> > the list and make the T = 0;
> 
> Yes, but does this matter in practice?  Are there any workloads where
> this makes a difference?  If so, how much?

I have already asked this and didn't get any response. There were other
versions of a similar patch without a good clarification...

Zhaoyang Huang, please try to formulate the problem you are fixing and
why. While it is clear that you add _an_ optimization it is not really
clear why we need it and whether it might adversely affect existing
workloads. I would rather not touch this code unless there is a strong
justification for it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
