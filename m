Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 220096B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 20:01:48 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz10so2808611pad.7
        for <linux-mm@kvack.org>; Sun, 03 Mar 2013 17:01:47 -0800 (PST)
Date: Sun, 3 Mar 2013 17:01:42 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: per-cpu statistics
Message-ID: <20130304010142.GE3678@htj.dyndns.org>
References: <512F0E76.2020707@parallels.com>
 <5133F0FD.3040501@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5133F0FD.3040501@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Hello,

On Mon, Mar 04, 2013 at 09:55:25AM +0900, Kamezawa Hiroyuki wrote:
> An reason I didn't like percpu_counter *was* its memory layout.
> 
> ==
> struct percpu_counter {
>         raw_spinlock_t lock;
>         s64 count;
> #ifdef CONFIG_HOTPLUG_CPU
>         struct list_head list;  /* All percpu_counters are on a list */
> #endif
>         s32 __percpu *counters;
> };
> ==
> 
> Assume we have counters in an array, then, we'll have
> 
>    lock
>    count
>    list
>    pointer
>    lock
>    count
>    list
>    pointer
>    ....
> 
> An counter's lock ops will invalidate pointers in the array.
> We tend to update several counters at once.

I agree that percpu_counter leaves quite a bit to be desired.  It
would be great if we can implement generic percpu stats facility which
takes care of aggregating the values periodically preferably with
provisions to limit the amount of deviation global counter may reach.

Thansk.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
