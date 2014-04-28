Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 772386B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:23:27 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so5167968eek.32
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:23:26 -0700 (PDT)
Received: from mail-ee0-x22d.google.com (mail-ee0-x22d.google.com [2a00:1450:4013:c00::22d])
        by mx.google.com with ESMTPS id w48si24086967een.44.2014.04.28.11.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 11:23:25 -0700 (PDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so5176181eek.4
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:23:24 -0700 (PDT)
Date: Mon, 28 Apr 2014 20:23:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Message-ID: <20140428182321.GA5856@dhcp22.suse.cz>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
 <20140428145440.GB7839@dhcp22.suse.cz>
 <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, Jiang Liu <liuj97@gmail.com>, peterz@infradead.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, khalid.aziz@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 28-04-14 23:53:28, Jianyu Zhan wrote:
> Hi, Michal,
> 
> On Mon, Apr 28, 2014 at 10:54 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > I really fail to see how that helps. compound_head is inlined and the
> > compiler should be clever enough to optimize the code properly. I
> > haven't tried that to be honest but this looks like it only adds a code
> > without any good reason. And I really hate the new name as well. What
> > does it suppose to mean?
> 
> the code in question is as below:
> 
> --- snipt ----
> if (likely(!PageTail(page))) {                  <------  (1)
>                 if (put_page_testzero(page)) {
>                         /*
>                         |* By the time all refcounts have been released
>                         |* split_huge_page cannot run anymore from under us.
>                         |*/
>                         if (PageHead(page))
>                                 __put_compound_page(page);
>                         else
>                                 __put_single_page(page);
>                 }
>                 return;
> }
> 
> /* __split_huge_page_refcount can run under us */
> page_head = compound_head(page);        <------------ (2)
> --- snipt ---
> 
> if at (1) ,  we fail the check, this means page is *likely* a tail page.
> 
> Then at (2), yes, compoud_head(page) is inlined, it is :
> 
> --- snipt ---
> static inline struct page *compound_head(struct page *page)
> {
>           if (unlikely(PageTail(page))) {           <----------- (3)
>               struct page *head = page->first_page;
> 
>                 smp_rmb();
>                 if (likely(PageTail(page)))
>                         return head;
>         }
>         return page;
> }
> --- snipt ---
> 
> here, the (3) unlikely in the case is  a negative hint, because it
> is *likely* a tail page. So the check (3) in this case is not good,
> so I introduce a helper for this case.
> 
> Actually, I checked the assembled code, the compiler is _not_
> so smart to recognize this case. It just does optimization as
> the hint unlikely() told it.

OK, the generated code is sligly smaller:
  11869    1328      32   13229    33ad mm/swap.o.after
  11880    1328      32   13240    33b8 mm/swap.o.before

The another question is. Does this matter? You are optimizing a slow
path which is not bad in general but it would be much better if you
show numbers which tell us that it helps noticeably in some loads or it
helped with future readability and maintainability. My experience tells
me that having very specialized helper functions used at a single place
don't help in neither in readability nor maintainability.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
