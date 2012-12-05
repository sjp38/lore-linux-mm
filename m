Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 466826B006C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 19:17:12 -0500 (EST)
Message-ID: <1354666628.6733.227.camel@calx>
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
From: Matt Mackall <mpm@selenic.com>
Date: Tue, 04 Dec 2012 18:17:08 -0600
In-Reply-To: <20121204152121.e5c33938.akpm@linux-foundation.org>
References: <50B8F2F4.6000508@parallels.com>
	 <20121203144310.7ccdbeb4.akpm@linux-foundation.org>
	 <50BD86DE.6050700@parallels.com>
	 <20121204152121.e5c33938.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 2012-12-04 at 15:21 -0800, Andrew Morton wrote:
> On Tue, 04 Dec 2012 09:15:10 +0400
> Pavel Emelyanov <xemul@parallels.com> wrote:
> 
> > 
> > > Two alternatives come to mind:
> > > 
> > > 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
> > >     fashion to determine which pages have been touched.

[momentarily coming out of kernel retirement for old man rant]

This is a popular interface anti-pattern.

You shouldn't use an interface that gives you huge amount of STATE to
detect small amounts of CHANGE via manual differentiation. For example,
you would be foolish to try to monitor an entire filesystem by stat()ing
all files on the disk continually. It will be massively slow, only sort
of work, and you'll miss changes sometimes. Instead, use inotify.

Similarly, you shouldn't try to use an interface that gives you small
amounts of CHANGE to get a large STATE via manual integration. For
instance, you would be silly to try to get the current timestamp on a
file by tracking every change to the filesystem since boot via inotify.
It would be massively slow, only sort of work, and you'll get wrong
answers sometimes. Instead, use stat().

Pagemap is unambiguously a STATE interface for making the kinds of
measurements that such interfaces are good for. If you try to use it as
a CHANGE interface, you may find sadness.

I don't know what a good CHANGE interface here might look like, but
tracepoints have been suggested in the past. If you want do something
UNIXy, you could teach inotify to report write iovecs and then make it
possible for /proc and /sys objects to report events through inotify.
Lots of other neat possibilities would fall out of that, of course.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
