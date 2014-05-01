Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 343E16B0037
	for <linux-mm@kvack.org>; Thu,  1 May 2014 17:02:36 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id w10so2540516pde.19
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:02:35 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id pb4si21923536pac.113.2014.05.01.14.02.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 14:02:35 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so4219563pad.24
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:02:34 -0700 (PDT)
Date: Thu, 1 May 2014 14:02:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, migration: add destination page freeing
 callback
In-Reply-To: <5361d71e.236ec20a.1b3d.ffffc8aeSMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.DEB.2.02.1405011402160.32268@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <5361d71e.236ec20a.1b3d.ffffc8aeSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 May 2014, Naoya Horiguchi wrote:

> Looks good to me.
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 

Thanks!

> I have one comment below ...
> 
> [snip]
> 
> > @@ -1056,20 +1059,30 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> >  	if (!page_mapped(hpage))
> >  		rc = move_to_new_page(new_hpage, hpage, 1, mode);
> >  
> > -	if (rc)
> > +	if (rc != MIGRATEPAGE_SUCCESS)
> >  		remove_migration_ptes(hpage, hpage);
> >  
> >  	if (anon_vma)
> >  		put_anon_vma(anon_vma);
> >  
> > -	if (!rc)
> > +	if (rc == MIGRATEPAGE_SUCCESS)
> >  		hugetlb_cgroup_migrate(hpage, new_hpage);
> >  
> >  	unlock_page(hpage);
> >  out:
> >  	if (rc != -EAGAIN)
> >  		putback_active_hugepage(hpage);
> > -	put_page(new_hpage);
> > +
> > +	/*
> > +	 * If migration was not successful and there's a freeing callback, use
> > +	 * it.  Otherwise, put_page() will drop the reference grabbed during
> > +	 * isolation.
> > +	 */
> 
> This comment is true both for normal page and huge page, and people more likely
> to see unmap_and_move() at first, so this had better be (also) in unmap_and_move().
> 

Ok!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
