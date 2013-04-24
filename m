Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 22D1B6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 15:35:24 -0400 (EDT)
Received: by mail-gh0-f201.google.com with SMTP id r13so228986ghr.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 12:35:23 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
	<1366705329-9426-2-git-send-email-glommer@openvz.org>
	<xr93vc7cgzs0.fsf@gthelen.mtv.corp.google.com>
	<51779970.4010101@parallels.com>
Date: Wed, 24 Apr 2013 12:35:21 -0700
In-Reply-To: <51779970.4010101@parallels.com> (Glauber Costa's message of
	"Wed, 24 Apr 2013 12:36:00 +0400")
Message-ID: <xr93k3nrhgcm.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Apr 24 2013, Glauber Costa wrote:

> On 04/24/2013 11:21 AM, Greg Thelen wrote:
>> On Tue, Apr 23 2013, Glauber Costa wrote:
>> 
>>> From: Glauber Costa <glommer@parallels.com>
>>>
>>> During the past weeks, it became clear to us that the shrinker interface
>>> we have right now works very well for some particular types of users,
>>> but not that well for others. The later are usually people interested in
>>> one-shot notifications, that were forced to adapt themselves to the
>>> count+scan behavior of shrinkers. To do so, they had no choice than to
>>> greatly abuse the shrinker interface producing little monsters all over.
>>>
>>> During LSF/MM, one of the proposals that popped out during our session
>>> was to reuse Anton Voronstsov's vmpressure for this. They are designed
>>> for userspace consumption, but also provide a well-stablished,
>>> cgroup-aware entry point for notifications.
>>>
>>> This patch extends that to also support in-kernel users. Events that
>>> should be generated for in-kernel consumption will be marked as such,
>>> and for those, we will call a registered function instead of triggering
>>> an eventfd notification.
>>>
>>> Please note that due to my lack of understanding of each shrinker user,
>>> I will stay away from converting the actual users, you are all welcome
>>> to do so.
>>>
>>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>>> Cc: Dave Chinner <david@fromorbit.com>
>>> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
>>> Cc: John Stultz <john.stultz@linaro.org>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Joonsoo Kim <js1304@gmail.com>
>>> Cc: Michal Hocko <mhocko@suse.cz>
>>> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> ---
>>>  include/linux/vmpressure.h |  6 ++++++
>>>  mm/vmpressure.c            | 48 ++++++++++++++++++++++++++++++++++++++++++----
>>>  2 files changed, 50 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
>>> index 76be077..1862012 100644
>>> --- a/include/linux/vmpressure.h
>>> +++ b/include/linux/vmpressure.h
>>> @@ -19,6 +19,9 @@ struct vmpressure {
>>>  	/* Have to grab the lock on events traversal or modifications. */
>>>  	struct mutex events_lock;
>>>  
>>> +	/* false if only kernel users want to be notified, true otherwise */
>>> +	bool notify_userspace;
>>> +
>>>  	struct work_struct work;
>>>  };
>>>  
>>> @@ -36,6 +39,9 @@ extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
>>>  extern int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>>>  				     struct eventfd_ctx *eventfd,
>>>  				     const char *args);
>>> +
>>> +extern int vmpressure_register_kernel_event(struct cgroup *cg,
>>> +					    void (*fn)(void));
>>>  extern void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
>>>  					struct eventfd_ctx *eventfd);
>>>  #else
>>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>>> index 736a601..8d77ad0 100644
>>> --- a/mm/vmpressure.c
>>> +++ b/mm/vmpressure.c
>>> @@ -135,8 +135,12 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>>  }
>>>  
>>>  struct vmpressure_event {
>>> -	struct eventfd_ctx *efd;
>>> +	union {
>>> +		struct eventfd_ctx *efd;
>>> +		void (*fn)(void);
>>> +	};
>>>  	enum vmpressure_levels level;
>>> +	bool kernel_event;
>>>  	struct list_head node;
>>>  };
>>>  
>>> @@ -152,7 +156,9 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>>>  	mutex_lock(&vmpr->events_lock);
>>>  
>>>  	list_for_each_entry(ev, &vmpr->events, node) {
>>> -		if (level >= ev->level) {
>>> +		if (ev->kernel_event)
>>> +			ev->fn();
>>> +		else if (vmpr->notify_userspace && (level >= ev->level)) {
>>>  			eventfd_signal(ev->efd, 1);
>>>  			signalled = true;
>>>  		}
>>> @@ -227,7 +233,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>>  	 * we account it too.
>>>  	 */
>>>  	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
>>> -		return;
>>> +		goto schedule;
>>>  
>>>  	/*
>>>  	 * If we got here with no pages scanned, then that is an indicator
>>> @@ -238,14 +244,16 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>>  	 * through vmpressure_prio(). But so far, keep calm.
>>>  	 */
>>>  	if (!scanned)
>>> -		return;
>>> +		goto schedule;
>> 
>> If goto schedule is taken here then scanned==0.  Then
>> scanned<vmpressure_win (below), so this function would always simply
>> return.  So this change seems like a no-op.  Should the schedule: below
>> be just before schedule_work(&vmpr->work)?  But this wouldn't do much
>> either because vmpressure_work_fn() would immediately return if
>> vmpr->scanned==0.  Presumable the idea is to avoid notifying user space
>> or kernel callbacks if lru pages are not scanned - at least until
>> vmpressure_prio() is called with a priority more desperate than
>> vmpressure_level_critical_prio at which time this function's scanned!=0.
>> 
>
> Yes, the idea is to avoid calling the callbacks. I can just return at
> this point if you prefer. I figured that jumping to the common entry
> point would be more consistent, only that. I don't care either way.

Leave it as is.  I don't really care either way.

>>>  	mutex_lock(&vmpr->sr_lock);
>>>  	vmpr->scanned += scanned;
>>>  	vmpr->reclaimed += reclaimed;
>>> +	vmpr->notify_userspace = true;
>>>  	scanned = vmpr->scanned;
>>>  	mutex_unlock(&vmpr->sr_lock);
>>>  
>>> +schedule:
>>>  	if (scanned < vmpressure_win || work_pending(&vmpr->work))
>>>  		return;
>>>  	schedule_work(&vmpr->work);
>>> @@ -328,6 +336,38 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>>>  }
>>>  
>>>  /**
>>> + * vmpressure_register_kernel_event() - Register kernel-side notification
>>> + * @cg:		cgroup that is interested in vmpressure notifications
>>> + * @fn:		function to be called when pressure happens
>>> + *
>>> + * This function register in-kernel users interested in receiving notifications
>>> + * about pressure conditions. Pressure notifications will be triggered at the
>>> + * same time as userspace notifications (with no particular ordering relative
>>> + * to it).
>>> + *
>>> + * Pressure notifications are a alternative method to shrinkers and will serve
>>> + * well users that are interested in a one-shot notification, with a
>>> + * well-defined cgroup aware interface.
>>> + */
>>> +int vmpressure_register_kernel_event(struct cgroup *cg, void (*fn)(void))
>> 
>> It seems useful to include the "struct cgroup *" as a parameter to fn.
>> This would allow for fn to shrink objects it's caching in the cgroup.
>> 
>> Also, why not allow level specification for kernel events?
>> 
> Because I don't want to overdesign. This is a in-kernel API, so we can
> change it if we want to. There is only one user, and that is called from
> the root cgroup, without level distinction.
>
> The cgroup argument makes sense, but I would rather leave it as is for
> now. As for levels, it might make sense as well, but I would much rather
> leave the implementation to someone actually using them - specially
> since this is not a simple parameter passing.

If there's going to be a single global listener for now, then I agree.
Leave your change as-is.

>> It might be neat if vmpressure_register_event() used
>> vmpressure_register_kernel_event() with a callback function calls
>> eventfd_signal().  This would allow for a uniform event notification
>> type which is agnostic of user vs kernel.  However, as proposed there
>> are different signaling conditions.  So I'm not sure it's worth the time
>> to combine the even types.  So feel free to ignore this paragraph.
>> 
>
> I don't think it is worth it.

Fine with me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
