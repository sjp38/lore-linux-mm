Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2297F6B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 15:53:05 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p7NJr29O030072
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:53:02 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by hpaq1.eem.corp.google.com with ESMTP id p7NJqkKm018366
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:53:01 -0700
Received: by qwj9 with SMTP id 9so496199qwj.35
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 12:52:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110822213347.GF2507@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
	<20110822213347.GF2507@redhat.com>
Date: Tue, 23 Aug 2011 12:52:56 -0700
Message-ID: <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
Subject: Re: [PATCH] thp: tail page refcounting fix
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi Andrea,

On Mon, Aug 22, 2011 at 2:33 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> So this solution:
>
> 1) should allow the working set estimation code to keep doing its
> get_page_unless_zero() without any change (you'll still have to modify
> it to check if you got a THP page etc... but you won't risk to get any
> tail page anymore). Maybe it still needs some non trivial thought
> about the changes but not anymore about tail pages refcounting screwups.
>
> 2) no change to all existing get_page_unless_zero() is required, so
> this should fix the radix tree speculative page lookup too.
>
> 3) no RCU new feature is needed

Adding Paul McKenney so he won't spend too much time on RCU cookie
feature until there is a firmer user...

> 4) get_page was actually called by direct-io as my debug
> instrumentation I wrote to test these changes noticed it so I fixed
> that too

Looks like this scheme will work. I'm off in Yosemite for a few days
with my family, but I should be able to review this more thoroughly on
Thursday.

>From a few-minutes look, I have a few minor concerns:
- When splitting THP pages, the old tail refcount will be visible as
the _mapcount for a short while after PageTail is cleared; not clear
yet to me if there are unintended side effects to that;
- (not a concern, but an opportunity) when splitting pages, there are
two atomic adds to the tail _count field, while we know the initial
value is 0. Why not just one straight assignment ? Similarly, the
adjustments to page head count could be added into a local variable
and the page head count could be updated once after all tail pages
have been split off.
- Not sure if we could/should add assertions to make sure people call
the right get_page variant.

The other question I have is about the use of the pagemap.h RCU
protocol for eventual page count stability. With your proposal, this
would now affect only head pages, so THP splitting is fine :) . I'm
not sure who else might use that protocol, but it looks like we should
either make all get_pages_unless_zero call sites follow it (if the
protocol matters to someone) or none (if the protocol turns out to be
obsolete).

Sorry for the incomplete reply, I'll have a better one by Thursday :)

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
