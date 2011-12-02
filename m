Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B98E76B004F
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 20:59:28 -0500 (EST)
Date: Fri, 2 Dec 2011 12:59:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-ID: <20111202015921.GZ7046@dastard>
References: <20111201093644.GW7046@dastard>
 <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
 <20111201124634.GY7046@dastard>
 <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 01, 2011 at 02:35:31PM -0800, David Rientjes wrote:
> On Thu, 1 Dec 2011, Dave Chinner wrote:
> 
> > > /*
> > >  * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
> > >  * pid.
> > >  */
> > > #define OOM_SCORE_ADJ_MIN       (-1000)
> > > 
> > >  
> > > IIUC, this task cannot be killed by oom-killer because of oom_score_adj settings.
> > 
> > It's not me or the test suite that setting this, so it's something
> > the kernel must be doing automagically.
> > 
> 
> The kernel does not set oom_score_adj to ever disable oom killing for a 
> thread.  The only time the kernel touches oom_score_adj is when setting it 
> to "1000" in ksm and swap to actually prefer a memory allocator for oom 
> killing.
> 
> It's also possible to change this value via the deprecated 
> /proc/pid/oom_adj interface until it is removed next year.  Check your 
> dmesg for warnings about using the deprecated oom_adj interface or change 
> the printk_once() in oom_adjust_write() to a normal printk() to catch it.

No warnings at all, as I've already said. If it is userspace,
whatever is doing it is using the oom_score_adj interface correctly.

Hmmm - google is finding reports of sshd randomly inheriting -17 at
startup depending modules loaded on debian systems. Except, I'm not
using a modular kernel and it's running in a VM so there's no
firmware being loaded.

Yup, all my systems end up with a random value for sessions logged
in via ssh:

$ ssh -X test-2
Linux test-2 3.2.0-rc3-dgc+ #114 SMP Thu Dec 1 22:14:55 EST 2011 x86_64
No mail.
Last login: Fri Dec  2 11:34:44 2011 from deranged
$ cat /proc/self/oom_adj
-17
$ sudo reboot;exit
[sudo] password for dave:

Broadcast message from root@test-2 (pts/0) (Fri Dec  2 12:39:39 2011):

The system is going down for reboot NOW!
logout
Connection to test-2 closed.
$ ssh -X test-2
Linux test-2 3.2.0-rc3-dgc+ #114 SMP Thu Dec 1 22:14:55 EST 2011 x86_64
No mail.
Last login: Fri Dec  2 12:40:15 2011 from deranged
$ cat /proc/self/oom_adj 
0
$ 

That'll be the root cause of the problem - I just caused an OOM
panic with test 019....

<sigh>

The reports all cycle around this loop:

	linux-mm says userspace/distro problem
	distro says openssh problem
	openssh says kernel problem

And there doesn't appear to be any resolution in any of the reports,
just circular finger pointing and frustrated users.

I can't find anything in the distro startup or udev scripts that
modify the oom parameters, and the openssh guys say they only
pass on the value inhereted from ssh's parent process, so it clearly
not obvious where the bug lies at this point. It's been around for
some time, though...

More digging to do...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
