Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4A02E6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 17:18:03 -0400 (EDT)
Received: by mail-da0-f43.google.com with SMTP id u36so538056dak.30
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 14:18:02 -0700 (PDT)
Date: Tue, 23 Apr 2013 16:24:46 -0400
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
Message-ID: <20130423202446.GA2484@teo>
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
 <1366705329-9426-2-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1366705329-9426-2-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Apr 23, 2013 at 12:22:08PM +0400, Glauber Costa wrote:
> From: Glauber Costa <glommer@parallels.com>
> 
> This patch extends that to also support in-kernel users. Events that
> should be generated for in-kernel consumption will be marked as such,
> and for those, we will call a registered function instead of triggering
> an eventfd notification.

Just a couple more questions... :-)

[...]
> @@ -238,14 +244,16 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>  	 * through vmpressure_prio(). But so far, keep calm.
>  	 */
>  	if (!scanned)
> -		return;
> +		goto schedule;
>  
>  	mutex_lock(&vmpr->sr_lock);
>  	vmpr->scanned += scanned;
>  	vmpr->reclaimed += reclaimed;
> +	vmpr->notify_userspace = true;

Setting the variable on every event seems a bit wasteful... does it make
sense to set it in vmpressure_register_event()? We'll have to make it a
counter, but the good thing is that we won't need any additional locks for
the counter.

>  /**
> + * vmpressure_register_kernel_event() - Register kernel-side notification

Why don't we need the unregister function? I see that the memcg portion
deals with dangling memcgs, but do they dangle forver?

Oh, and a few cosmetic changes down below...

Other than that, this particular patch looks perfect, feel free to add my:

	Acked-by: Anton Vorontsov <anton@enomsg.org>

Thanks!

Anton


diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 1862012..3131e72 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -19,7 +19,7 @@ struct vmpressure {
 	/* Have to grab the lock on events traversal or modifications. */
 	struct mutex events_lock;
 
-	/* false if only kernel users want to be notified, true otherwise */
+	/* False if only kernel users want to be notified, true otherwise. */
 	bool notify_userspace;
 
 	struct work_struct work;
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 8d77ad0..acd3e66 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -156,9 +156,9 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 	mutex_lock(&vmpr->events_lock);
 
 	list_for_each_entry(ev, &vmpr->events, node) {
-		if (ev->kernel_event)
+		if (ev->kernel_event) {
 			ev->fn();
-		else if (vmpr->notify_userspace && (level >= ev->level)) {
+		} else if (vmpr->notify_userspace && level >= ev->level) {
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
