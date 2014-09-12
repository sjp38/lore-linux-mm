Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F10796B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 03:39:54 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so296009wgg.6
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 00:39:54 -0700 (PDT)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id qn9si2939391wjc.37.2014.09.12.00.39.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 00:39:53 -0700 (PDT)
Received: by mail-we0-f172.google.com with SMTP id k48so305793wev.17
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 00:39:53 -0700 (PDT)
Date: Fri, 12 Sep 2014 03:39:36 -0400
From: Niv Yehezkel <executerx@gmail.com>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140912073936.GA10692@localhost.localdomain>
References: <20140911213338.GA4098@localhost.localdomain>
 <54124AC9.2040308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54124AC9.2040308@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, hannes@cmpxchg.org, oleg@redhat.com, wangnan0@huawei.com

On Fri, Sep 12, 2014 at 09:22:17AM +0800, Zhang Zhen wrote:
> On 2014/9/12 5:33, Niv Yehezkel wrote:
> > There is no need to fallback and continue computing
> > badness for each running process after we have found a
> > process currently performing the swapoff syscall. We ought to
> > immediately select this process for killing.
> > 
> > Signed-off-by: Niv Yehezkel <executerx@gmail.com>
> > ---
> >  mm/oom_kill.c |    6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 1e11df8..68ac30e 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -305,6 +305,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  	struct task_struct *g, *p;
> >  	struct task_struct *chosen = NULL;
> >  	unsigned long chosen_points = 0;
> > +	bool process_selected = false;
> >  
> >  	rcu_read_lock();
> >  	for_each_process_thread(g, p) {
> > @@ -315,7 +316,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  		case OOM_SCAN_SELECT:
> >  			chosen = p;
> >  			chosen_points = ULONG_MAX;
> > -			/* fall through */
> > +			process_selected = true;
> > +			break;
> >  		case OOM_SCAN_CONTINUE:
> >  			continue;
> >  		case OOM_SCAN_ABORT:
> > @@ -324,6 +326,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  		case OOM_SCAN_OK:
> >  			break;
> >  		};
> > +		if (process_selected)
> > +			break;
> 
> Hi,
> The following comment shows that we prefer thread group leaders for display purposes.
> If we break here and two threads in a thread group are performing the swapoff syscall, maybe we can not get thread
> group leaders.
> 
> Thanks!
> 
> >  		points = oom_badness(p, NULL, nodemask, totalpages);
> >  		if (!points || points < chosen_points)
> >  			continue;
> > 
> 
> 

Well, this is not the logic implemented in the loop.
Once a process is selected, it fallbacks and continues the loop.
If two threads are performing the swapoff, the latter will be chosen whatsoever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
