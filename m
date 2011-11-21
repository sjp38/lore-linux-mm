Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 387BD6B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 03:23:03 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 21 Nov 2011 08:21:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAL8JRiV3252394
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:19:27 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAL8MhQD010442
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:22:44 +1100
Message-ID: <4ECA0A50.7030502@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2011 13:52:40 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <201111192257.19763.rjw@sisk.pl> <4EC8984E.30005@linux.vnet.ibm.com> <201111201124.17528.rjw@sisk.pl> <4EC9D557.9090008@linux.vnet.ibm.com> <4ECA03DF.4000402@linux.intel.com>
In-Reply-To: <4ECA03DF.4000402@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/21/2011 01:25 PM, Chen Gong wrote:
> [...]
>>
>> Actually, I think I have a better idea based on a key observation:
>> We are trying to acquire pm_mutex here. And if we block due to this,
>> we are *100% sure* that we are not going to run as long as hibernation
>> sequence is running, since hibernation releases pm_mutex only at the
>> very end, when everything is done.
>> And this means, this task is going to be blocked for much more longer
>> than what the freezer intends to achieve. Which means, freezing and
>> thawing doesn't really make a difference to this task!
>>
>> So, let's just ask the freezer to skip freezing us!! And everything
>> will be just fine!
>>
>> Something like:
>>
>> void lock_system_sleep(void)
>> {
>>     /* simplified freezer_do_not_count() */
>>     current->flags |= PF_FREEZER_SKIP;
>>
>>     mutex_lock(&pm_mutex);
>>
>> }
>>
>> void unlock_system_sleep(void)
>> {
>>     mutex_unlock(&pm_mutex);
>>
>>     /* simplified freezer_count() */
>>     current->flags&= ~PF_FREEZER_SKIP;
>>
>> }
>>
>> We probably don't want the restriction that freezer_do_not_count() and
>> freezer_count() work only for userspace tasks. So I have open coded
>> the relevant parts of those functions here.
>>
> 
> This new design looks clean and better than old one. I just curious how do
> you design your test environment? e.g. when hibernating is in progress,
> try to online some memories and wait for hibernation fails or succeeds?
> 

Hi Chen,

Thanks a lot for taking a look!

As I have indicated earlier in some of my mails, I am more concerned about
the API lock_system_sleep() than memory hotplug, because it is this *API*
that is buggy, not memory-hotplug. And going further, any other code planning
to use this API will be problematic. So our focus here, is to fix this *API*.

So, to test this API, I have written a kernel module that calls
lock_system_sleep() in its init code. Then I load/unload that module wildly
in a loop and simultaneously run hibernation tests using the 'pm_test'
framework. It is to be also noted that, the issue here is only with the initial
steps of hibernation, namely, related to freezer. Hence, pm_test framework
fits pretty well to debug these freezer issues. (And in fact, I have found that
this method is quite effective to test whether my patch fixes the issue or not.)

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
