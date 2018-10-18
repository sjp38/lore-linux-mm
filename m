Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E61C26B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:53:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h24-v6so18692935eda.10
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:53:45 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id t19-v6si9920377edq.195.2018.10.18.07.53.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 07:53:44 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 1B0AB1C1EA5
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 15:53:44 +0100 (IST)
Date: Thu, 18 Oct 2018 15:53:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018145342.GP5819@techsingularity.net>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
 <20181018133917.GO5819@techsingularity.net>
 <20181018141926.zjiebfjcodthvagg@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181018141926.zjiebfjcodthvagg@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 02:19:26PM +0000, Wei Yang wrote:
> On Thu, Oct 18, 2018 at 02:39:17PM +0100, Mel Gorman wrote:
> >On Thu, Oct 18, 2018 at 09:04:29PM +0800, Wei Yang wrote:
> >> This is not necessary to save the pfn to page->private.
> >> 
> >> The pfn could be retrieved by page_to_pfn() directly.
> >> 
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >
> >page_to_pfn is not free which is why it's cached.
> >
> 
> Hi, Mel
> 
> Thanks for your response.
> 
> Not free means the access to mem_section?
> 

That's memory model specific but in some cases yes, it's accessing
mem_section.

> I have thought about the cache thing, so we assume the list is not that
> long, and the cache could hold those page->private for the whole loop?
> 

The intent was to avoid multiple page->pfn translations.

> In my understand, it the cache has limited size, if more data accessed
> the cache will be overwritten.
> 
> And another thing is:
> 
> In case of CONFIG_SPARSEMEM_VMEMMAP, would this be a little different?

Yes because the lookup has a different cost

> Becase we get pfn by a simple addition. Which I think no need to cache
> it?
> 

Because SPARSEMEM_VMEMMAP is not always used but also because it's
harmless to cache even in the SPARSEMEM_VMEMMAP case.

-- 
Mel Gorman
SUSE Labs
