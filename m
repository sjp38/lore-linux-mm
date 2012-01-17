Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1FEB66B004F
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 14:31:07 -0500 (EST)
Message-ID: <4F15CC56.90309@redhat.com>
Date: Tue, 17 Jan 2012 14:30:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] /dev/low_mem_notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
In-Reply-To: <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 01/17/2012 01:51 PM, Pekka Enberg wrote:
> Hello,
>
> Ok, so here's a proof of concept patch that implements sample-base
> per-process free threshold VM event watching using perf-like syscall
> ABI. I'd really like to see something like this that's much more
> extensible and clean than the /dev based ABIs that people have proposed
> so far.

Looks like a nice extensible interface to me.

The only thing is, I expect we will not want to wake
up processes most of the time, when there is no memory
pressure, because that would just waste battery power
and/or cpu time that could be used for something else.

The desire to avoid such wakeups makes it harder to
wake up processes at arbitrary points set by the API.

Another issue is that we might be running two programs
on the system, each with a different threshold for
"lets free some of my cache".  Say one program sets
the threshold at 20% free/cache memory, the other
program at 10%.

We could end up with the first process continually
throwing away its caches, while the second process
never gives its unused memory back to the kernel.

I am not sure what the right thing to do would be...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
