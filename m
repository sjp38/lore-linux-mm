Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C33786B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 16:04:09 -0400 (EDT)
Message-ID: <51783AE2.4010402@parallels.com>
Date: Thu, 25 Apr 2013 00:04:50 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-2-git-send-email-glommer@openvz.org> <xr937gjrhg1f.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr937gjrhg1f.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/24/2013 11:42 PM, Greg Thelen wrote:
> On Tue, Apr 23 2013, Glauber Costa wrote:
> 
>> From: Glauber Costa <glommer@parallels.com>
>>
>> During the past weeks, it became clear to us that the shrinker interface
>> we have right now works very well for some particular types of users,
>> but not that well for others. The later are usually people interested in
>> one-shot notifications, that were forced to adapt themselves to the
>> count+scan behavior of shrinkers. To do so, they had no choice than to
>> greatly abuse the shrinker interface producing little monsters all over.
>>
>> During LSF/MM, one of the proposals that popped out during our session
>> was to reuse Anton Voronstsov's vmpressure for this. They are designed
>> for userspace consumption, but also provide a well-stablished,
>> cgroup-aware entry point for notifications.
>>
>> This patch extends that to also support in-kernel users. Events that
>> should be generated for in-kernel consumption will be marked as such,
>> and for those, we will call a registered function instead of triggering
>> an eventfd notification.
>>
>> Please note that due to my lack of understanding of each shrinker user,
>> I will stay away from converting the actual users, you are all welcome
>> to do so.
>>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
>> Cc: John Stultz <john.stultz@linaro.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Joonsoo Kim <js1304@gmail.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> ---
>>  include/linux/vmpressure.h |  6 ++++++
>>  mm/vmpressure.c            | 48 ++++++++++++++++++++++++++++++++++++++++++----
>>  2 files changed, 50 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
>> index 76be077..1862012 100644
>> --- a/include/linux/vmpressure.h
>> +++ b/include/linux/vmpressure.h
>> @@ -19,6 +19,9 @@ struct vmpressure {
>>  	/* Have to grab the lock on events traversal or modifications. */
>>  	struct mutex events_lock;
>>  
>> +	/* false if only kernel users want to be notified, true otherwise */
>> +	bool notify_userspace;
>> +
>>  	struct work_struct work;
>>  };
>>  
>> @@ -36,6 +39,9 @@ extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
>>  extern int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>>  				     struct eventfd_ctx *eventfd,
>>  				     const char *args);
>> +
>> +extern int vmpressure_register_kernel_event(struct cgroup *cg,
>> +					    void (*fn)(void));
>>  extern void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
>>  					struct eventfd_ctx *eventfd);
>>  #else
>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> index 736a601..8d77ad0 100644
>> --- a/mm/vmpressure.c
>> +++ b/mm/vmpressure.c
>> @@ -135,8 +135,12 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>  }
>>  
>>  struct vmpressure_event {
>> -	struct eventfd_ctx *efd;
>> +	union {
>> +		struct eventfd_ctx *efd;
>> +		void (*fn)(void);
>> +	};
>>  	enum vmpressure_levels level;
>> +	bool kernel_event;
>>  	struct list_head node;
>>  };
>>  
>> @@ -152,7 +156,9 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>>  	mutex_lock(&vmpr->events_lock);
>>  
>>  	list_for_each_entry(ev, &vmpr->events, node) {
>> -		if (level >= ev->level) {
>> +		if (ev->kernel_event)
>> +			ev->fn();
>> +		else if (vmpr->notify_userspace && (level >= ev->level)) {
>>  			eventfd_signal(ev->efd, 1);
>>  			signalled = true;
>>  		}
>> @@ -227,7 +233,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>  	 * we account it too.
>>  	 */
>>  	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
>> -		return;
>> +		goto schedule;
>>  
>>  	/*
>>  	 * If we got here with no pages scanned, then that is an indicator
>> @@ -238,14 +244,16 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>  	 * through vmpressure_prio(). But so far, keep calm.
>>  	 */
>>  	if (!scanned)
>> -		return;
>> +		goto schedule;
>>  
>>  	mutex_lock(&vmpr->sr_lock);
>>  	vmpr->scanned += scanned;
>>  	vmpr->reclaimed += reclaimed;
>> +	vmpr->notify_userspace = true;
> 
> Should notify_userspace get cleared sometime?  Seems like we might need
> to clear or decrement notify_userspace in vmpressure_event() when
> calling eventfd_signal().
> 

Hhummm, I was kind of assuming that it would always reach this point
zeroed. But looking at the code again, I am wrong, and you are right: it
should be cleared as soon as the notifications are fired.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
