Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B71B8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 05:14:34 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAFAEUQh021957
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:14:31 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz24.hot.corp.google.com with ESMTP id oAFAESB7019637
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:14:29 -0800
Received: by pvg7 with SMTP id 7so1131825pvg.36
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:14:27 -0800 (PST)
Date: Mon, 15 Nov 2010 02:14:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Revert oom rewrite series
In-Reply-To: <4CE0A87E.1030304@leadcoretech.com>
Message-ID: <alpine.DEB.2.00.1011150204060.2986@chino.kir.corp.google.com>
References: <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain> <20101114141913.E019.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com>
 <4CE0A87E.1030304@leadcoretech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010, Figo.zhang wrote:

> i am doubt that a new rewrite but the athor canot provide some evidence and
> experiment result, why did you do that? what is the prominent change for your
> new algorithm?
> 
> as KOSAKI Motohiro said, "you removed CAP_SYS_RESOURCE condition with ZERO
> explanation".
> 
> David just said that pls use userspace tunable for protection by
> oom_score_adj. but may i ask question:
> 
> 1. what is your innovation for your new algorithm, the old one have the same
> way for user tunable oom_adj.
> 

The goal was to make the oom killer heuristic as predictable as possible 
and to kill the most memory-hogging task to avoid having to recall it and 
needlessly kill several tasks.

The goal behind oom_score_adj vs. oom_adj was for several reasons, as 
pointed out before:

 - give it a unit (proportion of available memory), oom_adj had no unit,

 - allow it to work on a linear scale for more control over 
   prioritization, oom_adj had an exponential scale,

 - give it a much higher resolution so it can be fine-tuned, it works with 
   a granularity of 0.1% of memory (~128M on a 128G machine), and

 - allow it to describe the oom killing priority of a task regardless of 
   its cpuset attachment, mempolicy, or memcg, or when their respective
   limits change.

> 2. if server like db-server/financial-server have huge import processes (such
> as root/hardware access processes)want to be protection, you let the
> administrator to find out which processes should be protection. you
> will let the  financial-server administrator huge crazy!! and lose so many
> money!! ^~^
> 

You have full control over disabling a task from being considered with 
oom_score_adj just like you did with oom_adj.  Since oom_adj is 
deprecated for two years, you can even use the old interface until then.

> 3. i see your email in LKML, you just said
> "I have repeatedly said that the oom killer no longer kills KDE when run on my
> desktop in the presence of a memory hogging task that was written specifically
> to oom the machine."
> http://thread.gmane.org/gmane.linux.kernel.mm/48998
> 
> so you just test your new oom_killer algorithm on your desktop with KDE, so
> have you provide the detail how you do the test? is it do the
> experiment again for anyone and got the same result as your comment ?
> 

Xorg tends to be killed less because of the change to the heuristic's 
baseline, which is now based on rss and swap instead of total_vm.  This is 
seperate from the issues you list above, but is a benefit to the oom 
killer that desktop users especially will notice.  I, personally, am 
interested more in the server market and that's why I looked for a more 
robust userspace tunable that would still be applicable when things like 
cpusets have a node added or removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
