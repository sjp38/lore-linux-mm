Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0C856B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:43:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r103so32946532wrb.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 02:43:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si1464138wrz.264.2017.06.28.02.43.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 02:43:12 -0700 (PDT)
Date: Wed, 28 Jun 2017 11:43:09 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 0/4] mm/hotplug: make hotplug memory_block alligned
Message-ID: <20170628094309.GD5225@dhcp22.suse.cz>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170626074635.GB11534@dhcp22.suse.cz>
 <20170627021335.GA62718@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627021335.GA62718@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org

On Tue 27-06-17 10:13:35, Wei Yang wrote:
> On Mon, Jun 26, 2017 at 09:46:35AM +0200, Michal Hocko wrote:
> >On Sun 25-06-17 10:52:23, Wei Yang wrote:
> >> Michal & all
> >> 
> >> Previously we found the hotplug range is mem_section aligned instead of
> >> memory_block.
> >> 
> >> Here is several draft patches to fix that. To make sure I am getting your
> >> point correctly, I post it here before further investigation.
> >
> >This description doesn't explain what the problem is and why do we want
> >to fix it. Before diving into the code and review changes it would help
> >a lot to give a short introduction and explain your intention and your
> >assumptions you base your changes on.
> >
> >So please start with a highlevel description first.
> >
> 
> Here is the high level description in my mind, glad to see your comment.
> 
> 
> The minimum unit of memory hotplug is memory_block instead of mem_section.
> While in current implementation, we see several concept misunderstanding.
> 
> For example:
> 1. The alignment check is based on mem_section instead of memory_block
> 2. Online memory range on section base instead of memory_block base
> 
> Even memory_block and mem_section are close related, they are two concepts. It
> is possible to initialize and register them respectively.
> 
> For example:
> 1. In __add_section(), it tries to register these two in one place.
> 
> This patch generally does the following:
> 1. Aligned the range with memory_block
> 2. Online rage with memory_block base
> 3. Split the registration of memory_block and mem_section

OK this is slightly better but from a quick glance over cumulative diff
(sorry I didn't have time to look at separate patches yet) you only go
half way through there. E.g. register_new_memory still uses section_nr.
Basically would I would love to see is to make section implementation
details and get it out of any hotplug APIs. Sections are a sparse
concept and they should stay there and in few hotplug functions which
talk to sparse.

Also you have surely noticed that this area is full of subtle code so it
will take a lot of testing to uncover subtle dependencies. I remember
hitting many of them while touching this area. I would encourage you to
read previous discussions for the rework to see which different setups
broke and why.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
