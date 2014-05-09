Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AAABD6B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 15:54:29 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so644037pad.39
        for <linux-mm@kvack.org>; Fri, 09 May 2014 12:54:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ud10si2735830pbc.417.2014.05.09.12.54.28
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 12:54:28 -0700 (PDT)
Date: Fri, 9 May 2014 12:54:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use a irq-safe __mod_zone_page_state in
 mlocked_vma_newpage()
Message-Id: <20140509125426.e585b751a81bfcc96b6b8b88@linux-foundation.org>
In-Reply-To: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
References: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: cl@linux.com, mhocko@suse.cz, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, zhangyanfei@cn.fujitsu.com, hanpt@linux.vnet.ibm.com, sasha.levin@oracle.com, oleg@redhat.com, fabf@skynet.be, mgorman@suse.de, aarcange@redhat.com, cldu@marvell.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 May 2014 00:16:48 +0800 Jianyu Zhan <nasa4836@gmail.com> wrote:

> mlocked_vma_newpage() is only called in fault path by
> page_add_new_anon_rmap(), which is called on a *new* page.
> And such page is initially only visible via the pagetables, and the
> pte is locked while calling page_add_new_anon_rmap(), so we need not
> use an irq-safe mod_zone_page_state() here, using a light-weight version
> __mod_zone_page_state() would be OK.
> 
> ...
>
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -196,7 +196,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
>  		return 0;
>  
>  	if (!TestSetPageMlocked(page)) {
> -		mod_zone_page_state(page_zone(page), NR_MLOCK,
> +		__mod_zone_page_state(page_zone(page), NR_MLOCK,
>  				    hpage_nr_pages(page));
>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>  	}

The comment over __mod_zone_page_state() says "For use when we know
that interrupts are disabled".  But that is not the case here.

Please fix this up, probably by altering the __mod_zone_page_state()
documentation.


Your proposed change to (the very poorly named) mlocked_vma_newpage()
makes that function more dangerous - people might add new callsites
without knowing that they're adding races.  This risk can be reduced by

a) adding documentation explaining why __mod_zone_page_state() is
   used and why it is safe and

b) moving mlocked_vma_newpage() out of internal.h and placing it in
   mm/rmap.c immediately before page_add_new_anon_rmap().  Or, probably
   better, by removing mlocked_vma_newpage() altogether and open-coding
   its logic into page_add_new_anon_rmap().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
