Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E013F6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:18:50 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1664901bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 18:18:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120608010520.GA25317@x4>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com>
 <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com>
 <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <20120608010520.GA25317@x4>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 18:18:28 -0700
Message-ID: <CA+55aFwuA3ex+XXW+TzOee8ax0g1NK9Mm5F3nYtY1m6YtvUFhQ@mail.gmail.com>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, khlebnikov@openvz.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com, stable@vger.kernel.org

On Thu, Jun 7, 2012 at 6:05 PM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
>
> You've somehow merged the wrong patch.
> The correct version can be found here:
> http://marc.info/?l=linux-kernel&m=133848759505805

It looks like Andrew sent me a bad version.

However, that patch you point at isn't good *either*.

It does totally insane things in xacct_add_tsk(). You can't call
"sync_mm_rss(mm)" on somebody elses mm, yet that is exactly what it
does (and you can't pass in another thread pointer either, since the
whole point of the per-thread counters is that they don't have locking
and aren't atomic, so you can't read them from any other context than
"current").

The thing is, the *only* point where it makes sense to sync the rss
pointers is when you detach the mm from the current thread. And
possibly at "fork()" time, *before* you duplicate the "struct
task_struct" and pollute the new one with stale rss counter values
from the old one.

So doing sync_mm_rss() in xacct_add_tsk() is crazy. Doing it
*anywhere* where mm is not clearly "current->mm" is wrong. If there is
a "get_task_mm()" or similar nearby, it's wrong, it's crap, and it
shouldn't be done.

Oleg, please rescue me? Your patch looks much closer to sane, but it's
not quite there..

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
