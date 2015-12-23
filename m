Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B69F06B0264
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:32:27 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l126so152686200wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 08:32:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n129si52049106wmb.97.2015.12.23.08.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 08:32:26 -0800 (PST)
Date: Wed, 23 Dec 2015 11:32:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Exhausting memory makes the system unresponsive but doesn't
 invoke OOM killer
Message-ID: <20151223163221.GA7520@cmpxchg.org>
References: <20151223143109.GC3519@orkisz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151223143109.GC3519@orkisz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Szewczyk <Marcin.Szewczyk@wodny.org>
Cc: linux-mm@kvack.org

Hi Marcin,

On Wed, Dec 23, 2015 at 03:31:09PM +0100, Marcin Szewczyk wrote:
> Hi,
> 
> In 2010 I noticed that viewing many GIFs in a row using gpicview renders 
> my Linux unresponsive. The problem still exists. There is very little 
> I can do in such a situation. Rarely after some minutes the OOM killer 
> kicks in and saves the day. Nevertheless, usually I end up using 
> Alt+SysRq+B.

Have you tried kicking the OOM killer manually with sysrq+f?

> What happens is gpicview exhausting whole available memory in such 
> a pattern that userspace becomes unresponsive. My application 
> (`crash.c`) allocates memory in a very similar way using GDK to 
> replicate the problem.
> 
> I keep the updated description of the problem and the source code here:
> https://github.com/wodny/crasher
> 
> I've originally posted to linux-kernel:
> http://marc.info/?t=145070009500007&r=1&w=2
> but got no response.
> 
> I'm using:
> 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt11-1+deb8u6 (2015-11-09) x86_64 GNU/Linux
> 
> ## Symptoms
> 
> The unresponsiveness goes with high CPU load and a lot of IO (read) 
> operations on the root file system and its block device.

There is a semi-known issue of heavily thrashing page cache. Your
crash program sucks up most memory and leaves very little for the
executables and libraries to be cached, which results in multiple
threads experiencing cache misses in their executable code, followed
by fighting over the few remaining page cache slots, which are not
enough to meet the demand at any given point in time. These threads
than end up spending a lot of time a) searching for reusable cache
slots and taking away slots that were only recently populated by
another thread, possibly before that other thread has returned to
userspace, and then b) waiting for disk to repopulate the cache slot
which will be stolen by another thread soon, possibly before this
thread had a chance to return to userspace as well.

That being said, there is no real solution to thrashing page cache as
of this day. We have most infrastructure in place to detect it, but it
isn't hooked up to the OOM killer yet. The only answer until then is
try to keep free+buffer+cache at at least 10-15% of overall memory.

Since you can reproduce it easily, is there any chance you could grab
backtraces (sysrq+t) of the tasks while the machine is in that state?
That should confirm that most tasks are either waiting for IO or are
inside page reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
