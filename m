Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B0FED6B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:50:26 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o820oNPU031983
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:50:23 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq1.eem.corp.google.com with ESMTP id o820oBSe026414
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:50:12 -0700
Received: by pzk36 with SMTP id 36so4610926pzk.26
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 17:50:11 -0700 (PDT)
Date: Wed, 1 Sep 2010 17:50:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 2/2] oom: use old_mm for oom_disable_count in exec
In-Reply-To: <20100902092039.D05C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011748190.22920@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011659020.14215@chino.kir.corp.google.com> <alpine.DEB.2.00.1009011659490.14215@chino.kir.corp.google.com> <20100902092039.D05C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Sep 2010, KOSAKI Motohiro wrote:

> > active_mm in the exec() path can be for an unrelated thread, so the 
> > oom_disable_count logic should use old_mm instead.
> > 
> > Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  fs/exec.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/exec.c b/fs/exec.c
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -752,8 +752,8 @@ static int exec_mmap(struct mm_struct *mm)
> >  	tsk->mm = mm;
> >  	tsk->active_mm = mm;
> >  	activate_mm(active_mm, mm);
> > -	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > -		atomic_dec(&active_mm->oom_disable_count);
> > +	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +		atomic_dec(&old_mm->oom_disable_count);
> >  		atomic_inc(&tsk->mm->oom_disable_count);
> 
> Looks good. However you need to use tsk->signal->oom_adj == OOM_DISABLE because
> I removed OOM_SCORE_ADJ_MIN.
> 

KOSAKI, I'm not going to argue this with you.  VM patches, like where you 
revert oom_score_adj, go through Andrew.  That's not up for debate.

Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
