Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 689946B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 03:29:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so34756571wmw.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 00:29:41 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id e124si9866223lfg.83.2016.05.06.00.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 00:29:39 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id j8so121697466lfd.2
        for <linux-mm@kvack.org>; Fri, 06 May 2016 00:29:39 -0700 (PDT)
Date: Fri, 6 May 2016 10:29:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160506072936.GA6971@node.shutemov.name>
References: <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
 <20160502160042.GC24419@node.shutemov.name>
 <20160502180307.GB12310@redhat.com>
 <20160504191927.095cdd90@t450s.home>
 <20160505143924.GC28755@redhat.com>
 <20160505151110.GA13972@node.shutemov.name>
 <20160505152406.GH28755@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505152406.GH28755@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 05, 2016 at 05:24:06PM +0200, Andrea Arcangeli wrote:
> On Thu, May 05, 2016 at 06:11:10PM +0300, Kirill A. Shutemov wrote:
> > Hm. How total_mapcount equal to NULL wouldn't lead to NULL-pointer
> > dereference inside page_trans_huge_mapcount()?
> 
> Sorry for the confusion, this was still work in progress and then I've
> seen the email from Alex and I sent the last version I had committed
> right away. An earlier version of course had the proper checks for
> NULL but they got wiped as I transitioned from one model to another
> and back.
> 
> > > +				page_move_anon_rmap(old_page, vma, address);
> > 
> > compound_head() is missing, I believe.
> 
> Oh yes, fixed that too.
> 
> 			if (total_mapcount == 1) {
> 				/*
> 				 * The page is all ours. Move it to
> 				 * our anon_vma so the rmap code will
> 				 * not search our parent or siblings.
> 				 * Protected against the rmap code by
> 				 * the page lock.
> 				 */
> 				page_move_anon_rmap(compound_head(old_page),
> 						    vma, address);
> 			}
> 
> 
> If there's no other issue I can git send-email.

I don't see any.

> Then we should look into calling page_move_anon_rmap from THP COWs
> too, hugetlbfs calls it too. I think we probably need to make
> page_move_anon_rmap smarter and optionally let it take the lock for us
> after reading page->mapping first to be sure it's really moving it.
> 
> The question is then if trylock or lock_page should be used, my
> preference would be just trylock.

trylock is probably fine. It's not big deal if we wouldn't move the page
to new anon_vma, just nice-to-have.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
