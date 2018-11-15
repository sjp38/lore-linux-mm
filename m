Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 764DE6B05F0
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:37:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m1-v6so15385554plb.13
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:37:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w3-v6si18921430plb.154.2018.11.15.13.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 13:37:38 -0800 (PST)
Date: Thu, 15 Nov 2018 13:37:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-Id: <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
In-Reply-To: <20181114235040.36180-1-richard.weiyang@gmail.com>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Nov 2018 07:50:40 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> For one zone, there are three digits to describe its space range:
> 
>     spanned_pages
>     present_pages
>     managed_pages
> 
> The detailed meaning is written in include/linux/mmzone.h. This patch
> concerns about the last two.
> 
>     present_pages is physical pages existing within the zone
>     managed_pages is present pages managed by the buddy system
> 
> >From the definition, managed_pages is a more strict condition than
> present_pages.
> 
> There are two functions using zone's present_pages as a boundary:
> 
>     populated_zone()
>     for_each_populated_zone()
> 
> By going through the kernel tree, most of their users are willing to
> access pages managed by the buddy system, which means it is more exact
> to check zone's managed_pages for a validation.
> 
> This patch replaces those checks on present_pages to managed_pages by:
> 
>     * change for_each_populated_zone() to for_each_managed_zone()
>     * convert for_each_populated_zone() to for_each_zone() and check
>       populated_zone() where is necessary
>     * change populated_zone() to managed_zone() at proper places
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 
> ---
> 
> Michal, after last mail, I did one more thing to replace
> populated_zone() with managed_zone() at proper places.
> 
> One thing I am not sure is those places in mm/compaction.c. I have
> chaged them. If not, please let me know.
> 
> BTW, I did a boot up test with the patched kernel and looks smooth.

Seems sensible, but a bit scary.  A basic boot test is unlikely to
expose subtle gremlins.

Worse, the situations in which managed_zone() != populated_zone() are
rare(?), so it will take a long time for problems to be discovered, I
expect.

I'll toss it in there for now, let's see who breaks :(
