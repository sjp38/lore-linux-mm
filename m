Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0A86B0085
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 03:09:47 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so81855219wgb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 00:09:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si3079077wiz.1.2015.06.19.00.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 00:09:45 -0700 (PDT)
Date: Fri, 19 Jun 2015 09:09:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] oom: Do not panic when OOM killer is sysrq triggered
Message-ID: <20150619070943.GA4913@dhcp22.suse.cz>
References: <1434621447-21175-1-git-send-email-mhocko@suse.cz>
 <1434621447-21175-2-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506181213400.3668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506181213400.3668@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 18-06-15 12:21:22, David Rientjes wrote:
> On Thu, 18 Jun 2015, Michal Hocko wrote:
> 
> > OOM killer might be triggered externally via sysrq+f. This is supposed
> 
> I'm not sure what you mean by externally?  Perhaps "explicitly"?

OK, explicitly is better.

[...]

> s/panicing/panicking/

Fixed
 
> > While we are there also add a comment explaining why
> > sysctl_oom_kill_allocating_task doesn't apply to sysrq triggered OOM
> > killer even though there is no explicit check and we subtly rely
> > on current->mm being NULL for the context from which it is triggered.
> > 
> > Also be more explicit about sysrq+f behavior in the documentation.
> > 
> > Requested-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  Documentation/sysrq.txt |  5 ++++-
> >  mm/oom_kill.c           | 21 +++++++++++++++++----
> >  2 files changed, 21 insertions(+), 5 deletions(-)
> > 
> > diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
> > index 0e307c94809a..a5dd88b0aede 100644
> > --- a/Documentation/sysrq.txt
> > +++ b/Documentation/sysrq.txt
> > @@ -75,7 +75,10 @@ On other - If you know of the key combos for other architectures, please
> >  
> >  'e'     - Send a SIGTERM to all processes, except for init.
> >  
> > -'f'	- Will call oom_kill to kill a memory hog process.
> > +'f'	- Will call oom_kill to kill a memory hog process. Please note that
> > +	  an ongoing OOM killer is ignored and a task is killed even though
> > +	  there was an oom victim selected already. panic_on_oom is ignored
> > +	  and the system doesn't panic if there are no oom killable tasks.
> 
> "an ongoing OOM killer" could probably be reworded to "parallel oom 
> killings".

OK

> >  
> >  'g'	- Used by kgdb (kernel debugger)
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index dff991e0681e..0c312eaac834 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -687,8 +687,14 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
> >  						&totalpages);
> >  	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
> > -	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
> > +	/* Ignore panic_on_oom when the OOM killer is sysrq triggered */
> > +	if (!force_kill)
> > +		check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
> 
> I don't think the comment is necessary, it should be clear from the code 
> that this only executes when force_kill == true.

OK, I will remove the comment.
 
> You may want to reconsider my suggestion of renaming the formal as 
> "sysrq".

I consider the naming clear enough
 
> >  
> > +	/*
> > +	 * not affecting force_kill because sysrq triggered OOM killer runs from
> > +	 * the workqueue context so current->mm will be NULL
> > +	 */
> 
> Unnecessary comment, nobody is reading this code with the short circuit in 
> mind.

I find this comment helpful because it is pointing a non trivial fact
that requires wandering the code otherwise. So I will keep it.
 
> >  	if (sysctl_oom_kill_allocating_task && current->mm &&
> >  	    !oom_unkillable_task(current, NULL, nodemask) &&
> >  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> > @@ -700,10 +706,17 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	}
> >  
> >  	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
> > -	/* Found nothing?!?! Either we hang forever, or we panic. */
> > +	/*
> > +	 * Found nothing?!?! Either we hang forever, or we panic.
> > +	 * Do not panic when the OOM killer is sysrq triggered.
> > +	 */
> 
> Again, it's clear what a conditional does in C code.

OK, I will remove it.

> >  	if (!p) {
> > -		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> > -		panic("Out of memory and no killable processes...\n");
> > +		if (!force_kill) {
> > +			dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> > +			panic("Out of memory and no killable processes...\n");
> > +		} else {
> > +			pr_info("Forced out of memory. No killable task found...\n");
> > +		}
> 
> This line could probably be reworded to specify that an oom kill was 
> requested by a specific process and there was nothing avilable to kill.  
> I'm not sure that "forced" implies that it was process triggered.

s@Forced@Sysrq triggered@ ?

> 
> >  	}
> >  	if (p != (void *)-1UL) {
> >  		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,

---
diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
index a5dd88b0aede..7664e93411d2 100644
--- a/Documentation/sysrq.txt
+++ b/Documentation/sysrq.txt
@@ -76,7 +76,7 @@ On other - If you know of the key combos for other architectures, please
 'e'     - Send a SIGTERM to all processes, except for init.
 
 'f'	- Will call oom_kill to kill a memory hog process. Please note that
-	  an ongoing OOM killer is ignored and a task is killed even though
+	  parallel OOM killer is ignored and a task is killed even though
 	  there was an oom victim selected already. panic_on_oom is ignored
 	  and the system doesn't panic if there are no oom killable tasks.
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0c312eaac834..f2737d66f66a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -687,7 +687,6 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
 						&totalpages);
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
-	/* Ignore panic_on_oom when the OOM killer is sysrq triggered */
 	if (!force_kill)
 		check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
 
@@ -706,16 +705,13 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	}
 
 	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
-	/*
-	 * Found nothing?!?! Either we hang forever, or we panic.
-	 * Do not panic when the OOM killer is sysrq triggered.
-	 */
+	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		if (!force_kill) {
 			dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
 			panic("Out of memory and no killable processes...\n");
 		} else {
-			pr_info("Forced out of memory. No killable task found...\n");
+			pr_info("Sysrq triggered out of memory. No killable task found...\n");
 		}
 	}
 	if (p != (void *)-1UL) {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
