Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 02BB76B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:24:10 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e35so133192140qge.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:24:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m4si6293645qkc.222.2016.05.05.08.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:24:09 -0700 (PDT)
Date: Thu, 5 May 2016 17:24:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160505152406.GH28755@redhat.com>
References: <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
 <20160502160042.GC24419@node.shutemov.name>
 <20160502180307.GB12310@redhat.com>
 <20160504191927.095cdd90@t450s.home>
 <20160505143924.GC28755@redhat.com>
 <20160505151110.GA13972@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505151110.GA13972@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 05, 2016 at 06:11:10PM +0300, Kirill A. Shutemov wrote:
> Hm. How total_mapcount equal to NULL wouldn't lead to NULL-pointer
> dereference inside page_trans_huge_mapcount()?

Sorry for the confusion, this was still work in progress and then I've
seen the email from Alex and I sent the last version I had committed
right away. An earlier version of course had the proper checks for
NULL but they got wiped as I transitioned from one model to another
and back.

> > +				page_move_anon_rmap(old_page, vma, address);
> 
> compound_head() is missing, I believe.

Oh yes, fixed that too.

			if (total_mapcount == 1) {
				/*
				 * The page is all ours. Move it to
				 * our anon_vma so the rmap code will
				 * not search our parent or siblings.
				 * Protected against the rmap code by
				 * the page lock.
				 */
				page_move_anon_rmap(compound_head(old_page),
						    vma, address);
			}


If there's no other issue I can git send-email.

Then we should look into calling page_move_anon_rmap from THP COWs
too, hugetlbfs calls it too. I think we probably need to make
page_move_anon_rmap smarter and optionally let it take the lock for us
after reading page->mapping first to be sure it's really moving it.

The question is then if trylock or lock_page should be used, my
preference would be just trylock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
