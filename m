Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id CB5CF6B007B
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 09:27:11 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so2647035qae.20
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 06:27:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v3si6002018qat.21.2013.12.20.06.27.09
        for <linux-mm@kvack.org>;
        Fri, 20 Dec 2013 06:27:10 -0800 (PST)
Date: Fri, 20 Dec 2013 09:26:59 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v14 16/18] vmpressure: in-kernel notifications
Message-ID: <20131220092659.0ed23cf5@redhat.com>
In-Reply-To: <abff42910c131a9c94a7518de59b283ee0a2dcd1.1387193771.git.vdavydov@parallels.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
	<abff42910c131a9c94a7518de59b283ee0a2dcd1.1387193771.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 16 Dec 2013 16:17:05 +0400
Vladimir Davydov <vdavydov@parallels.com> wrote:

> From: Glauber Costa <glommer@openvz.org>
> 
> During the past weeks, it became clear to us that the shrinker interface
> we have right now works very well for some particular types of users,
> but not that well for others. The latter are usually people interested
> in one-shot notifications, that were forced to adapt themselves to the
> count+scan behavior of shrinkers. To do so, they had no choice than to
> greatly abuse the shrinker interface producing little monsters all over.
> 
> During LSF/MM, one of the proposals that popped out during our session
> was to reuse Anton Voronstsov's vmpressure for this. They are designed
> for userspace consumption, but also provide a well-stablished,
> cgroup-aware entry point for notifications.

I have the exact problem described above for a project I'm working on
and this solution seems to solve it well.

However, I had a few issues while trying to use this interface. I'll
comment on them below, but please take this more as advice seeking
than patch review.

