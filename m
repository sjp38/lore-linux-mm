Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6636B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:52:50 -0500 (EST)
Received: by vbbfq11 with SMTP id fq11so3618742vbb.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 09:52:46 -0800 (PST)
Date: Mon, 21 Nov 2011 09:52:42 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111121175242.GE15314@google.com>
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
 <201111192257.19763.rjw@sisk.pl>
 <4EC8984E.30005@linux.vnet.ibm.com>
 <201111201124.17528.rjw@sisk.pl>
 <4EC9D557.9090008@linux.vnet.ibm.com>
 <20111121164006.GB15314@google.com>
 <4ECA84A8.5030005@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ECA84A8.5030005@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello,

On Mon, Nov 21, 2011 at 10:34:40PM +0530, Srivatsa S. Bhat wrote:
> >> I haven't tested this solution yet. Let me know if this solution looks
> >> good and I'll send it out as a patch after testing and analyzing some
> >> corner cases, if any.
> 
> I tested this, and it works great! I'll send the patch in some time.

Awesome.

> > * I think it would be better to remove direct access to pm_mutex and
> >   use [un]lock_system_sleep() universally.  I don't think hinging it
> >   on CONFIG_HIBERNATE_CALLBACKS buys us anything.
> > 
> 
> Which direct access to pm_mutex are you referring to?
> Other than suspend/hibernation call paths, I think mem-hotplug is the only
> subsystem trying to access pm_mutex. I haven't checked thoroughly though. 
> 
> But yes, using lock_system_sleep() for mutually excluding some code path
> from suspend/hibernation is good, and that is one reason why I wanted
> to fix this API ASAP. But as long as memory hotplug is the only direct user
> of pm_mutex, is it justified to remove the CONFIG_HIBERNATE_CALLBACKS
> restriction and make it generic? I don't know...
> 
> Or, are you saying that we should use these APIs even in suspend/hibernate
> call paths? That's not such a bad idea either...

Yeap, all.  It's just confusing to have two different types of access
to a single lock and I don't believe CONFIG_HIBERNATE_CALLBACKS is a
meaningful optimization in this case.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
