Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 15D1E6B0099
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:04:42 -0400 (EDT)
Received: by mail-ia0-f177.google.com with SMTP id w33so900306iag.22
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 21:04:41 -0700 (PDT)
Date: Tue, 2 Apr 2013 21:00:40 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v3] memcg: Add memory.pressure_level events
Message-ID: <20130403040039.GA8687@lizard.gateway.2wire.net>
References: <20130322071351.GA3971@lizard.gateway.2wire.net>
 <5152511A.1010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5152511A.1010707@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, Mar 27, 2013 at 10:53:30AM +0900, Kamezawa Hiroyuki wrote:
[...]
> >+++ b/mm/memcontrol.c
> >@@ -49,6 +49,7 @@
> >  #include <linux/fs.h>
> >  #include <linux/seq_file.h>
> >  #include <linux/vmalloc.h>
> >+#include <linux/vmpressure.h>
> >  #include <linux/mm_inline.h>
> >  #include <linux/page_cgroup.h>
> >  #include <linux/cpu.h>
> >@@ -376,6 +377,9 @@ struct mem_cgroup {
> >  	atomic_t	numainfo_events;
> >  	atomic_t	numainfo_updating;
> >  #endif
> >+
> >+	struct vmpressure vmpr;
> >+
> 
> How about placing this just below "memsw_threshold" ?
> memory objects around there is not performance critical.

Yup, done.

[...]
> >+static const unsigned int vmpressure_win = SWAP_CLUSTER_MAX * 16;
> >+static const unsigned int vmpressure_level_med = 60;
> >+static const unsigned int vmpressure_level_critical = 95;
> >+static const unsigned int vmpressure_level_critical_prio = 3;
> >+
> more comments are welcomed...
> 
> I'm not against the numbers themselves but I'm not sure how these numbers are
> selected...I'm glad if you show some reasons in changelog or somewhere.

Sure, in v4 the numbers are described in the comments.

[...]
> >+static enum vmpressure_levels vmpressure_calc_level(unsigned int scanned,
> >+						    unsigned int reclaimed)
> >+{
> >+	unsigned long scale = scanned + reclaimed;
> >+	unsigned long pressure;
> >+
> >+	if (!scanned)
> >+		return VMPRESSURE_LOW;
> 
> Can you add comment here ? When !scanned happens ?

Yeah, the comment is needed. in v4 I added explanation for this case.

[...]
> >+	mutex_lock(&vmpr->sr_lock);
> >+	vmpr->scanned += scanned;
> >+	vmpr->reclaimed += reclaimed;
> >+	mutex_unlock(&vmpr->sr_lock);
> >+
> >+	if (scanned < vmpressure_win || work_pending(&vmpr->work))
> >+		return;
> >+	schedule_work(&vmpr->work);
> >+}
> 
> I'm not sure how other guys thinks but....could you place the definition
> of work_fn above calling it ? you call vmpressure_wk_fn(), right ?

Yup. OK, I rearranged the code a bit.

[...]
> >  	do {
> >+		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> >+				sc->priority);
> >  		sc->nr_scanned = 0;
> >  		aborted_reclaim = shrink_zones(zonelist, sc);
> >
> >
> 
> When you answers Andrew's comment and fix problems, feel free to add
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks a lot for the reviews, Kamezawa!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
