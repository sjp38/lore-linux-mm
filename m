Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 6DA686B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:23:19 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Date: Tue, 24 Jan 2012 16:22:36 +0000
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
In-Reply-To: <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201201241622.36222.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: leonid.moiseichuk@nokia.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Wednesday 18 January 2012, Pekka Enberg wrote:
> >> +struct vmnotify_event {
> >> +     /* Size of the struct for ABI extensibility. */
> >> +     __u32                   size;
> >> +
> >> +     __u64                   nr_avail_pages;
> >> +
> >> +     __u64                   nr_swap_pages;
> >> +
> >> +     __u64                   nr_free_pages;
> >> +};
> >
> > Two fields here most likely session-constant, (nr_avail_pages and
> > nr_swap_pages), seems not much sense to report them in every event.  If we
> > have memory/swap hotplug user-space can use sysinfo() call.
> 
> I actually changed the ABI to look like this:
> 
> struct vmnotify_event {
>         /*
>          * Size of the struct for ABI extensibility.
>          */
>         __u32                   size;
> 
>         __u64                   attrs;
> 
>         __u64                   attr_values[];
> };
> 
> So userspace can decide which fields to include in notifications.

Please make the first member a __u64 instead of a __u32. This will
avoid incompatibility between 32 and 64 bit processes, which have
different alignment rules on x86: x86-32 would implicitly pack the
struct while x86-64 would add padding with your layout.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
