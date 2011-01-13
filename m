Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 22D726B00EF
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:20:39 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p0DMKa3H027039
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:20:36 -0800
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by hpaq12.eem.corp.google.com with ESMTP id p0DMKX3q004450
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:20:34 -0800
Received: by pwj9 with SMTP id 9so443753pwj.7
        for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:20:33 -0800 (PST)
Date: Thu, 13 Jan 2011 14:20:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [RFC][PATCH 0/2] Tunable watermark
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF645@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1101131414110.26770@chino.kir.corp.google.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF645@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, dle-develop@lists.sourceforge.net, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2011, Satoru Moriya wrote:

> > You didn't mention why it wouldn't be possible to modify 
> > setup_per_zone_wmarks() in some way for your configuration so this happens 
> > automatically.  If you can find a deterministic way to set these 
> > watermarks from userspace, you should be able to do it in the kernel as 
> > well based on the configuration.
> 
> Do you mean that we should introduce a mechanism into kernel that changes
> watermarks dynamically depending on its loads (such as cpu frequency control)
> or we should change the calculation method in setup_per_zone_wmarks()?
> 

The watermarks you're exposing through this patchset to userspace for the 
first time are meant to be internal to the VM.  Userspace is not intended 
to manipulate them in an effort to cover-up deficiencies within the memory 
manager itself.  If you have actual cases where tuning the watermarks from 
userspace is helpful, then it logically means:

 - the VM is acting incorrectly in response to situations where it 
   approaches the tunable min watermark (all watermarks are a function of 
   the min watermark) which shouldn't representative in just a handfull
   of cases, and

 - you can deterministically do the same calculation within the kernel
   itself.

I'm skeptical that any tuning is actually helpful to your workload that 
doesn't also indicate a problem internal to the VM itself.  I think what 
would be more helpful is if you would show how the watermarks currently 
don't trigger fast enough (or aggressive enough) and then address the 
issue in the kernel itself so everyone can benefit from your work, whether 
that's adjusting where the watermarks are based on external factors or 
whether the semantics of those watermarks are to slightly change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
