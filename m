Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id A43239003C7
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:30:49 -0400 (EDT)
Received: by iggp10 with SMTP id p10so23137048igg.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:30:49 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id mp20si6559906icb.12.2015.07.09.14.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:30:49 -0700 (PDT)
Received: by igrv9 with SMTP id v9so233243936igr.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:30:49 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:30:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 3/3] mm, oom: do not panic for oom kills triggered
 from sysrq
In-Reply-To: <02e601d0b9fd$d644ec50$82cec4f0$@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1507091428340.17177@chino.kir.corp.google.com>
References: <02e601d0b9fd$d644ec50$82cec4f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 9 Jul 2015, Hillf Danton wrote:

> > diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
> > --- a/Documentation/sysrq.txt
> > +++ b/Documentation/sysrq.txt
> > @@ -75,7 +75,8 @@ On all -  write a character to /proc/sysrq-trigger.  e.g.:
> > 
> >  'e'     - Send a SIGTERM to all processes, except for init.
> > 
> > -'f'	- Will call oom_kill to kill a memory hog process.
> > +'f'	- Will call the oom killer to kill a memory hog process, but do not
> > +	  panic if nothing can be killed.
> > 
> >  'g'	- Used by kgdb (kernel debugger)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -607,6 +607,9 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
> >  		if (constraint != CONSTRAINT_NONE)
> >  			return;
> >  	}
> > +	/* Do not panic for oom kills triggered by sysrq */
> > +	if (oc->order == -1)
> > +		return;
> >  	dump_header(oc, NULL, memcg);
> >  	panic("Out of memory: %s panic_on_oom is enabled\n",
> >  		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
> > @@ -686,11 +689,11 @@ bool out_of_memory(struct oom_control *oc)
> > 
> >  	p = select_bad_process(oc, &points, totalpages);
> >  	/* Found nothing?!?! Either we hang forever, or we panic. */
> > -	if (!p) {
> > +	if (!p && oc->order != -1) {
> >  		dump_header(oc, NULL, NULL);
> >  		panic("Out of memory and no killable processes...\n");
> >  	}
> 
> Given sysctl_panic_on_oom checked, AFAICU there seems
> no chance for panic, no matter -1 or not.
> 

I'm not sure I understand your point.

There are two oom killer panics: when panic_on_oom is enabled and when the 
oom killer can't find an eligible process.

The change to the panic_on_oom panic is dealt with in check_panic_on_oom() 
and the no eligible process panic is dealt with here.

If the sysctl is disabled, and there are no eligible processes to kill, 
the change in behavior here is that we don't panic when triggered from 
sysrq.  That's the change in the hunk above.

> > -	if (p != (void *)-1UL) {
> > +	if (p && p != (void *)-1UL) {
> >  		oom_kill_process(oc, p, points, totalpages, NULL,
> >  				 "Out of memory");
> >  		killed = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
