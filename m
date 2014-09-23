Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 59D6D6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:30:24 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id n12so3256277wgh.35
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:30:23 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id mc4si16198416wjb.75.2014.09.23.11.30.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 11:30:22 -0700 (PDT)
Received: by mail-wg0-f46.google.com with SMTP id a1so4806335wgh.29
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:30:22 -0700 (PDT)
Date: Tue, 23 Sep 2014 20:30:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140923183020.GD29528@dhcp22.suse.cz>
References: <20140911213338.GA4098@localhost.localdomain>
 <20140912080853.GA12156@dhcp22.suse.cz>
 <20140912082329.GA12330@localhost.localdomain>
 <20140912121817.GE12156@dhcp22.suse.cz>
 <20140912122143.GA20622@localhost.localdomain>
 <alpine.DEB.2.02.1409141345300.19382@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1409141345300.19382@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Niv Yehezkel <executerx@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, oleg@redhat.com

On Sun 14-09-14 13:46:15, David Rientjes wrote:
> On Fri, 12 Sep 2014, Niv Yehezkel wrote:
> 
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index 1e11df8..3203578 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -315,7 +315,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > > >  		case OOM_SCAN_SELECT:
> > > >  			chosen = p;
> > > >  			chosen_points = ULONG_MAX;
> > > > -			/* fall through */
> > > > +			break;
> > > >  		case OOM_SCAN_CONTINUE:
> > > >  			continue;
> > > >  		case OOM_SCAN_ABORT:
> > > > @@ -324,6 +324,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > > >  		case OOM_SCAN_OK:
> > > >  			break;
> > > >  		};
> > > > +		if (chosen_points == ULONG_MAX)
> > > > +			break;
> > > >  		points = oom_badness(p, NULL, nodemask, totalpages);
> > > >  		if (!points || points < chosen_points)
> > > >  			continue;
> > > > -- 
> > > > 1.7.10.4
> > > > 
> > > 
> > > 
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > As mentioned earlier, there's no need to keep iterating over all
> > running processes once the process with the highest score has been found.
> > 
> 
> This would lead to unnecessary oom killing since we may miss a process 
> that returns OOM_SCAN_ABORT simply because it is later in the tasklist (we 
> want to defer oom killing if there is an exiting process or an oom kill 
> victim hasn't exited yet).  NACK.

Good point David. I have completely missed this part!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
