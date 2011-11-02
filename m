Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED8E6B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 11:31:38 -0400 (EDT)
Received: by pzk6 with SMTP id 6so608074pzk.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2011 08:31:35 -0700 (PDT)
Date: Wed, 2 Nov 2011 08:31:46 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: Issue with core dump
Message-ID: <20111102153146.GC12543@dhcp-172-17-108-109.mtv.corp.google.com>
References: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com>
 <20111101152320.GA30466@redhat.com>
 <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trisha yad <trisha1march@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>

Hello,

On Wed, Nov 02, 2011 at 12:03:39PM +0530, trisha yad wrote:
> In loaded embedded system the time at with code hit do_user_fault()
> and core_dump_wait() is bit
> high, I check on my  system it took 2.7 sec. so it is very much
> possible that core dump is not correct.

This may sound like arguing over semantics but it doesn't matter how
long it takes, it's still correct.  You're arguing that it's not
immediate enough.  IOW, no matter how fast you make it, you cannot
guarantee that results from slow operation wouldn't appear.

Also, the time between do_user_fault() and actual core dumping isn't
the important factor here.  do_user_fault() directly triggers delivery
of SIGSEGV (or BUS) and signal delivery will immediately deliver
SIGKILL to all other threads in the process, so it should be immediate
enough, or, rather, we don't have any way to make it any more
immediate.  It's basically direct call + IPI (if some threads are
running on other cpus).

Are you actually seeing artifacts from delayed core dump?  Given the
code path, I'm highly skeptical that would be the actual case.  If
you're using shared memory between different processes, then that
delay would matter but for such cases there's nothing much to do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
