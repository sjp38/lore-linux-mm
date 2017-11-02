Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D80726B0260
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:46:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 198so2805656wmg.6
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:46:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si11890edc.14.2017.11.02.04.46.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:46:51 -0700 (PDT)
Date: Thu, 2 Nov 2017 12:46:50 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171102114650.GB31148@pathway.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171031153225.218234b4@gandalf.local.home>
 <187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
 <20171101133845.GF20040@pathway.suse.cz>
 <20171101113647.243eecf8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101113647.243eecf8@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Wed 2017-11-01 11:36:47, Steven Rostedt wrote:
> On Wed, 1 Nov 2017 14:38:45 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> > My current main worry with Steven's approach is a risk of deadlocks
> > that Jan Kara saw when he played with similar solution.
> 
> And if there exists such a deadlock, then the deadlock exists today.

The patch is going to effectively change console_trylock() to
console_lock() and this might add problems.

The most simple example is:

       console_lock()
         printk()
	    console_trylock() was SAFE.

       console_lock()
         printk()
	   console_lock() cause DEADLOCK!

Sure, we could detect this and avoid waiting when
console_owner == current. But does this cover all
situations? What about?

CPU0			CPU1

console_lock()          func()
  console->write()        take_lockA()
    func()		    printk()
			      busy wait for console_lock()

      take_lockA()

By other words, it used to be safe to call printk() from
console->write() functions because printk() used console_trylock().
Your patch is going to change this. It is even worse because
you probably will not use console_lock() directly and therefore
this might be hidden for lockdep.

BTW: I am still not sure how to make the busy waiter preferred
over console_lock() callers. I mean that the busy waiter has
to get console_sem even if there are some tasks in the workqueue.


> > But let's wait for the patch. It might look and work nicely
> > in the end.
> 
> Oh, I need to write a patch? Bah, I guess I should. Where's all those
> developers dying to do kernel programing where I can pass this off to?

Yes, where are these days when my primary task was to learn kernel
hacking? This would have been a great training material.

I still have to invest time into fixing printk. But I personally
think that the lazy offloading to kthreads is more promising
way to go. It is pretty straightforward. The only problem is
the guaranty of the takeover. But there must be a reasonable
way how to detect that the system heart is still beating
and we are not the only working CPU.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
