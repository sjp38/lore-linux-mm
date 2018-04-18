Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E10B6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:29:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 88-v6so293123wrc.21
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:29:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si1144721edc.176.2018.04.18.04.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 04:29:19 -0700 (PDT)
Date: Wed, 18 Apr 2018 13:29:16 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Message-ID: <20180418112916.GX17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
 <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz>
 <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
 <20180417190044.GK17484@dhcp22.suse.cz>
 <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
 <20180418090722.GV17484@dhcp22.suse.cz>
 <20180418091943.GW17484@dhcp22.suse.cz>
 <CAEemH2evD8Gk6y_q41ygBZVwu--U9oKvnPh8xsrb5R27oLCBDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEemH2evD8Gk6y_q41ygBZVwu--U9oKvnPh8xsrb5R27oLCBDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 18-04-18 18:39:19, Li Wang wrote:
> On Wed, Apr 18, 2018 at 5:19 PM, Michal Hocko <mhocko@suse.com> wrote:
> 
> > On Wed 18-04-18 11:07:22, Michal Hocko wrote:
> > > On Tue 17-04-18 16:09:33, Zi Yan wrote:
> > [...]
> > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > index f65dd69e1fd1..32afa4723e7f 100644
> > > > --- a/mm/migrate.c
> > > > +++ b/mm/migrate.c
> > > > @@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct *mm,
> > nodemask_t task_nodes,
> > > >                         if (err)
> > > >                                 goto out;
> > > >                 }
> > > > +               /* Move to next page (i+1), after we have saved page
> > status (until i) */
> > > > +               start = i + 1;
> > > >                 current_node = NUMA_NO_NODE;
> > > >         }
> > > >  out_flush:
> > > >
> > > > Feel free to check it by yourselves.
> > >
> > > Yes, you are right. I never update start if the last page in the range
> > > fails and so we overwrite the whole [start, i] range. I wish the code
> > > wasn't that ugly and subtle but considering how we can fail in different
> > > ways and that we want to batch as much as possible I do not see an easy
> > > way.
> > >
> > > Care to send the patch? I would just drop the comment.
> >
> > Hmm, thinking about it some more. An alternative would be to check for
> > list_empty on the page list. It is a bit larger diff but maybe that
> > would be tiny bit cleaner because there is simply no point to call
> > do_move_pages_to_node on an empty list in the first place.
> >
> 
> a??Hi Michal, Zi
> 
> I tried your patch separately, both of them works fine to me.

Thanks for retesting! Do you plan to post a patch with the changelog or
should I do it?
-- 
Michal Hocko
SUSE Labs
