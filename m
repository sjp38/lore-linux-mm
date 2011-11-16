Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A36D76B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 14:05:46 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 17 Nov 2011 00:35:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAGJ5bHS4866088
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 00:35:37 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAGJ5bij031215
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 00:35:37 +0530
Message-ID: <4EC40980.90207@linux.vnet.ibm.com>
Date: Thu, 17 Nov 2011 00:35:36 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
References: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com> <20111116162601.GB18919@google.com> <4EC3F146.7050801@linux.vnet.ibm.com> <20111116174302.GD18919@google.com> <4EC3FFC4.2010904@linux.vnet.ibm.com> <20111116184157.GA25497@google.com>
In-Reply-To: <20111116184157.GA25497@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/17/2011 12:11 AM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 16, 2011 at 11:54:04PM +0530, Srivatsa S. Bhat wrote:
>> Ok, so by "proper solution", are you referring to a totally different
>> method (than grabbing pm_mutex) to implement mutual exclusion between
>> subsystems and suspend/hibernation, something like the suspend blockers
>> stuff and friends?
>> Or are you hinting at just the existing code itself being fixed more
>> properly than what this patch does, to avoid having side effects like
>> you pointed out?
> 
> Oh, nothing fancy.  Just something w/o busy looping would be fine.
> The stinking thing is we don't have mutex_lock_freezable().  Lack of
> proper freezable interface seems to be a continuing problem and I'm
> not sure what the proper solution should be at this point.  Maybe we
> should promote freezable to a proper task state.  Maybe freezable
> kthread is a bad idea to begin with.  Maybe instead of removing
> freezable_with_signal() we should make that default, that way,
> freezable can hitch on the pending signal handling (this creates
> another set of problems tho - ie. who's responsible for clearing
> TIF_SIGPENDING?).  I don't know.
> 

Thanks a lot for the explanation! I now get an idea about your thoughts
on the fundamental issues with the freezer that are causing a broad range
of problems... Hmm, definitely something to ponder over...

> Maybe just throw in msleep(10) there with fat ugly comment explaining
> why the hack is necessary?
> 

Hehe, that surely sounds like the simplest of all the approaches you
suggested ;-) I'll add this to the while loop in the patch and repost
it, hoping we can solve the fundamental issues effectively at a later time.

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
