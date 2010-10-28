Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 340F98D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:13:53 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o9SMDoZj018768
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:13:50 -0700
Received: from ywi4 (ywi4.prod.google.com [10.192.9.4])
	by kpbe14.cbf.corp.google.com with ESMTP id o9SMDCYx002663
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:13:48 -0700
Received: by ywi4 with SMTP id 4so2067698ywi.37
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:13:48 -0700 (PDT)
Date: Thu, 28 Oct 2010 15:03:31 -0700
From: Mandeep Singh Baines <msb@chromium.org>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-ID: <20101028220331.GZ26494@google.com>
References: <20101028191523.GA14972@google.com>
 <20101028131029.ee0aadc0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101028131029.ee0aadc0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

Andrew Morton (akpm@linux-foundation.org) wrote:
> On Thu, 28 Oct 2010 12:15:23 -0700
> Mandeep Singh Baines <msb@chromium.org> wrote:
> 
> > On ChromiumOS, we do not use swap.
> 
> Well that's bad.  Why not?
> 

We're using SSDs. We're still in the "make it work" phase so wanted
avoid swap unless/until we learn how to use it effectively with
an SSD.

You'll want to tune swap differently if you're using an SSD. Not sure
if swappiness is the answer. Maybe a new tunable to control how aggressive
swap is unless such a thing already exits?

> > When memory is low, the only way to
> > free memory is to reclaim pages from the file list. This results in a
> > lot of thrashing under low memory conditions. We see the system become
> > unresponsive for minutes before it eventually OOMs. We also see very
> > slow browser tab switching under low memory. Instead of an unresponsive
> > system, we'd really like the kernel to OOM as soon as it starts to
> > thrash. If it can't keep the working set in memory, then OOM.
> > Losing one of many tabs is a better behaviour for the user than an
> > unresponsive system.
> > 
> > This patch create a new sysctl, min_filelist_kbytes, which disables reclaim
> > of file-backed pages when when there are less than min_filelist_bytes worth
> > of such pages in the cache. This tunable is handy for low memory systems
> > using solid-state storage where interactive response is more important
> > than not OOMing.
> > 
> > With this patch and min_filelist_kbytes set to 50000, I see very little
> > block layer activity during low memory. The system stays responsive under
> > low memory and browser tab switching is fast. Eventually, a process a gets
> > killed by OOM. Without this patch, the system gets wedged for minutes
> > before it eventually OOMs. Below is the vmstat output from my test runs.
> > 
> > BEFORE (notice the high bi and wa, also how long it takes to OOM):
> 
> That's an interesting result.
> 
> Having the machine "wedged for minutes" thrashing away paging
> executable text is pretty bad behaviour.  I wonder how to fix it. 
> Perhaps simply declaring oom at an earlier stage.
> 
> Your patch is certainly simple enough but a bit sad.  It says "the VM
> gets this wrong, so lets just disable it all".  And thereby reduces the
> motivation to fix it for real.
> 

Yeah, I used the RFC label because we're thinking this is just a temporary
bandaid until something better comes along.

Couple of other nits I have with our patch:
* Not really sure what to do for the cgroup case. We do something
  reasonable for now.
* One of my colleagues also brought up the point that we might want to do
  something different if swap was enabled.

> But the patch definitely improves the situation in real-world
> situations and there's a case to be made that it should be available at
> least as an interim thing until the VM gets fixed for real.  Which
> means that the /proc tunable might disappear again (or become a no-op)
> some time in the future.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
