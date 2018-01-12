Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92946B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:43:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h20so2394888wrf.22
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:43:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v70si1409849wmd.97.2018.01.11.16.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 16:43:18 -0800 (PST)
Date: Thu, 11 Jan 2018 16:43:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_ext.c: Make page_ext_init a noop when
 CONFIG_PAGE_EXTENSION but nothing uses it
Message-Id: <20180111164315.ca96f3ca533ee6684269d7f5@linux-foundation.org>
In-Reply-To: <20180105130235.GA21241@techadventures.net>
References: <20180105130235.GA21241@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, jaewon31.kim@samsung.com

On Fri, 5 Jan 2018 14:02:35 +0100 Oscar Salvador <osalvador@techadventures.net> wrote:

> static struct page_ext_operations *page_ext_ops[] always contains debug_guardpage_ops,
> 
> static struct page_ext_operations *page_ext_ops[] = {
>         &debug_guardpage_ops,
>  #ifdef CONFIG_PAGE_OWNER
>         &page_owner_ops,
>  #endif
> ...
> }
> 
> but for it to work, CONFIG_DEBUG_PAGEALLOC must be enabled first.
> If someone has CONFIG_PAGE_EXTENSION, but has none of its users,
> eg: (CONFIG_PAGE_OWNER, CONFIG_DEBUG_PAGEALLOC, CONFIG_IDLE_PAGE_TRACKING), we can shrink page_ext_init()
> to a simple retq.
> 
> $ size vmlinux  (before patch)
>    text	   data	    bss	    dec	    hex	filename
> 14356698	5681582	1687748	21726028	14b834c	vmlinux
> 
> $ size vmlinux  (after patch)
>    text	   data	    bss	    dec	    hex	filename
> 14356008	5681538	1687748	21725294	14b806e	vmlinux
> 
> On the other hand, it might does not even make sense, since if someone
> enables CONFIG_PAGE_EXTENSION, I would expect him to enable also at least
> one of its users, but I wanted to see what you guys think.

Presumably the CONFIG_PAGE_EXTENSION users should `select'
CONFIG_PAGE_EXTENSION so the situation doesn't arise.

(or does it?  I have a vague memory that if CONFIG_A selects CONFIG_B
and you then set CONFIG_A=n, CONFIG_B remains enabled?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
