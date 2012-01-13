Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 63D1A6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:35:28 -0500 (EST)
Received: by ggnp4 with SMTP id p4so2422302ggn.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 13:35:27 -0800 (PST)
Date: Fri, 13 Jan 2012 13:35:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
In-Reply-To: <84FF21A720B0874AA94B46D76DB982690455759C@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201131328540.24089@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195521.GA19181@suse.de> <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com> <alpine.DEB.2.00.1201091251300.10232@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB98269045568A1@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201111338320.21755@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904556CB7@008-AM1MPN1-003.mgdnok.nokia.com> <alpine.DEB.2.00.1201121247480.17287@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904557417@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201130253560.15417@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB982690455759C@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Fri, 13 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> > Your memory threshold, as proposed, will have values that are tied directly to the
> > implementation of the VM in the kernel when its under memory pressure
> > and that implementation evolves at a constant rate.
> 
> Not sure that I understand this statement. Free/Used/Active page sets 
> are properties of any VM.

The point at which the latency is deemed to be unacceptable in your 
trail-and-error is tied directly to the implementation of the VM and must 
be recalibrated with each userspace change or kernel upgrade.  I assume 
here that some reclaim is allowed in the VM for your usecase; if not, then 
I already gave a solution for how to disable that entirely.

>  The thresholds are set by user-space and individual for applications 
> which likes to be informed.
> 

You haven't given a usecase for the thresholds for anything other than 
when you're just about oom, and I think it's much simpler if you actually 
get to the point of oom and your userspace notifier is guaranteed to be 
able to respond over a preconfigured delay.  It works pretty well for us 
internally, you should consider it.

> > mlock() the memory that your userspace monitoring needs to send signals to
> > applications, whether those signals are handled to free memory internally or
> > its SIGTERM or SIGKILL.
> 
> Mlocked memory should be avoid as much as possible because efficiency 
> rate is lowest possible and makes situation for non-mlocked pages even 
> worse.

It's used only to protect the thread that is notified right before the oom 
killer is triggered so that it can send the appropriate signals.  If it 
can't do that, the oom killer delay will expire on subsequent memory 
allocation attempts and kill something itself.  This thread should have a 
minimal memory footprint, be mlock()'d into memory, and have an 
oom_score_adj of OOM_SCORE_ADJ_MIN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
