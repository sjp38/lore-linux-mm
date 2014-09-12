Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id AF16F6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 04:23:49 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ex7so146022wid.7
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:23:49 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id dt6si1542103wib.78.2014.09.12.01.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 01:23:48 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id k48so357056wev.27
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:23:48 -0700 (PDT)
Date: Fri, 12 Sep 2014 04:23:29 -0400
From: Niv Yehezkel <executerx@gmail.com>
Subject: Re: [PATCH] oom: break after selecting process to kill
Message-ID: <20140912082329.GA12330@localhost.localdomain>
References: <20140911213338.GA4098@localhost.localdomain>
 <20140912080853.GA12156@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Content-Disposition: inline
In-Reply-To: <20140912080853.GA12156@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, oleg@redhat.com


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 12, 2014 at 10:08:53AM +0200, Michal Hocko wrote:
> On Thu 11-09-14 17:33:39, Niv Yehezkel wrote:
> > There is no need to fallback and continue computing
> > badness for each running process after we have found a
> > process currently performing the swapoff syscall. We ought to
> > immediately select this process for killing.
> 
> a) this is not only about swapoff. KSM (run_store) is currently
>    considered oom origin as well.
> b) you forgot to tell us what led you to this change. It sounds like a
>    minor optimization to me. We can potentially skip scanning through
>    many tasks but this is not guaranteed at all because our task might
>    be at the very end of the tasks list as well.
> c) finally this might select thread != thread_group_leader which is a
>    minor issue affecting oom report
> 
> I am not saying the change is wrong but please make sure you first
> describe your motivation. Does it fix any issue you are seeing?  Is this
> just something that struck you while reading the code? Maybe it was 
> /* always select this thread first */ comment for OOM_SCAN_SELECT.
> Besides that your process_selected is not really needed. You could test
> for chosen_points == ULONG_MAX as well. This would be even more
> straightforward because any score like that is ultimate candidate.
> 
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
> >  		points = oom_badness(p, NULL, nodemask, totalpages);
> >  		if (!points || points < chosen_points)
> >  			continue;
> > -- 
> > 1.7.10.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

Been reviewing kernel code lately and looking for implementations not fulfilling their actual intention. That's about most of the patches I tend to send.
Motivation is pretty much derived from the Eudyptula challenge so there is not concrete reason for this patch.

To the point: I have not witnessed any major affects to performance due to this.
I fixed the patch and attached it to this mail.

--mYCpIKhGyMATD0i+
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-break-after-selecting-process-to-kill.patch"


--mYCpIKhGyMATD0i+--
