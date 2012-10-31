Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 777F36B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:07:10 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id c11so1175461qad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:07:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121031072446.GS15767@bbox>
References: <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
	<CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
	<20121031005738.GM15767@bbox>
	<CAA25o9QhkQfZi+UVOjj0JBkNo8Vmt22ATUP25LFqkS-cDoq85Q@mail.gmail.com>
	<20121031012720.GO15767@bbox>
	<CAA25o9QRr-wBHG0uY8UOOumUq_Er4shnmLWaXh3voY=1pvvWkA@mail.gmail.com>
	<20121031072446.GS15767@bbox>
Date: Wed, 31 Oct 2012 09:07:09 -0700
Message-ID: <CAA25o9Rp3TQxKkSLEW2mbiRecXScJnEKMg7xWAZWA75n5DYV_Q@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>, Mandeep Baines <msb@google.com>

On Wed, Oct 31, 2012 at 12:24 AM, Minchan Kim <minchan@kernel.org> wrote:

> AFAIRC, I recommended mem_notify instead of hacky patch when Mandeep submitted
> at the beginning. Does it have any problem?

When we introduced min_filelist_kbytes, the Chrome browser was not
prepared to take actions on low-memory notifications, so we could not
use that approach.  We still needed somehow to prevent the system from
thrashing.

A couple of years later we added a "tab discard" feature to Chrome,
which could be used to release memory in Chrome after saving the DOM
state of a tab.  At that time I noticed a similar patch from you,
which I took and slightly modified for our purposes.  I was not aware
of Anton's earlier patch then.  The basic idea of my patch is the same
as yours, but I estimate "easily reclaimable memory" differently.

I wasn't sure my patch would be of interest here, so I never posted it.

Going back to the min_filelist_kbytes patch, it doesn't seem that it's
such a bad idea to have a mechanism that prevents text page thrash.
It would be useful if the system kept working even if nobody is paying
attention to low-memory notifications.  The hacky patch sets a
threshold under which text pages are not evicted, to maintain a
reasonably-sized working set in memory.  Perhaps this threshold should
be set dynamically based on the rate of page faults due to instruction
fetches?

> AFAIK, mem_notify had a problem to notify too late so OOM kill still happens.
> Recently, Anton have been tried new low memory notifier and It should solve
> same problem and then it's thing you need.
> https://patchwork.kernel.org/patch/1625251/

Yes, part of the problem is that all these mechanisms are based on
heuristics.  Chrome tab discard is conceptually very similar to OOM
kill.  When Chrome gets a low-memory notification, it discards a tab
and then waits for about 1s before checking if it should discard more
tabs.  If other processes are allocating aggressively (for instance
after issuing commands that load multiple tabs in parallel), they will
use up memory faster than the tab discarder is releasing it.  So it's
essential to have a functioning fall-back mechanism in the kernel.

> Of course, there are further steps to merge it but I think you can help us
> with some experiments and input your voice to meet Chrome OS's goal.

I will look at Anton's notifier and see if it would meet our needs.  Thanks!

>
> Thanks.
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
