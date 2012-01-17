Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 71BD76B00BE
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:38:35 -0500 (EST)
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 7299B20E53
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:38:34 -0500 (EST)
Subject: Re: [RFC 0/3] low memory notify
From: Colin Walters <walters@verbum.org>
Date: Tue, 17 Jan 2012 09:38:10 -0500
In-Reply-To: <1326788038-29141-1-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1326811093.3467.41.camel@lenny>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On Tue, 2012-01-17 at 17:13 +0900, Minchan Kim wrote:
> As you can see, it's respin of mem_notify core of KOSAKI and Marcelo.
> (Of course, KOSAKI's original patchset includes more logics but I didn't
> include all things intentionally because I want to start from beginning
> again) Recently, there are some requirements of notification of system
> memory pressure.

How does this relate to the existing cgroups memory notifications?  See
Documentation/cgroups/memory.txt under "10. OOM Control"

>  It would be very useful for various cases.
> For example, QEMU/JVM/Firefox like big memory hogger can release their memory
> when memory pressure happens.

I don't know about QEMU, but the key characteristic of the JVM and
Firefox is that they use garbage collection.  Which also applies to
Python, Ruby, Google Go, Haskell, OCaml...

So what you really want to be investigating here is integration between
a garbage collector and the system VM.  Your test program looks nothing
like a garbage collector.  I'd expect most of the performance tradeoffs
to be similar between these runtimes.  The Azul people have been doing
something like this: http://www.managedruntime.org/

In Firefox' case though it can also drop other caches, e.g.:

http://people.gnome.org/~federico/news-2007-09.html#firefox-memory-1

As far as the desktop goes, I want to get notified if we're going to hit
swap, not if we're close to exhausting the total of RAM+swap.  While
swap may make sense for servers that care about throughput mainly, I
care a lot about latency.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
