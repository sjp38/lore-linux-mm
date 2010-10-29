Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 705878D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 20:10:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T0ATO8002312
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 09:10:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CEF045DE55
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:10:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF8E545DE53
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:10:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1E0EE08004
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:10:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5E4E18003
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:10:28 +0900 (JST)
Date: Fri, 29 Oct 2010 09:04:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-Id: <20101029090449.a79452a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
References: <20101028191523.GA14972@google.com>
	<20101028131029.ee0aadc0.akpm@linux-foundation.org>
	<20101028220331.GZ26494@google.com>
	<AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 08:28:23 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Oct 29, 2010 at 7:03 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
> > Andrew Morton (akpm@linux-foundation.org) wrote:
> >> On Thu, 28 Oct 2010 12:15:23 -0700
> >> Mandeep Singh Baines <msb@chromium.org> wrote:
> >>
> >> > On ChromiumOS, we do not use swap.
> >>
> >> Well that's bad. A Why not?
> >>
> >
> > We're using SSDs. We're still in the "make it work" phase so wanted
> > avoid swap unless/until we learn how to use it effectively with
> > an SSD.
> >
> > You'll want to tune swap differently if you're using an SSD. Not sure
> > if swappiness is the answer. Maybe a new tunable to control how aggressive
> > swap is unless such a thing already exits?
> >
> >> > When memory is low, the only way to
> >> > free memory is to reclaim pages from the file list. This results in a
> >> > lot of thrashing under low memory conditions. We see the system become
> >> > unresponsive for minutes before it eventually OOMs. We also see very
> >> > slow browser tab switching under low memory. Instead of an unresponsive
> >> > system, we'd really like the kernel to OOM as soon as it starts to
> >> > thrash. If it can't keep the working set in memory, then OOM.
> >> > Losing one of many tabs is a better behaviour for the user than an
> >> > unresponsive system.
> >> >
> >> > This patch create a new sysctl, min_filelist_kbytes, which disables reclaim
> >> > of file-backed pages when when there are less than min_filelist_bytes worth
> >> > of such pages in the cache. This tunable is handy for low memory systems
> >> > using solid-state storage where interactive response is more important
> >> > than not OOMing.
> >> >
> >> > With this patch and min_filelist_kbytes set to 50000, I see very little
> >> > block layer activity during low memory. The system stays responsive under
> >> > low memory and browser tab switching is fast. Eventually, a process a gets
> >> > killed by OOM. Without this patch, the system gets wedged for minutes
> >> > before it eventually OOMs. Below is the vmstat output from my test runs.
> >> >
> >> > BEFORE (notice the high bi and wa, also how long it takes to OOM):
> >>
> >> That's an interesting result.
> >>
> >> Having the machine "wedged for minutes" thrashing away paging
> >> executable text is pretty bad behaviour. A I wonder how to fix it.
> >> Perhaps simply declaring oom at an earlier stage.
> >>
> >> Your patch is certainly simple enough but a bit sad. A It says "the VM
> >> gets this wrong, so lets just disable it all". A And thereby reduces the
> >> motivation to fix it for real.
> >>
> >
> > Yeah, I used the RFC label because we're thinking this is just a temporary
> > bandaid until something better comes along.
> >
> > Couple of other nits I have with our patch:
> > * Not really sure what to do for the cgroup case. We do something
> > A reasonable for now.
> > * One of my colleagues also brought up the point that we might want to do
> > A something different if swap was enabled.
> >
> >> But the patch definitely improves the situation in real-world
> >> situations and there's a case to be made that it should be available at
> >> least as an interim thing until the VM gets fixed for real. A Which
> >> means that the /proc tunable might disappear again (or become a no-op)
> >> some time in the future.
> 
> I think this feature that "System response time doesn't allow but OOM allow".
> While we can control process to not killed by OOM using
> /oom_score_adj, we can't control response time directly.
> But in mobile system, we have to control response time. One of cause
> to avoid swap is due to response time.
> 
> How about using memcg?
> Isolate processes related to system response(ex, rendering engine, IPC
> engine and so no)  to another group.
> 
Yes, this seems interesting topic on memcg.

maybe configure cgroups as..

/system       ....... limit to X % of the system.
/application  ....... limit to 100-X % of the system.

and put management software to /system. Then, the system software can check
behavior of applicatoin and measure cpu time and I/O performance in /applicaiton.
(And yes, it can watch memory usage.)

Here, memory cgroup has oom-notifier, you may able to do something other than
oom-killer by the system. If this patch is applied to global VM, I'll check
memcg can support it or not.
Hmm....checking anon/file rate in /application may be enough ?

Or, as a google guy proosed, we may have to add "file-cache-only" memcg.
For example, configure system as

/system
/application-anon
/application-file-cache

(But balancing file/anon must be done by user....this is difficult.)

BTW, can we know that "recently paged out file cache comes back immediately!"
score ?


Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
