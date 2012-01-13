Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 308C16B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:06:24 -0500 (EST)
Received: by iafj26 with SMTP id j26so5557599iaf.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 03:06:23 -0800 (PST)
Date: Fri, 13 Jan 2012 03:06:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904557417@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201130253560.15417@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195521.GA19181@suse.de> <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com> <alpine.DEB.2.00.1201091251300.10232@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB98269045568A1@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201111338320.21755@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904556CB7@008-AM1MPN1-003.mgdnok.nokia.com> <alpine.DEB.2.00.1201121247480.17287@chino.kir.corp.google.com>
 <84FF21A720B0874AA94B46D76DB9826904557417@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Fri, 13 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> > Then it's fundamentally flawed since there's no guarantee that coming with
> > 100MB of the min watermark, for example, means that an oom is imminent
> > and will just result in unnecessary notification to userspace that will cause
> > some action to be taken that may not be necessary.  If the setting of these
> > thresholds depends on some pattern that is guaranteed to be along the path
> > to oom for a certain workload, then that will also change depending on VM
> > implementation changes, kernel versions, other applications, etc., and simply
> > is unmaintainable.
> 
> Why? That is expected that product tested and tuned properly, 
> applications fixed, and at least no apps installed which might consume 
> 100 MB in second or two.

I'm trying to make this easy for you, if you haven't noticed.  Your memory 
threshold, as proposed, will have values that are tied directly to the 
implementation of the VM in the kernel when its under memory pressure and 
that implementation evolves at a constant rate.

What I'm proposing is limiting the amount of latency that the VM incurs 
when under memory pressure, notify userspace, and allow it to react to the 
situation until the delay expires.  This doesn't require recalibration for 
other products or upgraded kernels, it just works all the time.

> Slowdown is natural thing if you have lack of space for code paging, I 
> do not see any ways to fix it.
> 

mlock() the memory that your userspace monitoring needs to send signals to 
applications, whether those signals are handled to free memory internally 
or its SIGTERM or SIGKILL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
