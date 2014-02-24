Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2306D6B010C
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 03:28:56 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so6199282pab.23
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 00:28:55 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id s1si16132397pav.248.2014.02.24.00.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 00:28:55 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so6278976pab.33
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 00:28:54 -0800 (PST)
Date: Mon, 24 Feb 2014 00:28:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
In-Reply-To: <CABdxLJHS5kw0rpD=+77iQtc6PMeRXoWnh-nh5VzjjfGHJ5wLGQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
References: <20140213104231.GX6732@suse.de> <CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com> <loom.20140214T135753-812@post.gmane.org> <CABdxLJHS5kw0rpD=+77iQtc6PMeRXoWnh-nh5VzjjfGHJ5wLGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijieut@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 16 Feb 2014, Weijie Yang wrote:
>  On Fri, Feb 14, 2014 at 9:10 PM, Christian Ehrhardt
> <ehrhardt@linux.vnet.ibm.com> wrote:
> > Weijie Yang <weijie.yang.kh <at> gmail.com> writes:
> >
> >>
> >> On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman <at> suse.de> wrote:
> > [...]
> >> > -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> >> > +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
> >>
> > [...]
> >> Does it lead to a "schlemiel the painter's algorithm"?
> >> (please forgive my rude words, but I can't find a precise word to describe it
> >>
> >> How about modify it like this?
> >>
> > [...]
> >> - next = swap_list.head;
> >> + next = type;
> > [...]
> >
> > Hi,
> > unfortunately withou studying the code more thoroughly I'm not even sure if
> > you meant you code to extend or replace Mels patch.
> >
> > To be sure about your intention.  You refered to algorithm scaling because
> > you were afraid the new code would scan the full list all the time right ?
> >
> > But simply letting the machines give a try for both options I can now
> > qualify both.
> >
> > Just your patch creates a behaviour of jumping over priorities (see the
> > following example), so I hope you meant combining both patches.
> > With that in mind the patch I eventually tested the combined patch looking
> > like this:
> 
> Hi Christian,
> 
> My patch is not appropriate, so there is no need to combine it with Mel's patch.
> 
> What I worried about Mel's patch is not only the search efficiency,
> actually it has
> negligible impact on system, but also the following scenario:
> 
> If two swapfiles have the same priority, in ordinary semantic, they
> should be used
> in balance. But with Mel's patch, it will always get the free
> swap_entry from the
> swap_list.head in priority order, I worry it could break the balance.
> 
> I think you can test this scenario if you have available test machines.
> 
> Appreciate for your done.

Weijie, I agree with you on both points: Schlemiel effect of repeatedly
restarting from head (already an unintended defect before Mel's patch),
and more importantly the breakage of swapfiles at the same priority.

Sorry, it has to be a Nak to Mel's patch, which fixes one behavior
at the expense of another.  And if we were to go that way, better
just to rip out all of swap_list.next and highest_priority_index.

I had hoped to respond today with a better patch; but I just haven't
got it right yet either.  I think we don't need to rush to fix it,
but fix it we certainly should.

Christian, congratulations on discovering this wrong behavior: at
first I assumed it came from Shaohua's 3.9 highest_priority_index
changes, but no; then I assumed it came from my 2.6.14 swap_lock
changes; but now I think it goes back even before 2.4.0, probably
ever since there have been swap priorities.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
