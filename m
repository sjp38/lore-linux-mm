Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2656B038A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 11:08:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g8so12101463wmg.7
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 08:08:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si19254877wru.49.2017.03.19.08.08.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 08:08:27 -0700 (PDT)
Date: Sun, 19 Mar 2017 11:08:22 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use BITS_PER_LONG to unify the definition in
 page->flags
Message-ID: <20170319150822.GC12414@dhcp22.suse.cz>
References: <20170318003914.24839-1-richard.weiyang@gmail.com>
 <20170319143012.GB12414@dhcp22.suse.cz>
 <20170319150345.GA34657@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170319150345.GA34657@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 19-03-17 23:03:45, Wei Yang wrote:
> On Sun, Mar 19, 2017 at 10:30:13AM -0400, Michal Hocko wrote:
> >On Sat 18-03-17 08:39:14, Wei Yang wrote:
> >> The field page->flags is defined as unsigned long and is divided into
> >> several parts to store different information of the page, like section,
> >> node, zone. Which means all parts must sit in the one "unsigned
> >> long".
> >> 
> >> BITS_PER_LONG is used in several places to ensure this applies.
> >> 
> >>     #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGEFLAGS
> >>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
> >>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
> >> 
> >> While we use "sizeof(unsigned long) * 8" in the definition of
> >> SECTIONS_PGOFF
> >> 
> >>     #define SECTIONS_PGOFF         ((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> >> 
> >> This may not be that obvious for audience to catch the point.
> >> 
> >> This patch replaces the "sizeof(unsigned long) * 8" with BITS_PER_LONG to
> >> make all this consistent.
> >
> >I am not really sure this is an improvement. page::flags is unsigned
> >long nad the current code reflects that type.
> >
> 
> Hi, Michal
> 
> Glad to hear from you.
> 
> I think the purpose of definition BITS_PER_LONG is more easily to let audience
> know it is the number of bits of type long. If it has no improvement, we don't
> need to define a specific macro .
> 
> And as you could see, several related macros use BITS_PER_LONG in their
> definition. After this change, all of them will have a consistent definition.
> 
> After this change, code looks more neat :-)
> 
> So it looks more reasonable to use this.

I do not think that this is sufficient to justify the change.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
