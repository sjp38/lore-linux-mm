Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7658B6B0037
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:54:09 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id at1so3342287iec.31
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:54:09 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id k7si13059556icu.27.2014.04.28.08.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 08:54:08 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id lx4so6522591iec.24
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:54:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140428145440.GB7839@dhcp22.suse.cz>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com> <20140428145440.GB7839@dhcp22.suse.cz>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Mon, 28 Apr 2014 23:53:28 +0800
Message-ID: <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
Subject: Re: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, Jiang Liu <liuj97@gmail.com>, peterz@infradead.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, khalid.aziz@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi, Michal,

On Mon, Apr 28, 2014 at 10:54 PM, Michal Hocko <mhocko@suse.cz> wrote:
> I really fail to see how that helps. compound_head is inlined and the
> compiler should be clever enough to optimize the code properly. I
> haven't tried that to be honest but this looks like it only adds a code
> without any good reason. And I really hate the new name as well. What
> does it suppose to mean?

the code in question is as below:

--- snipt ----
if (likely(!PageTail(page))) {                  <------  (1)
                if (put_page_testzero(page)) {
                        /*
                        =C2=A6* By the time all refcounts have been release=
d
                        =C2=A6* split_huge_page cannot run anymore from und=
er us.
                        =C2=A6*/
                        if (PageHead(page))
                                __put_compound_page(page);
                        else
                                __put_single_page(page);
                }
                return;
}

/* __split_huge_page_refcount can run under us */
page_head =3D compound_head(page);        <------------ (2)
--- snipt ---

if at (1) ,  we fail the check, this means page is *likely* a tail page.

Then at (2), yes, compoud_head(page) is inlined, it is :

--- snipt ---
static inline struct page *compound_head(struct page *page)
{
          if (unlikely(PageTail(page))) {           <----------- (3)
              struct page *head =3D page->first_page;

                smp_rmb();
                if (likely(PageTail(page)))
                        return head;
        }
        return page;
}
--- snipt ---

here, the (3) unlikely in the case is  a negative hint, because it
is *likely* a tail page. So the check (3) in this case is not good,
so I introduce a helper for this case.

Actually, I checked the assembled code, the compiler is _not_
so smart to recognize this case. It just does optimization as
the hint unlikely() told it.



Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
