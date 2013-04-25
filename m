Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C2E2E6B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 06:49:44 -0400 (EDT)
Message-ID: <51790A73.3030805@parallels.com>
Date: Thu, 25 Apr 2013 14:50:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-2-git-send-email-glommer@openvz.org> <xr937gjrhg1f.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr937gjrhg1f.fsf@gthelen.mtv.corp.google.com>
Content-Type: multipart/mixed;
	boundary="------------000807030105080807080004"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

--------------000807030105080807080004
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 04/24/2013 11:42 PM, Greg Thelen wrote:
>> +	vmpr->notify_userspace = true;
> Should notify_userspace get cleared sometime?  Seems like we might need
> to clear or decrement notify_userspace in vmpressure_event() when
> calling eventfd_signal().
> 
I am folding the attached patch and keeping the acks unless the ackers
oppose.

Greg, any other problem you spot here? Thanks for the review BTW.


--------------000807030105080807080004
Content-Type: text/x-patch; name="vmpressure.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="vmpressure.diff"

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 1a082a0..e16256e 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -164,6 +164,7 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 		}
 	}
 
+	vmpr->notify_userspace = false;
 	mutex_unlock(&vmpr->events_lock);
 
 	return signalled;
@@ -249,8 +250,13 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	mutex_lock(&vmpr->sr_lock);
 	vmpr->scanned += scanned;
 	vmpr->reclaimed += reclaimed;
-	vmpr->notify_userspace = true;
 	scanned = vmpr->scanned;
+	/*
+	 * If we didn't reach this point, only kernel events will be triggered.
+	 * It is the job of the worker thread to clean this up once the
+	 * notifications are all delivered.
+	 */
+	vmpr->notify_userspace = true;
 	mutex_unlock(&vmpr->sr_lock);
 
 schedule:

--------------000807030105080807080004--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
