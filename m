Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 896D86B0070
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 16:44:47 -0500 (EST)
Received: by yenm2 with SMTP id m2so696550yen.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:44:46 -0800 (PST)
Date: Wed, 11 Jan 2012 13:44:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045568A1@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201111338320.21755@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195521.GA19181@suse.de> <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com> <alpine.DEB.2.00.1201091251300.10232@chino.kir.corp.google.com>
 <84FF21A720B0874AA94B46D76DB98269045568A1@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, 11 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> > So if the page allocator can make no progress in freeing memory, we would
> > introduce a delay in out_of_memory() if it were configured via a sysctl from
> > userspace.  When this delay is started, applications waiting on this event can
> > be notified with eventfd(2) that the delay has started and they have
> > however many milliseconds to address the situation.  When they rewrite the
> > sysctl, the delay is cleared.  If they don't rewrite the sysctl and the delay
> > expires, the oom killer proceeds with killing.
> > 
> > What's missing for your use case with this proposal?
> 
> Timed delays in multi-process handling in case OOM looks for me fragile 
> construction due to delays are not predicable.

Not sure what you mean by predictable; the oom conditions themselves 
certainly aren't predictable, otherwise you wouldn't need notification at 
all.  The delays are predictable since you configure it to be a number of 
millisecs via a global sysctl.  Userspace can either handle the oom itself 
and rewrite that sysctl to reset the delay or write 0 to make the kernel 
immediately oom.  If the delay expires, then it is assumed that userspace 
is dead and the kernel will proceed to avoid livelock.

> Memcg supports [1] better approach to freeze whole group and kick 
> pointed user-space application to handle it. We planned
> to use it as:
> - enlarge cgroup
> - send SIGTERM to selected "bad" application e.g. based on oom_score
> - wait a bit
> - send SIGKILL to "bad" application
> - reduce group size
> 
> But finally default OOM killer starts to work fine.
> 

I think you're misunderstanding the proposal; in the case of a global oom 
(that means without memcg) then, by definition, all threads that are 
allocating memory would be frozen and incur the delay at the point they 
would currently call into the oom killer.  If your userspace is alive, 
i.e. the application responsible for managing oom killing, then it can 
wait on eventfd(2), wake up, and then send SIGTERM and SIGKILL to the 
appropriate threads based on priority.

So, again, why wouldn't this work for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
