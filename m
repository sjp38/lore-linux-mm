Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 255986B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 14:56:37 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id c10so12035699ieb.24
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:56:36 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 11 Jun 2013 11:56:36 -0700
Message-ID: <CAA25o9R24C68zkpsFodgTKEKObPH6nAHdEwLHoyB=cqFi7mwKg@mail.gmail.com>
Subject: zram is deployed!
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I'd like to thank all those who helped us directly or indirectly with
getting zram to work well with Chrome OS.  It has been deployed as of
Release 27 to all Chrome OS devices, and we believe it is helping
users get the most out of their systems.  So, good job, thank you for
contributing to progress, and congratulations on having your code run
on a large number of systems (I regret I am not allowed to say how
large).

We plan to take advantage of further developments in Linux memory
compression in the future, and look forward to continue working with
you on this and other projects.

Thanks!
Luigi

P.S.  More details for those who care:

Chrome OS deals with memory shortage by letting the browser know when
it's about to run out of memory.  The browser then kills a tab, as
transparently as possible.  When the user switches to that tab again,
the browser reloads it and rebuilds its DOM state as much as possible.

In many cases however, much of the state is not recoverable (think of
a tab hosting an SSH session), and even when it is, the reloading is a
relatively slow and highly noticeable operation.  Chrome OS doesn't
use conventional swap to disk for various reasons, but memory
compression was an option and we tried it.

On most systems we allocate a zram device with size 1.5 * <system RAM
size>.  We achieve a compression ratio of almost 3:1, so, for
instance, on a 4GB system, we create a 6GB zram device, which, when
full, uses up about 2GB of RAM, and leaves the other 2GB for the
"working set" of tabs.

With a field trial we observed that the average number of "tab
discards" decreased considerably, by almost two orders of magnitude,
with few adverse side effects, most noticeably:

1. increased "jank" when switching to a not-recently-used tab (but
it's usually a tab that would have been discarded without zram, and
the jank is much more tolerable than a reload);

2. some (rare) thrashing on certain devices and under certain loads,
when background activity in the tabs (typically javascript timeouts)
causes the "working set" to be larger than available RAM (i.e. RAM not
used by the zram device).

Future challenges include dealing with point 2 above; possibly
integrating this with some amount of swap to disk; better integration
with the discarding of i915 graphics buffers (currently done in a
shrinker).

Please feel free to contact me for more info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
