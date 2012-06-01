Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 7F6586B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 05:08:35 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3185426dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 02:08:34 -0700 (PDT)
Date: Fri, 1 Jun 2012 02:08:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <4FC88299.1040707@gmail.com>
Message-ID: <alpine.LSU.2.00.1206010204150.8697@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <4FC88299.1040707@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 1 Jun 2012, KOSAKI Motohiro wrote:
> >   	mlock_migrate_page(newpage, page);
> > --- 3.4.0+/mm/page-writeback.c	2012-05-29 08:09:58.304806782 -0700
> > +++ linux/mm/page-writeback.c	2012-06-01 00:23:43.984116973 -0700
> > @@ -1987,7 +1987,10 @@ int __set_page_dirty_nobuffers(struct pa
> >   		mapping2 = page_mapping(page);
> >   		if (mapping2) { /* Race with truncate? */
> >   			BUG_ON(mapping2 != mapping);
> > -			WARN_ON_ONCE(!PagePrivate(page)&&
> > !PageUptodate(page));
> > +			if (WARN_ON(!PagePrivate(page)&&
> > !PageUptodate(page)))
> > +				print_symbol(KERN_WARNING
> > +				    "mapping->a_ops->writepage: %s\n",
> > +				    (unsigned
> > long)mapping->a_ops->writepage);
> 
> type mismatch?

I don't think so: I just copied from print_bad_pte().
Probably you're reading "printk" where it's "print_symbol"?

> I guess you want %pf or %pF.

I expect there is new-fangled %pMagic that can do it too, yes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
