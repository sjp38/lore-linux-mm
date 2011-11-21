Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAF86B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 11:40:13 -0500 (EST)
Received: by iaek3 with SMTP id k3so10004972iae.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:40:11 -0800 (PST)
Date: Mon, 21 Nov 2011 08:40:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111121164006.GB15314@google.com>
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
 <201111192257.19763.rjw@sisk.pl>
 <4EC8984E.30005@linux.vnet.ibm.com>
 <201111201124.17528.rjw@sisk.pl>
 <4EC9D557.9090008@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EC9D557.9090008@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello, Srivatsa.

On Mon, Nov 21, 2011 at 10:06:39AM +0530, Srivatsa S. Bhat wrote:
> void lock_system_sleep(void)
> {
> 	/* simplified freezer_do_not_count() */
> 	current->flags |= PF_FREEZER_SKIP;
> 
> 	mutex_lock(&pm_mutex);
> 
> }
> 
> void unlock_system_sleep(void)
> {
> 	mutex_unlock(&pm_mutex);
> 
> 	/* simplified freezer_count() */
> 	current->flags &= ~PF_FREEZER_SKIP;
> 
> }
> 
> We probably don't want the restriction that freezer_do_not_count() and
> freezer_count() work only for userspace tasks. So I have open coded
> the relevant parts of those functions here.
> 
> I haven't tested this solution yet. Let me know if this solution looks
> good and I'll send it out as a patch after testing and analyzing some
> corner cases, if any.

Ooh ooh, I definitely like this one much better.  Oleg did something
similar w/ wait_event_freezekillable() too.  On related notes,

* I think it would be better to remove direct access to pm_mutex and
  use [un]lock_system_sleep() universally.  I don't think hinging it
  on CONFIG_HIBERNATE_CALLBACKS buys us anything.

* In the longer term, we should be able to toggle PF_NOFREEZE instead
  as SKIP doesn't mean anything different.  We'll probably need a
  better API tho.  But for now SKIP should work fine.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