> This patch extends that to also support in-kernel users. Events that
> should be generated for in-kernel consumption will be marked as such,
> and for those, we will call a registered function instead of triggering
> an eventfd notification.
> 
> Please note that due to my lack of understanding of each shrinker user,
> I will stay away from converting the actual users, you are all welcome
> to do so.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Acked-by: Anton Vorontsov <anton@enomsg.org>
> Acked-by: Pekka Enberg <penberg@kernel.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/vmpressure.h |    5 +++++
>  mm/vmpressure.c            |   53 +++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 55 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> index 3f3788d..9102e53 100644
> --- a/include/linux/vmpressure.h
> +++ b/include/linux/vmpressure.h
> @@ -19,6 +19,9 @@ struct vmpressure {
>  	/* Have to grab the lock on events traversal or modifications. */
>  	struct mutex events_lock;
>  
> +	/* False if only kernel users want to be notified, true otherwise. */
> +	bool notify_userspace;
> +
>  	struct work_struct work;
>  };
>  
> @@ -38,6 +41,8 @@ extern int vmpressure_register_event(struct cgroup_subsys_state *css,
>  				     struct cftype *cft,
>  				     struct eventfd_ctx *eventfd,
>  				     const char *args);
> +extern int vmpressure_register_kernel_event(struct cgroup_subsys_state *css,
> +					    void (*fn)(void));
>  extern void vmpressure_unregister_event(struct cgroup_subsys_state *css,
>  					struct cftype *cft,
>  					struct eventfd_ctx *eventfd);
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index e0f6283..730e7c1 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -130,8 +130,12 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  }
>  
>  struct vmpressure_event {
> -	struct eventfd_ctx *efd;
> +	union {
> +		struct eventfd_ctx *efd;
> +		void (*fn)(void);

How does the callback access its private data?

> +	};
>  	enum vmpressure_levels level;
> +	bool kernel_event;
>  	struct list_head node;
>  };
>  
> @@ -147,12 +151,15 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>  	mutex_lock(&vmpr->events_lock);
>  
>  	list_for_each_entry(ev, &vmpr->events, node) {
> -		if (level >= ev->level) {
> +		if (ev->kernel_event) {
> +			ev->fn();

I think it would be interesting to pass 'level' to the callback (I'll
probably use it myself), but we could wait for a in-tree user before
adding it.

> +		} else if (vmpr->notify_userspace && level >= ev->level) {
>  			eventfd_signal(ev->efd, 1);
>  			signalled = true;
>  		}
>  	}
>  
> +	vmpr->notify_userspace = false;
>  	mutex_unlock(&vmpr->events_lock);
>  
>  	return signalled;
> @@ -222,7 +229,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>  	 * we account it too.
>  	 */
>  	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
> -		return;
> +		goto schedule;
>  
>  	/*
>  	 * If we got here with no pages scanned, then that is an indicator
> @@ -239,8 +246,15 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>  	vmpr->scanned += scanned;
>  	vmpr->reclaimed += reclaimed;
>  	scanned = vmpr->scanned;
> +	/*
> +	 * If we didn't reach this point, only kernel events will be triggered.
> +	 * It is the job of the worker thread to clean this up once the
> +	 * notifications are all delivered.
> +	 */
> +	vmpr->notify_userspace = true;
>  	spin_unlock(&vmpr->sr_lock);
>  
> +schedule:
>  	if (scanned < vmpressure_win)
>  		return;
>  	schedule_work(&vmpr->work);
> @@ -324,6 +338,39 @@ int vmpressure_register_event(struct cgroup_subsys_state *css,
>  }
>  
>  /**
> + * vmpressure_register_kernel_event() - Register kernel-side notification
> + * @css:	css that is interested in vmpressure notifications
> + * @fn:		function to be called when pressure happens
> + *
> + * This function register in-kernel users interested in receiving notifications
> + * about pressure conditions. Pressure notifications will be triggered at the
> + * same time as userspace notifications (with no particular ordering relative
> + * to it).
> + *
> + * Pressure notifications are a alternative method to shrinkers and will serve
> + * well users that are interested in a one-shot notification, with a
> + * well-defined cgroup aware interface.
> + */
> +int vmpressure_register_kernel_event(struct cgroup_subsys_state *css,
> +				      void (*fn)(void))
> +{
> +	struct vmpressure *vmpr = css_to_vmpressure(css);

This doesn't allow for css=NULL. What's the recommended way for a today's
shrinker (which is not related to cgroups) to register with this API?

Also, you don't seem to provide a way to de-register from the event.

I hacked a patch to be able to use this, seems to work but it's a ugly
hack:

---
 include/linux/vmpressure.h |  3 ++-
 mm/vmpressure.c            | 13 +++++++++----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 9102e53..de416b6 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -42,7 +42,8 @@ extern int vmpressure_register_event(struct cgroup_subsys_state *css,
 				     struct eventfd_ctx *eventfd,
 				     const char *args);
 extern int vmpressure_register_kernel_event(struct cgroup_subsys_state *css,
-					    void (*fn)(void));
+				     	    void (*fn)(void *data, int level),
+					    void *data);
 extern void vmpressure_unregister_event(struct cgroup_subsys_state *css,
 					struct cftype *cft,
 					struct eventfd_ctx *eventfd);
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 730e7c1..4ed0e85 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -132,9 +132,10 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	union {
 		struct eventfd_ctx *efd;
-		void (*fn)(void);
+		void (*fn)(void *data, int level);
 	};
 	enum vmpressure_levels level;
+	void *data;
 	bool kernel_event;
 	struct list_head node;
 };
@@ -152,7 +153,7 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (ev->kernel_event) {
-			ev->fn();
+			ev->fn(ev->data, level);
 		} else if (vmpr->notify_userspace && level >= ev->level) {
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
@@ -352,21 +353,25 @@ int vmpressure_register_event(struct cgroup_subsys_state *css,
  * well-defined cgroup aware interface.
  */
 int vmpressure_register_kernel_event(struct cgroup_subsys_state *css,
-				      void (*fn)(void))
+				     void (*fn)(void *data, int level), void *data)
 {
-	struct vmpressure *vmpr = css_to_vmpressure(css);
+	struct vmpressure *vmpr;
 	struct vmpressure_event *ev;
 
+	vmpr = css ? css_to_vmpressure(css) : memcg_to_vmpressure(NULL);
+
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
 	if (!ev)
 		return -ENOMEM;
 
 	ev->kernel_event = true;
+	ev->data = data;
 	ev->fn = fn;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
 	mutex_unlock(&vmpr->events_lock);
+
 	return 0;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
