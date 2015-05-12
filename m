Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 33F326B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:28:13 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so2231478pac.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:28:12 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y5si21656620pbt.39.2015.05.12.02.28.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:28:12 -0700 (PDT)
Date: Tue, 12 May 2015 12:27:47 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
Message-ID: <20150512092747.GC17628@esperanza>
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
 <20150511093652.GA11257@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150511093652.GA11257@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 12:36:52PM +0300, Kirill A. Shutemov wrote:
> On Mon, May 11, 2015 at 10:51:17AM +0300, Vladimir Davydov wrote:
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index 5e7c4f50a644..a529e0a35fe9 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -320,7 +320,8 @@ PAGEFLAG(Idle, idle)
> >  
> >  static inline int PageAnon(struct page *page)
> >  {
> > -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> > +	return ((unsigned long)READ_ONCE(page->mapping) &
> > +		PAGE_MAPPING_ANON) != 0;
> 
> Why do we need this? Write side should be enough to get this
> deterministic.

Yeah, this seems to be completely redundant, my bad.

> 
> >  }
> >  
> >  #ifdef CONFIG_KSM
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index eca7416f55d7..aa60c63704e6 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -958,7 +958,7 @@ void page_move_anon_rmap(struct page *page,
> >  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
> >  
> >  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > -	page->mapping = (struct address_space *) anon_vma;
> > +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
> >  }
> >  
> >  /**
> > @@ -987,7 +987,7 @@ static void __page_set_anon_rmap(struct page *page,
> >  		anon_vma = anon_vma->root;
> >  
> >  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > -	page->mapping = (struct address_space *) anon_vma;
> > +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
> >  	page->index = linear_page_index(vma, address);
> 
> No need: we don't hit this code if page is already PageAnon().

Agree.

> 
> >  }
> >  
> > @@ -1579,7 +1579,7 @@ static void __hugepage_set_anon_rmap(struct page *page,
> >  		anon_vma = anon_vma->root;
> >  
> >  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > -	page->mapping = (struct address_space *) anon_vma;
> > +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
> 
> Ditto.

Agree.

So we do need this eventually, don't we? Frankly, I doubted that,
because the fact that a compiler can do such wicked things really scares
me :-/

All right then, I'll resend the patch with your comments addressed.
Thank you for spending your time reviewing it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
