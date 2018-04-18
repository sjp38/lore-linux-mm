Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B65AF6B0009
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 05:07:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j18so524135pgv.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 02:07:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d127si750287pga.201.2018.04.18.02.07.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 02:07:26 -0700 (PDT)
Date: Wed, 18 Apr 2018 11:07:22 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Message-ID: <20180418090722.GV17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
 <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz>
 <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
 <20180417190044.GK17484@dhcp22.suse.cz>
 <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Li Wang <liwang@redhat.com>, linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 17-04-18 16:09:33, Zi Yan wrote:
> On 17 Apr 2018, at 15:00, Michal Hocko wrote:
> 
> > On Tue 17-04-18 22:28:33, Li Wang wrote:
> >> On Tue, Apr 17, 2018 at 10:14 PM, Michal Hocko <mhocko@suse.com> wrote:
> >>
> >>> On Tue 17-04-18 15:03:00, Michal Hocko wrote:
> >>>> On Tue 17-04-18 19:06:15, Li Wang wrote:
> >>>> [...]
> >>>>> diff --git a/mm/migrate.c b/mm/migrate.c
> >>>>> index f65dd69..2b315fc 100644
> >>>>> --- a/mm/migrate.c
> >>>>> +++ b/mm/migrate.c
> >>>>> @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm,
> >>> nodemask_t task_nodes,
> >>>>>                     continue;
> >>>>>
> >>>>>             err = store_status(status, i, err, 1);
> >>>>> -           if (err)
> >>>>> +           if (!err)
> >>>>>                     goto out_flush;
> >>>>
> >>>> This change just doesn't make any sense to me. Why should we bail out if
> >>>> the store_status is successul? I am trying to wrap my head around the
> >>>> test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
> >>>> explain that move_pages has some semantic issues and the new
> >>>> implementation might be not 100% replacement. Anyway I am studying the
> >>>> test case to come up with a proper fix.
> >>>
> >>> OK, I get what the test cases does. I've failed to see the subtle
> >>> difference between alloc_pages_on_node and numa_alloc_onnode. The later
> >>> doesn't faul in anything.
> >>>
> >>> Why are we getting EPERM is quite not yet clear to me.
> >>> add_page_for_migration uses FOLL_DUMP which should return EFAULT on
> >>> zero pages (no_page_table()).
> >>>
> >>>         err = PTR_ERR(page);
> >>>         if (IS_ERR(page))
> >>>                 goto out;
> >>>
> >>> therefore bails out from add_page_for_migration and store_status should
> >>> store that value. There shouldn't be any EPERM on the way.
> >>>
> >>
> >> Yes, I print the the return value and confirmed the
> >> add_page_for_migration()a??
> >> do right things for zero page. and after store_status(...) the status saves
> >> -EFAULT.
> >> So I did the change above.
> >
> > OK, I guess I knnow what is going on. I must be overwriting the status
> > on the way out by
> >
> > out_flush:
> > 	/* Make sure we do not overwrite the existing error */
> > 	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
> > 	if (!err1)
> > 		err1 = store_status(status, start, current_node, i - start);
> >
> > This error handling is rather fragile and I was quite unhappy about it
> > at the time I was developing it. I have to remember all the details why
> > I've done it that way but I would bet my hat this is it. More on this
> > tomorrow.
> 
> Hi Michal and Li,
> 
> The problem is that the variable start is not set properly after store_status(),
> like the "start = i;" after the first store_status().
> 
> The following patch should fix the problem (it has passed all move_pages test cases from ltp
> on my machine):
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f65dd69e1fd1..32afa4723e7f 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>                         if (err)
>                                 goto out;
>                 }
> +               /* Move to next page (i+1), after we have saved page status (until i) */
> +               start = i + 1;
>                 current_node = NUMA_NO_NODE;
>         }
>  out_flush:
> 
> Feel free to check it by yourselves.

Yes, you are right. I never update start if the last page in the range
fails and so we overwrite the whole [start, i] range. I wish the code
wasn't that ugly and subtle but considering how we can fail in different
ways and that we want to batch as much as possible I do not see an easy
way.

Care to send the patch? I would just drop the comment.

Thanks!
-- 
Michal Hocko
SUSE Labs
