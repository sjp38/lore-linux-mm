Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 37C086B0085
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 03:13:12 -0400 (EDT)
Received: by wguu7 with SMTP id u7so9685068wgu.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 00:13:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq16si18235796wjc.124.2015.06.19.00.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 00:13:11 -0700 (PDT)
Date: Fri, 19 Jun 2015 09:13:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] oom: split out forced OOM killer
Message-ID: <20150619071309.GB4913@dhcp22.suse.cz>
References: <1434621447-21175-1-git-send-email-mhocko@suse.cz>
 <1434621447-21175-3-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506181222010.3668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506181222010.3668@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 18-06-15 12:27:12, David Rientjes wrote:
> On Thu, 18 Jun 2015, Michal Hocko wrote:
> 
> > The forced OOM killing is currently wired into out_of_memory() call
> > even though their objective is different which makes the code ugly
> > and harder to follow. Generic out_of_memory path has to deal with
> > configuration settings and heuristics which are completely irrelevant
> > to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
> > OOM killer prevention for already dying tasks). All of them are
> > either relying on explicit force_kill check or indirectly by checking
> > current->mm which is always NULL for sysrq+f. This is not nice, hard
> > to follow and error prone.
> > 
> > Let's pull forced OOM killer code out into a separate function
> > (force_out_of_memory) which is really trivial now.
> > As a bonus we can clearly state that this is a forced OOM killer
> > in the OOM message which is helpful to distinguish it from the
> > regular OOM killer.
> > 
> 
> Ok, so this patch reverts _everything_ in the first patch other than the 
> documentation.  Just start with this patch instead, sheesh.

The ordering is intentional. Clean up on top of the fix. And considering
how much you "loved" the previous attempt of the cleanup I had even
stronger reason to put this on top of the fix.

> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  drivers/tty/sysrq.c |  3 +--
> >  include/linux/oom.h |  3 ++-
> >  mm/oom_kill.c       | 57 ++++++++++++++++++++++++++++++++---------------------
> >  mm/page_alloc.c     |  2 +-
> >  4 files changed, 39 insertions(+), 26 deletions(-)
> > 
> > diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> > index 3a42b7187b8e..06a95a8ed701 100644
> > --- a/drivers/tty/sysrq.c
> > +++ b/drivers/tty/sysrq.c
> > @@ -356,8 +356,7 @@ static struct sysrq_key_op sysrq_term_op = {
> >  static void moom_callback(struct work_struct *ignored)
> >  {
> >  	mutex_lock(&oom_lock);
> > -	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
> > -			   GFP_KERNEL, 0, NULL, true))
> > +	if (!force_out_of_memory())
> >  		pr_info("OOM request ignored because killer is disabled\n");
> >  	mutex_unlock(&oom_lock);
> >  }
> > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > index 7deecb7bca5e..061e0ffd3493 100644
> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -70,8 +70,9 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> >  		unsigned long totalpages, const nodemask_t *nodemask,
> >  		bool force_kill);
> >  
> > +extern bool force_out_of_memory(void);
> >  extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > -		int order, nodemask_t *mask, bool force_kill);
> > +		int order, nodemask_t *mask);
> >  
> >  extern void exit_oom_victim(void);
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0c312eaac834..050936f35944 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -635,12 +635,38 @@ int unregister_oom_notifier(struct notifier_block *nb)
> >  EXPORT_SYMBOL_GPL(unregister_oom_notifier);
> >  
> >  /**
> > - * __out_of_memory - kill the "best" process when we run out of memory
> > + * force_out_of_memory - forces OOM killer
> 
> ... to kill a process.

OK
 
> > + *
> > + * External trigger for the OOM killer. The system doesn't have to be under
> > + * OOM condition (e.g. sysrq+f).
> > + */
> 
> I'm still not sure what you mean by external.  I assume you're referring 
> to induced by userspace rather than the kernel.  I think you should use 
> the word "explicit".

OK
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5af8b5e44b27..7783a3760c56 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -635,9 +635,9 @@ int unregister_oom_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
 /**
- * force_out_of_memory - forces OOM killer
+ * force_out_of_memory - forces OOM killer to kill a process
  *
- * External trigger for the OOM killer. The system doesn't have to be under
+ * Explicitly trigger the OOM killer. The system doesn't have to be under
  * OOM condition (e.g. sysrq+f).
  */
 bool force_out_of_memory(void)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
