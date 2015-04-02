Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDF66B006E
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 20:09:02 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so66797530pad.3
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 17:09:02 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id gp4si4878404pbc.196.2015.04.01.17.09.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 17:09:00 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so70877145pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 17:09:00 -0700 (PDT)
Date: Wed, 1 Apr 2015 17:08:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: get page_cache_get_speculative() work on tail
 pages
In-Reply-To: <20150401235651.GA20597@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1504011705310.6939@eggly.anvils>
References: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1504011617300.6431@eggly.anvils> <20150401235651.GA20597@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:
> On Wed, Apr 01, 2015 at 04:21:30PM -0700, Hugh Dickins wrote:
> > On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:
> > 
> > > Generic RCU fast GUP rely on page_cache_get_speculative() to obtain pin
> > > on pte-mapped page.  As pointed by Aneesh during review of my compound
> > > pages refcounting rework, page_cache_get_speculative() would fail on
> > > pte-mapped tail page, since tail pages always have page->_count == 0.
> > > 
> > > That means we would never be able to successfully obtain pin on
> > > pte-mapped tail page via generic RCU fast GUP.
> > > 
> > > But the problem is not exclusive to my patchset. In current kernel some
> > > drivers (sound, for instance) already map compound pages with PTEs.
> > 
> > Hah, you were sending this as I was replying to the original thread.
> > 
> > Do we care if fast gup fails on some hardware driver's compound pages?
> > I don't think we do, and it would be better not to complicate the
> > low-level page_cache_get_speculative for them.
> 
> Fair enough :-/
> 
> I'll check tomorrow if it will look more reasonable on gup_pte_range()
> level, rather than page_cache_get_speculative().

But we don't need it on the (fast) gup_pte_range() level either, do we?
Or do you have THP changes in mmotm which are now demanding this?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
