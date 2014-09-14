Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 934BA6B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 16:46:19 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id h18so3011249igc.9
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 13:46:19 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id jd1si10682365icc.20.2014.09.14.13.46.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 13:46:18 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so3639550iec.10
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 13:46:18 -0700 (PDT)
Date: Sun, 14 Sep 2014 13:46:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: break after selecting process to kill
In-Reply-To: <20140912122143.GA20622@localhost.localdomain>
Message-ID: <alpine.DEB.2.02.1409141345300.19382@chino.kir.corp.google.com>
References: <20140911213338.GA4098@localhost.localdomain> <20140912080853.GA12156@dhcp22.suse.cz> <20140912082329.GA12330@localhost.localdomain> <20140912121817.GE12156@dhcp22.suse.cz> <20140912122143.GA20622@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niv Yehezkel <executerx@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, oleg@redhat.com

On Fri, 12 Sep 2014, Niv Yehezkel wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 1e11df8..3203578 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -315,7 +315,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  		case OOM_SCAN_SELECT:
> > >  			chosen = p;
> > >  			chosen_points = ULONG_MAX;
> > > -			/* fall through */
> > > +			break;
> > >  		case OOM_SCAN_CONTINUE:
> > >  			continue;
> > >  		case OOM_SCAN_ABORT:
> > > @@ -324,6 +324,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  		case OOM_SCAN_OK:
> > >  			break;
> > >  		};
> > > +		if (chosen_points == ULONG_MAX)
> > > +			break;
> > >  		points = oom_badness(p, NULL, nodemask, totalpages);
> > >  		if (!points || points < chosen_points)
> > >  			continue;
> > > -- 
> > > 1.7.10.4
> > > 
> > 
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> As mentioned earlier, there's no need to keep iterating over all
> running processes once the process with the highest score has been found.
> 

This would lead to unnecessary oom killing since we may miss a process 
that returns OOM_SCAN_ABORT simply because it is later in the tasklist (we 
want to defer oom killing if there is an exiting process or an oom kill 
victim hasn't exited yet).  NACK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
