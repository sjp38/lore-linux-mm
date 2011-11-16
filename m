Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B93A6B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 13:42:04 -0500 (EST)
Received: by iaek3 with SMTP id k3so1368903iae.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 10:42:02 -0800 (PST)
Date: Wed, 16 Nov 2011 10:41:57 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111116184157.GA25497@google.com>
References: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com>
 <20111116162601.GB18919@google.com>
 <4EC3F146.7050801@linux.vnet.ibm.com>
 <20111116174302.GD18919@google.com>
 <4EC3FFC4.2010904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EC3FFC4.2010904@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Nov 16, 2011 at 11:54:04PM +0530, Srivatsa S. Bhat wrote:
> Ok, so by "proper solution", are you referring to a totally different
> method (than grabbing pm_mutex) to implement mutual exclusion between
> subsystems and suspend/hibernation, something like the suspend blockers
> stuff and friends?
> Or are you hinting at just the existing code itself being fixed more
> properly than what this patch does, to avoid having side effects like
> you pointed out?

Oh, nothing fancy.  Just something w/o busy looping would be fine.
The stinking thing is we don't have mutex_lock_freezable().  Lack of
proper freezable interface seems to be a continuing problem and I'm
not sure what the proper solution should be at this point.  Maybe we
should promote freezable to a proper task state.  Maybe freezable
kthread is a bad idea to begin with.  Maybe instead of removing
freezable_with_signal() we should make that default, that way,
freezable can hitch on the pending signal handling (this creates
another set of problems tho - ie. who's responsible for clearing
TIF_SIGPENDING?).  I don't know.

Maybe just throw in msleep(10) there with fat ugly comment explaining
why the hack is necessary?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
