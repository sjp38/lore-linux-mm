Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0730B6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:39:54 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so32063qge.26
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:39:54 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.232])
        by mx.google.com with ESMTP id e7si5748551qai.19.2014.05.06.13.39.54
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 13:39:54 -0700 (PDT)
Date: Tue, 6 May 2014 16:39:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/4] plist: add plist_rotate
Message-ID: <20140506163950.7e278f7c@gandalf.local.home>
In-Reply-To: <CALZtONAr7XGMB8LHwKRjqeEaWTEKBbwkUuP1RAZd04YQiwxrGw@mail.gmail.com>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
	<1399057350-16300-1-git-send-email-ddstreet@ieee.org>
	<1399057350-16300-4-git-send-email-ddstreet@ieee.org>
	<20140505221846.4564e04d@gandalf.local.home>
	<CALZtONAr7XGMB8LHwKRjqeEaWTEKBbwkUuP1RAZd04YQiwxrGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Tue, 6 May 2014 16:12:54 -0400
Dan Streetman <ddstreet@ieee.org> wrote:

> On Mon, May 5, 2014 at 10:18 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Fri,  2 May 2014 15:02:29 -0400
> > Dan Streetman <ddstreet@ieee.org> wrote:
> >
> >> Add plist_rotate(), which moves the specified plist_node after
> >> all other same-priority plist_nodes in the list.
> >
> > This is a little confusing? You mean it takes a plist_node from a plist
> > and simply moves it to the end of the list of all other nodes of the
> > same priority?
> 
> yes, exactly
> 
> > Kind of like what a sched_yield() would do with a
> > SCHED_FIFO task? I wonder if we should call this "plist_yield()" then?
> 
> I suppose it is similar, yes...I'll rename it in a v2 patch.

I'm open to other suggestions as well. What else can give you the idea
that it's putting a node at the end of its priority?

I added Peter to the Cc list because I know how much he loves
sched_yield() :-)

> 
> >
> >>
> >> This is needed by swap, which has a plist of swap_info_structs
> >> and needs to use each same-priority swap_info_struct equally.
> >
> > "needs to use each same-priority swap_info_struct equally"
> >
> > -ENOCOMPUTE
> 
> heh, yeah that needs a bit more explaining doesn't it :-)
> 
> by "equally", I mean as swap writes pages out to its swap devices, it
> must write to any same-priority devices on a round-robin basis.

OK, I think you are suffering from "being too involved to explain
clearly" syndrome. :)

I still don't see the connection between swap pages and plist, and even
more so, why something would already be in a plist and then needs to be
pushed to the end of its priority.

> 
> I'll update the comment in the v2 patch to try to explain clearer.
> 

Please do. But explain it to someone that has no idea how plists are
used by the swap subsystem, and why you need to move a node to the end
of its priority.

Thanks,

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
