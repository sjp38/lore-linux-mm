Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6CC346B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 02:59:18 -0500 (EST)
Message-ID: <4ECA03DF.4000402@linux.intel.com>
Date: Mon, 21 Nov 2011 15:55:11 +0800
From: Chen Gong <gong.chen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <201111192257.19763.rjw@sisk.pl> <4EC8984E.30005@linux.vnet.ibm.com> <201111201124.17528.rjw@sisk.pl> <4EC9D557.9090008@linux.vnet.ibm.com>
In-Reply-To: <4EC9D557.9090008@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

[...]
>
> Actually, I think I have a better idea based on a key observation:
> We are trying to acquire pm_mutex here. And if we block due to this,
> we are *100% sure* that we are not going to run as long as hibernation
> sequence is running, since hibernation releases pm_mutex only at the
> very end, when everything is done.
> And this means, this task is going to be blocked for much more longer
> than what the freezer intends to achieve. Which means, freezing and
> thawing doesn't really make a difference to this task!
>
> So, let's just ask the freezer to skip freezing us!! And everything
> will be just fine!
>
> Something like:
>
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
> 	current->flags&= ~PF_FREEZER_SKIP;
>
> }
>
> We probably don't want the restriction that freezer_do_not_count() and
> freezer_count() work only for userspace tasks. So I have open coded
> the relevant parts of those functions here.
>

This new design looks clean and better than old one. I just curious how do
you design your test environment? e.g. when hibernating is in progress,
try to online some memories and wait for hibernation fails or succeeds?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
