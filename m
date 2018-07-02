Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 608356B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:55:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t14-v6so13884466ioj.8
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:55:09 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 186-v6si3095059ith.79.2018.07.02.10.55.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 10:55:08 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62Hrdiq171650
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:55:07 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2jx2gpwexh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 17:55:07 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w62Ht6cG018017
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:55:06 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w62Ht6Qr028353
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:55:06 GMT
Received: by mail-oi0-f51.google.com with SMTP id s198-v6so14134718oih.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:55:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180702152745.27596-1-pasha.tatashin@oracle.com> <20180702155858.GE19043@dhcp22.suse.cz>
In-Reply-To: <20180702155858.GE19043@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 13:54:29 -0400
Message-ID: <CAGM2reYeHhQAqujJwcec_t40pM+9=DO=Ht8HR=yX6rHSUQQXvg@mail.gmail.com>
Subject: Re: [PATCH] mm: teach dump_page() to correctly output poisoned struct pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, gregkh@linuxfoundation.org

On Mon, Jul 2, 2018 at 11:59 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 02-07-18 11:27:45, Pavel Tatashin wrote:
> > If struct page is poisoned, and uninitialized access is detected via
> > PF_POISONED_CHECK(page) dump_page() is called to output the page. But,
> > the dump_page() itself accesses struct page to determine how to print
> > it, and therefore gets into a recursive loop.
> >
> > For example:
> > dump_page()
> >  __dump_page()
> >   PageSlab(page)
> >    PF_POISONED_CHECK(page)
> >     VM_BUG_ON_PGFLAGS(PagePoisoned(page), page)
> >      dump_page() recursion loop.
>
> This deserves a big fat comment in __dump_page. Basically no Page$FOO
> can be used on an HWPoison page.
>
> > Fixes: f165b378bbdf ("mm: uninitialized struct page poisoning sanity checking")
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you, I will send out an updated version with a comment.

Pavel

>
> > ---
> >  mm/debug.c | 13 +++++++++++--
> >  1 file changed, 11 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/debug.c b/mm/debug.c
> > index 56e2d9125ea5..469b526e6abc 100644
> > --- a/mm/debug.c
> > +++ b/mm/debug.c
> > @@ -43,12 +43,20 @@ const struct trace_print_flags vmaflag_names[] = {
> >
> >  void __dump_page(struct page *page, const char *reason)
> >  {
> > +     bool page_poisoned = PagePoisoned(page);
> > +     int mapcount;
> > +
> > +     if (page_poisoned) {
> > +             pr_emerg("page:%px is uninitialized and poisoned", page);
> > +             goto hex_only;
> > +     }
> > +
> >       /*
> >        * Avoid VM_BUG_ON() in page_mapcount().
> >        * page->_mapcount space in struct page is used by sl[aou]b pages to
> >        * encode own info.
> >        */
> > -     int mapcount = PageSlab(page) ? 0 : page_mapcount(page);
> > +     mapcount = PageSlab(page) ? 0 : page_mapcount(page);
> >
> >       pr_emerg("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
> >                 page, page_ref_count(page), mapcount,
> > @@ -60,6 +68,7 @@ void __dump_page(struct page *page, const char *reason)
> >
> >       pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
> >
> > +hex_only:
> >       print_hex_dump(KERN_ALERT, "raw: ", DUMP_PREFIX_NONE, 32,
> >                       sizeof(unsigned long), page,
> >                       sizeof(struct page), false);
> > @@ -68,7 +77,7 @@ void __dump_page(struct page *page, const char *reason)
> >               pr_alert("page dumped because: %s\n", reason);
> >
> >  #ifdef CONFIG_MEMCG
> > -     if (page->mem_cgroup)
> > +     if (!page_poisoned && page->mem_cgroup)
> >               pr_alert("page->mem_cgroup:%px\n", page->mem_cgroup);
> >  #endif
> >  }
> > --
> > 2.18.0
> >
>
> --
> Michal Hocko
> SUSE Labs
>
