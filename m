Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 778726B0099
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:20:44 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id q1so1156488lam.4
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 07:20:43 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id li6si19166049lbc.87.2014.10.21.07.20.42
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 07:20:42 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Date: Tue, 21 Oct 2014 16:41:07 +0200
Message-ID: <4766859.KSKPTm3b0x@vostro.rjw.lan>
In-Reply-To: <20141021141159.GE9415@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz> <2156351.pWp6MNRoWm@vostro.rjw.lan> <20141021141159.GE9415@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tuesday, October 21, 2014 04:11:59 PM Michal Hocko wrote:
> On Tue 21-10-14 15:42:23, Rafael J. Wysocki wrote:
> > On Tuesday, October 21, 2014 03:14:45 PM Michal Hocko wrote:
> > > On Tue 21-10-14 14:09:27, Rafael J. Wysocki wrote:
> > > [...]
> > > > > @@ -131,12 +132,40 @@ int freeze_processes(void)
> > > > >  
> > > > >  	printk("Freezing user space processes ... ");
> > > > >  	pm_freezing = true;
> > > > > +	oom_kills_saved = oom_kills_count();
> > > > >  	error = try_to_freeze_tasks(true);
> > > > >  	if (!error) {
> > > > > -		printk("done.");
> > > > >  		__usermodehelper_set_disable_depth(UMH_DISABLED);
> > > > >  		oom_killer_disable();
> > > > > +
> > > > > +		/*
> > > > > +		 * There might have been an OOM kill while we were
> > > > > +		 * freezing tasks and the killed task might be still
> > > > > +		 * on the way out so we have to double check for race.
> > > > > +		 */
> > > > > +		if (oom_kills_count() != oom_kills_saved) {
> > > > > +			struct task_struct *g, *p;
> > > > > +
> > > > > +			read_lock(&tasklist_lock);
> > > > > +			for_each_process_thread(g, p) {
> > > > > +				if (p == current || freezer_should_skip(p) ||
> > > > > +				    frozen(p))
> > > > > +					continue;
> > > > > +				error = -EBUSY;
> > > > > +				goto out_loop;
> > > > > +			}
> > > > > +out_loop:
> > > > 
> > > > Well, it looks like this will work here too:
> > > > 
> > > > 			for_each_process_thread(g, p)
> > > > 				if (p != current && !frozen(p) &&
> > > > 				    !freezer_should_skip(p)) {
> > > > 					error = -EBUSY;
> > > > 					break;
> > > > 				}
> > > > 
> > > > or I am helplessly misreading the code.
> > > 
> > > break will not work because for_each_process_thread is a double loop.
> > 
> > I see.  In that case I'd do:
> > 
> >                         for_each_process_thread(g, p)
> >                                 if (p != current && !frozen(p) &&
> >                                     !freezer_should_skip(p)) {
> > 
> > 					read_unlock(&tasklist_lock);
> > 
> > 					__usermodehelper_set_disable_depth(UMH_ENABLED);
> > 					printk("OOM in progress.");
> >                                         error = -EBUSY;
> >                                         goto done;
> >                                 }
> > 
> > to avoid adding the new label that looks odd.
> 
> OK, incremental diff on top. I will post the complete patch if you are
> happier with this change

Yes, I am.

> ---
> diff --git a/kernel/power/process.c b/kernel/power/process.c
> index a397fa161d11..7a37cf3eb1a2 100644
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -108,6 +108,28 @@ static int try_to_freeze_tasks(bool user_only)
>  	return todo ? -EBUSY : 0;
>  }
>  
> +/*
> + * Returns true if all freezable tasks (except for current) are frozen already
> + */
> +static bool check_frozen_processes(void)
> +{
> +	struct task_struct *g, *p;
> +	bool ret = true;
> +
> +	read_lock(&tasklist_lock);
> +	for_each_process_thread(g, p) {
> +		if (p != current && !freezer_should_skip(p) &&
> +		    !frozen(p)) {
> +			ret = false;
> +			goto done;
> +		}
> +	}
> +done:
> +	read_unlock(&tasklist_lock);
> +
> +	return ret;
> +}
> +
>  /**
>   * freeze_processes - Signal user space processes to enter the refrigerator.
>   * The current thread will not be frozen.  The same process that calls
> @@ -143,25 +165,12 @@ int freeze_processes(void)
>  		 * freezing tasks and the killed task might be still
>  		 * on the way out so we have to double check for race.
>  		 */
> -		if (oom_kills_count() != oom_kills_saved) {
> -			struct task_struct *g, *p;
> -
> -			read_lock(&tasklist_lock);
> -			for_each_process_thread(g, p) {
> -				if (p == current || freezer_should_skip(p) ||
> -				    frozen(p))
> -					continue;
> -				error = -EBUSY;
> -				goto out_loop;
> -			}
> -out_loop:
> -			read_unlock(&tasklist_lock);
> -
> -			if (error) {
> -				__usermodehelper_set_disable_depth(UMH_ENABLED);
> -				printk("OOM in progress.");
> -				goto done;
> -			}
> +		if (oom_kills_count() != oom_kills_saved &&
> +				!check_frozen_processes()) {
> +			__usermodehelper_set_disable_depth(UMH_ENABLED);
> +			printk("OOM in progress.");
> +			error = -EBUSY;
> +			goto done;
>  		}
>  		printk("done.");
>  	}
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
