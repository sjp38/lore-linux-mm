Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BDEC36B01F2
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:29:46 -0400 (EDT)
Date: Tue, 30 Mar 2010 22:29:23 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100330142923.GA10099@desktop>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
 <20100326150805.f5853d1c.akpm@linux-foundation.org>
 <20100326223356.GA20833@redhat.com>
 <20100328145528.GA14622@desktop>
 <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
 <20100329140633.GA26464@desktop>
 <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 01:01:58PM -0700, David Rientjes wrote:
> On Mon, 29 Mar 2010, anfei wrote:
> 
> > I think this method is okay, but it's easy to trigger another bug of
> > oom.  See select_bad_process():
> > 	if (!p->mm)
> > 		continue;
> > !p->mm is not always an unaccepted condition.  e.g. "p" is killed and
> > doing exit, setting tsk->mm to NULL is before releasing the memory.
> > And in multi threading environment, this happens much more.
> > In __out_of_memory(), it panics if select_bad_process returns NULL.
> > The simple way to fix it is as mem_cgroup_out_of_memory() does.
> > 
> 
> This is fixed by 
> oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch in 
> the -mm tree.
> 
> See 
> http://userweb.kernel.org/~akpm/mmotm/broken-out/oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index afeab2a..9aae208 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -588,12 +588,8 @@ retry:
> >  	if (PTR_ERR(p) == -1UL)
> >  		return;
> >  
> > -	/* Found nothing?!?! Either we hang forever, or we panic. */
> > -	if (!p) {
> > -		read_unlock(&tasklist_lock);
> > -		dump_header(NULL, gfp_mask, order, NULL);
> > -		panic("Out of memory and no killable processes...\n");
> > -	}
> > +	if (!p)
> > +		p = current;
> >  
> >  	if (oom_kill_process(p, gfp_mask, order, points, NULL,
> >  			     "Out of memory"))
> 
> The reason p wasn't selected is because it fails to meet the criteria for 
> candidacy in select_bad_process(), not necessarily because of a race with 
> the !p->mm check that the -mm patch cited above fixes.  It's quite 
> possible that current has an oom_adj value of OOM_DISABLE, for example, 
> where this would be wrong.

I see.  And what about changing mem_cgroup_out_of_memory() too?


diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0cb1ca4..9e89a29 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -510,8 +510,10 @@ retry:
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
-	if (!p)
-		p = current;
+	if (!p) {
+		read_unlock(&tasklist_lock);
+		panic("Out of memory and no killable processes...\n");
+	}
 
 	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
 				"Memory cgroup out of memory"))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
