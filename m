Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id ED9956B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:58:42 -0400 (EDT)
Received: by wegp1 with SMTP id p1so2399703weg.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:58:42 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gl10si2000701wib.104.2015.03.17.01.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 01:58:41 -0700 (PDT)
Received: by wixw10 with SMTP id w10so43240410wix.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:58:40 -0700 (PDT)
Date: Tue, 17 Mar 2015 09:58:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: hangs in free_pages_prepare
Message-ID: <20150317085838.GA28112@dhcp22.suse.cz>
References: <54FB4590.20102@oracle.com>
 <20150308203838.GA10442@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150308203838.GA10442@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm >> Andrew Morton" <akpm@linux-foundation.org>

On Sun 08-03-15 16:38:38, Michal Hocko wrote:
> On Sat 07-03-15 13:38:08, Sasha Levin wrote:
> [...]
> > [ 1573.730097] ? kasan_free_pages (mm/kasan/kasan.c:301)
> > [ 1573.788680] free_pages_prepare (mm/page_alloc.c:791)
> > [ 1573.788680] ? free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
> > [ 1573.788680] free_hot_cold_page (mm/page_alloc.c:1543)
> > [ 1573.788680] __free_pages (mm/page_alloc.c:2957)
> > [ 1573.788680] ? __vunmap (mm/vmalloc.c:1460 (discriminator 2))
> > [ 1573.788680] __vunmap (mm/vmalloc.c:1460 (discriminator 2))
> 
> __vunmap is doing:
>                 for (i = 0; i < area->nr_pages; i++) {
>                         struct page *page = area->pages[i];
> 
>                         BUG_ON(!page);
>                         __free_page(page);
>                 }
> 
> is it possible that nr_pages is a huge number (a large vmalloc area)? I
> do not see any cond_resched down __free_page path at least. vfree
> delayes the call to workqueue when called from irq context and vunmap is
> marked as might_sleep). So to me it looks like it would be safe. Something
> for vmalloc familiar people, though.

Hmm, just looked into the git log and it seems that there are/were
some callers of vfree with spinlock held (e.g. 9265f1d0c759 (GFS2:
gfs2_dir_get_hash_table(): avoiding deferred vfree() is easy here...))
and who knows how many others like that we have so cond_resched here is
no-no.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
