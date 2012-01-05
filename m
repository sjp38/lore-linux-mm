Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id F0D9A6B0075
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 18:10:14 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so1585726obc.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 15:10:14 -0800 (PST)
Date: Thu, 5 Jan 2012 15:10:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and related
 changes in MM
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045545E5@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201051503530.10521@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195612.GB19181@suse.de> <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com> <20120105145753.GA3937@suse.de> <84FF21A720B0874AA94B46D76DB98269045545E5@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Thu, 5 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> I tried to sort out all inputs coming. But before doing the next step I 
> prefer to have tests passed. Changes you proposed are strain forward and 
> understandable. 
> Hooking in mm/vmscan.c and mm/page-writeback.c is not so easy, I need 
> to find proper place and make adequate proposal.
> Using memcg is doesn't not look for me now as a good way because I 
> wouldn't like to change memory accounting - memcg has strong reason to 
> keep caches.
> 

If you can accept the overhead of the memory controller (increase in 
kernel text size and amount of metadata for page_cgroup), then you can 
already do this with a combination of memory thresholds with 
cgroup.event_control and disabling of the oom killer entirely with 
memory.oom_control.  You can also get notified when the oom killer is 
triggered by using eventfd(2) on memory.oom_control even though it's 
disabled in the kernel.  Then, the userspace task attached to that control 
file can send signals to applications to free their memory or, in the 
worst case, choose to kill an application but have all that policy be 
implemented in userspace.

We actually have extended that internally to have an oom killer delay, 
i.e. a specific amount of time must pass for userspace to react to the oom 
situation or the oom killer will actually be triggered.  This is needed in 
case our userspace is blocked or can't respond for whatever reason and is 
a nice fallback so that we're guaranteed to never end up livelocked.  That 
delay gets reset anytime a page is uncharged to a memcg, the memcg limit 
is increased, or the delay is rewritten (for userspace to say "I've 
handled the event").  Those patches were posted on linux-mm several months 
ago but never merged upstream.  You should be able to use the same concept 
apart from the memory controller and implement it generically.

You also presented this as an alternative for "embedded or small" users so 
I wasn't aware that using the memory controller was an acceptable solution 
given its overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
