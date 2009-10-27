Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DB546B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 08:38:17 -0400 (EDT)
Date: Tue, 27 Oct 2009 13:38:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-ID: <20091027123810.GA22830@random.random>
References: <4ADE3121.6090407@gmail.com>
 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com>
 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
 <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
 <20091027153429.b36866c4.minchan.kim@barrios-desktop>
 <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
 <28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
 <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
 <20091027165612.4122d600.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027165612.4122d600.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 04:56:12PM +0900, Minchan Kim wrote:
> Thanks for making the patch.
> Let's hear other's opinion. :)

total_vm is nearly meaningless, especially on 64bit that reduces the
mmap load on libs, I tried to change it to something "physical" (rss,
didn't add swap too) some time ago too, not sure why I didn't manage
to get it in. Trying again surely sounds good. Accounting swap isn't
necessarily good, we may be killing a task that isn't accessing memory
at all. So yes, we free swap but if the task is the "bloater" it's
unlikely to be all in swap as it did all recent activity that lead to
the oom. So I'm unsure if swap is good to account here, but surely I
ack to replace virtual with rss. I would include the whole rss, as the
file one may also be rendered unswappable if it is accessed in a loop
refreshing the young bit all the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
