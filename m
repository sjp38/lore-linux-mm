Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 73D196B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 06:19:16 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so671001pbc.26
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 03:19:16 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 2 Oct 2013 20:19:02 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A6ECB3578040
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:18:59 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r92AIeWF7864598
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 20:18:48 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r92AIoGe009897
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 20:18:51 +1000
Message-ID: <524BF210.4070301@linux.vnet.ibm.com>
Date: Wed, 02 Oct 2013 15:44:40 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com> <7632387.20FXkuCITr@vostro.rjw.lan> <524B0233.8070203@linux.vnet.ibm.com> <20131001173615.GW3657@laptop.programming.kicks-ass.net> <524B111F.9060003@linux.vnet.ibm.com>
In-Reply-To: <524B111F.9060003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On 10/01/2013 11:44 PM, Srivatsa S. Bhat wrote:
> On 10/01/2013 11:06 PM, Peter Zijlstra wrote:
>> On Tue, Oct 01, 2013 at 10:41:15PM +0530, Srivatsa S. Bhat wrote:
>>> However, as Oleg said, its definitely worth considering whether this proposed
>>> change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
>>> proved to be very useful in certain challenging situations (commit 1aee40ac9c
>>> explains one such example), so IMHO we should be very careful not to undermine
>>> its utility.
>>
>> Urgh.. crazy things. I've always understood POST_DEAD to mean 'will be
>> called at some time after the unplug' with no further guarantees. And my
>> patch preserves that.
>>
>> Its not at all clear to me why cpufreq needs more; 1aee40ac9c certainly
>> doesn't explain it.
>>
> 
> Sorry if I was unclear - I didn't mean to say that cpufreq needs more guarantees
> than that. I was just saying that the cpufreq code would need certain additional
> changes/restructuring to accommodate the change in the semantics brought about
> by this patch. IOW, it won't work as it is, but it can certainly be fixed.
> 


Ok, so I thought a bit more about the changes you are proposing, and I agree
that they would be beneficial in the long run, especially given that it can
eventually lead to a more stream-lined hotplug process where different CPUs
can be hotplugged independently without waiting on each other, like you
mentioned in your other mail. So I'm fine with the new POST_DEAD guarantees
you are proposing - that they are run after unplug, and will be completed
before UP_PREPARE of the same CPU. And its also very convenient that we need
to fix only cpufreq to accommodate this change.

So below is a quick untested patch that modifies the cpufreq hotplug
callbacks appropriately. With this, cpufreq should be able to handle the
POST_DEAD changes, irrespective of whether we do that in the regular path
or in the suspend/resume path. (Because, I've restructured it in such a way
that the races that I had mentioned earlier are totally avoided. That is,
the POST_DEAD handler now performs only the bare-minimal final cleanup, which
doesn't race with or depend on anything else).



diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index 04548f7..0a33c1a 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -1165,7 +1165,7 @@ static int __cpufreq_remove_dev_prepare(struct device *dev,
 					bool frozen)
 {
 	unsigned int cpu = dev->id, cpus;
-	int new_cpu, ret;
+	int new_cpu, ret = 0;
 	unsigned long flags;
 	struct cpufreq_policy *policy;
 
@@ -1200,9 +1200,10 @@ static int __cpufreq_remove_dev_prepare(struct device *dev,
 			policy->governor->name, CPUFREQ_NAME_LEN);
 #endif
 
-	lock_policy_rwsem_read(cpu);
+	lock_policy_rwsem_write(cpu);
 	cpus = cpumask_weight(policy->cpus);
-	unlock_policy_rwsem_read(cpu);
+	cpumask_clear_cpu(cpu, policy->cpus);
+	unlock_policy_rwsem_write(cpu);
 
 	if (cpu != policy->cpu) {
 		if (!frozen)
@@ -1220,7 +1221,23 @@ static int __cpufreq_remove_dev_prepare(struct device *dev,
 		}
 	}
 
-	return 0;
+	/* If no target, nothing more to do */
+	if (!cpufreq_driver->target)
+		return 0;
+
+	/* If cpu is last user of policy, cleanup the policy governor */
+	if (cpus == 1) {
+		ret = __cpufreq_governor(policy, CPUFREQ_GOV_POLICY_EXIT);
+		if (ret)
+			pr_err("%s: Failed to exit governor\n",	__func__);
+	} else {
+		if ((ret = __cpufreq_governor(policy, CPUFREQ_GOV_START)) ||
+				(ret = __cpufreq_governor(policy, CPUFREQ_GOV_LIMITS))) {
+			pr_err("%s: Failed to start governor\n", __func__);
+		}
+	}
+
+	return ret;
 }
 
 static int __cpufreq_remove_dev_finish(struct device *dev,
@@ -1243,25 +1260,12 @@ static int __cpufreq_remove_dev_finish(struct device *dev,
 		return -EINVAL;
 	}
 
-	WARN_ON(lock_policy_rwsem_write(cpu));
+	WARN_ON(lock_policy_rwsem_read(cpu));
 	cpus = cpumask_weight(policy->cpus);
-
-	if (cpus > 1)
-		cpumask_clear_cpu(cpu, policy->cpus);
-	unlock_policy_rwsem_write(cpu);
+	unlock_policy_rwsem_read(cpu);
 
 	/* If cpu is last user of policy, free policy */
-	if (cpus == 1) {
-		if (cpufreq_driver->target) {
-			ret = __cpufreq_governor(policy,
-					CPUFREQ_GOV_POLICY_EXIT);
-			if (ret) {
-				pr_err("%s: Failed to exit governor\n",
-						__func__);
-				return ret;
-			}
-		}
-
+	if (cpus == 0) {
 		if (!frozen) {
 			lock_policy_rwsem_read(cpu);
 			kobj = &policy->kobj;
@@ -1294,15 +1298,6 @@ static int __cpufreq_remove_dev_finish(struct device *dev,
 
 		if (!frozen)
 			cpufreq_policy_free(policy);
-	} else {
-		if (cpufreq_driver->target) {
-			if ((ret = __cpufreq_governor(policy, CPUFREQ_GOV_START)) ||
-					(ret = __cpufreq_governor(policy, CPUFREQ_GOV_LIMITS))) {
-				pr_err("%s: Failed to start governor\n",
-						__func__);
-				return ret;
-			}
-		}
 	}
 
 	per_cpu(cpufreq_cpu_data, cpu) = NULL;



Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
