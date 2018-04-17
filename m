Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0206B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:14:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y16so9890870wrh.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:14:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d35si3365084edc.198.2018.04.17.07.14.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 07:14:44 -0700 (PDT)
Date: Tue, 17 Apr 2018 16:14:42 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Message-ID: <20180417141442.GG17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
 <20180417130300.GF17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417130300.GF17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue 17-04-18 15:03:00, Michal Hocko wrote:
> On Tue 17-04-18 19:06:15, Li Wang wrote:
> [...]
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f65dd69..2b315fc 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >  			continue;
> >  
> >  		err = store_status(status, i, err, 1);
> > -		if (err)
> > +		if (!err)
> >  			goto out_flush;
> 
> This change just doesn't make any sense to me. Why should we bail out if
> the store_status is successul? I am trying to wrap my head around the
> test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
> explain that move_pages has some semantic issues and the new
> implementation might be not 100% replacement. Anyway I am studying the
> test case to come up with a proper fix.

OK, I get what the test cases does. I've failed to see the subtle
difference between alloc_pages_on_node and numa_alloc_onnode. The later
doesn't faul in anything.

Why are we getting EPERM is quite not yet clear to me.
add_page_for_migration uses FOLL_DUMP which should return EFAULT on
zero pages (no_page_table()).

	err = PTR_ERR(page);
	if (IS_ERR(page))
		goto out;

therefore bails out from add_page_for_migration and store_status should
store that value. There shouldn't be any EPERM on the way.

Let me try to reproduce and see what is going on. Btw. which kernel do
you try this on?
-- 
Michal Hocko
SUSE Labs
