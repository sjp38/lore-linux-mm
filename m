Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1306008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:23:12 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o4PAN8hI025035
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:23:08 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz5.hot.corp.google.com with ESMTP id o4PAN6bR012682
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:23:06 -0700
Received: by pvc21 with SMTP id 21so1452180pvc.35
        for <linux-mm@kvack.org>; Tue, 25 May 2010 03:23:06 -0700 (PDT)
Date: Tue, 25 May 2010 03:23:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100525100559.GI5087@laptop>
Message-ID: <alpine.DEB.2.00.1005250314440.8045@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100524100840.1E95.A69D9226@jp.fujitsu.com> <20100524070714.GV2516@laptop> <alpine.DEB.2.00.1005250242260.8045@chino.kir.corp.google.com> <20100525100559.GI5087@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Nick Piggin wrote:

> OK, you still never justified why that change is needed, or why it
> is even a cleanup at all. You need actually a *good* reason to change
> the user kernel API. A slight difference in opinion of what the sysctls
> should be, or a slight change in implementation in the kernel, is not
> a good reason in the slightest.
> 

My personal opinion (and it's no longer what I'm advocating since I'm 
hoping that the much larger importance of this patchset can now be 
realized without this sideshow) is that if we have the opportunity to 
consolidate two virtually unused sysctls into one to cleanup procfs and 
make extending the oom killer easier in the future without the need to add 
additional sysctls for systems that cannot afford a tasklist scan that we 
should do it.  I didn't think anyone was using them (nobody can be cited 
as using them) and I felt the two year deprecation period was enough to be 
able to cleanup the ever-growing list of VM sysctls as well as making it 
easier to extend in the future by adding a sysctl that had semantics 
specifically directed to its target audience.

> The point about not many people using the parameters I don't think is
> a good one. 2.6.32 is being used in the next enterprise kernels so they
> are going to be in production for 5 or more years. How many people will
> have written scripts by the time they upgrade?
> 

If nothing else, this solidifies in my mind the notion that once a VM 
sysctl is added, it can never be removed.  I regret adding 
oom_kill_allocating_task at the mere suggestion of SGI when I made cpuset 
ooms do a tasklist scan without developing a more extendable interface for 
those large systems that we could piggyback on later for the same reasons 
(we'd now need to disable oom_dump_tasks once it's the default for those 
systems).  I felt the deprecation and removal would eventually be 
sufficient, but I'm no longer going to push it because it's sidetracking a 
much larger and seperate effort.

> > I've made that change in my latest patch series which I'll be posting 
> > shortly.
> 
> The other thing is that it makes perfect sense to put controversial
> changes on hold even if you still think you can make a case for them.

I personally like consistency even amongst architectures when it comes to 
the semantics of sysctls, so the pagefault oom handling changes were 
merely for compatibility until all architectures were converted to using 
the oom killer.  You've done that work, so I no longer have a problem with 
panicking when the pagefault handler is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
