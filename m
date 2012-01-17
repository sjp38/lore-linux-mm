Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 979586B00DD
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 12:16:57 -0500 (EST)
Received: by yhpp34 with SMTP id p34so376926yhp.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:16:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326788038-29141-1-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
Date: Tue, 17 Jan 2012 09:16:56 -0800
Message-ID: <CAOesGMjgXMctGr3o=X3n2gx2_g990FzCPn88NQz8tN8m1aHsGQ@mail.gmail.com>
Subject: Re: [RFC 0/3] low memory notify
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

Hi,

On Tue, Jan 17, 2012 at 12:13 AM, Minchan Kim <minchan@kernel.org> wrote:
> As you can see, it's respin of mem_notify core of KOSAKI and Marcelo.
> (Of course, KOSAKI's original patchset includes more logics but I didn't
> include all things intentionally because I want to start from beginning
> again) Recently, there are some requirements of notification of system
> memory pressure. It would be very useful for various cases.
> For example, QEMU/JVM/Firefox like big memory hogger can release their memory
> when memory pressure happens. Another example in embedded side,
> they can close background application. For this, there are some trial but
> we need more general one and not-hacked alloc/free hot path.
>
> I think most big problem of system slowness is swap-in operation.
> Swap-in is a synchronous operation so application's latency would be
> big. Solution for that is prevent swap-out itself. We couldn't prevent
> swapout totally but could reduce it with this patch.
>
> In case of swapless system, code page is very important for system response.
> So we have to keep code page, too. I used very naive heuristic in this patch
> but welcome to any idea.
>
> I want to make kernel logic simple if possible and just notify to user space.
> Of course, there are lots of thing we have to consider but for discussion
> this simple patch would be a good start point.

This is almost exactly what we've been looking at doing for Chrome OS
(which is swapless). In our case, the browser is by far the largest
memory consumer on the system, and we have for quite a while been
playing tricks with OOM scores trying to make the interaction between
the VM and the application happen right such that if we're OOM, the
"right" tab process gets killed, etc. But it's not enough (and it's
not always accurate enough). Chrome definitely knows already what it
would prefer to do to release memory, so having a simple notifier for
low memory condition is preferred.

We have considered doing it through cgroups but it adds a level of
complexity that we don't need for this use case (we do already use
cgroups for other reasons though). If this simpler solution is heading
towards inclusion we'll probably use it instead.


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
