Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1C77182BDD
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 09:14:50 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so1329022wgg.13
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:14:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc5si14477947wjc.104.2014.10.21.06.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 06:14:46 -0700 (PDT)
Date: Tue, 21 Oct 2014 15:14:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141021131445.GC9415@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <1413876435-11720-4-git-send-email-mhocko@suse.cz>
 <3778374.avm26S62SZ@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3778374.avm26S62SZ@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tue 21-10-14 14:09:27, Rafael J. Wysocki wrote:
[...]
> > @@ -131,12 +132,40 @@ int freeze_processes(void)
> >  
> >  	printk("Freezing user space processes ... ");
> >  	pm_freezing = true;
> > +	oom_kills_saved = oom_kills_count();
> >  	error = try_to_freeze_tasks(true);
> >  	if (!error) {
> > -		printk("done.");
> >  		__usermodehelper_set_disable_depth(UMH_DISABLED);
> >  		oom_killer_disable();
> > +
> > +		/*
> > +		 * There might have been an OOM kill while we were
> > +		 * freezing tasks and the killed task might be still
> > +		 * on the way out so we have to double check for race.
> > +		 */
> > +		if (oom_kills_count() != oom_kills_saved) {
> > +			struct task_struct *g, *p;
> > +
> > +			read_lock(&tasklist_lock);
> > +			for_each_process_thread(g, p) {
> > +				if (p == current || freezer_should_skip(p) ||
> > +				    frozen(p))
> > +					continue;
> > +				error = -EBUSY;
> > +				goto out_loop;
> > +			}
> > +out_loop:
> 
> Well, it looks like this will work here too:
> 
> 			for_each_process_thread(g, p)
> 				if (p != current && !frozen(p) &&
> 				    !freezer_should_skip(p)) {
> 					error = -EBUSY;
> 					break;
> 				}
> 
> or I am helplessly misreading the code.

break will not work because for_each_process_thread is a double loop.
Except for that the negated condition is OK as well. I can change that
if you prefer.

> > +			read_unlock(&tasklist_lock);
> > +
> > +			if (error) {
> > +				__usermodehelper_set_disable_depth(UMH_ENABLED);
> > +				printk("OOM in progress.");
> > +				goto done;
> > +			}
> > +		}
> > +		printk("done.");
> >  	}
> > +done:
> >  	printk("\n");
> >  	BUG_ON(in_atomic());
> >  
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
