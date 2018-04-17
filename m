Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 064236B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:00:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 38so15875712wrv.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:00:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26si3461686eda.47.2018.04.17.12.00.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 12:00:46 -0700 (PDT)
Date: Tue, 17 Apr 2018 21:00:44 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Message-ID: <20180417190044.GK17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
 <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz>
 <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue 17-04-18 22:28:33, Li Wang wrote:
> On Tue, Apr 17, 2018 at 10:14 PM, Michal Hocko <mhocko@suse.com> wrote:
> 
> > On Tue 17-04-18 15:03:00, Michal Hocko wrote:
> > > On Tue 17-04-18 19:06:15, Li Wang wrote:
> > > [...]
> > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > index f65dd69..2b315fc 100644
> > > > --- a/mm/migrate.c
> > > > +++ b/mm/migrate.c
> > > > @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm,
> > nodemask_t task_nodes,
> > > >                     continue;
> > > >
> > > >             err = store_status(status, i, err, 1);
> > > > -           if (err)
> > > > +           if (!err)
> > > >                     goto out_flush;
> > >
> > > This change just doesn't make any sense to me. Why should we bail out if
> > > the store_status is successul? I am trying to wrap my head around the
> > > test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
> > > explain that move_pages has some semantic issues and the new
> > > implementation might be not 100% replacement. Anyway I am studying the
> > > test case to come up with a proper fix.
> >
> > OK, I get what the test cases does. I've failed to see the subtle
> > difference between alloc_pages_on_node and numa_alloc_onnode. The later
> > doesn't faul in anything.
> >
> > Why are we getting EPERM is quite not yet clear to me.
> > add_page_for_migration uses FOLL_DUMP which should return EFAULT on
> > zero pages (no_page_table()).
> >
> >         err = PTR_ERR(page);
> >         if (IS_ERR(page))
> >                 goto out;
> >
> > therefore bails out from add_page_for_migration and store_status should
> > store that value. There shouldn't be any EPERM on the way.
> >
> 
> Yes, I print the the return value and confirmed the
> add_page_for_migration()a??
> do right things for zero page. and after store_status(...) the status saves
> -EFAULT.
> So I did the change above.

OK, I guess I knnow what is going on. I must be overwriting the status
on the way out by

out_flush:
	/* Make sure we do not overwrite the existing error */
	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
	if (!err1)
		err1 = store_status(status, start, current_node, i - start);

This error handling is rather fragile and I was quite unhappy about it
at the time I was developing it. I have to remember all the details why
I've done it that way but I would bet my hat this is it. More on this
tomorrow.
-- 
Michal Hocko
SUSE Labs
