Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 773B16B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 11:10:16 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so14847203wiv.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 08:10:16 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id fz7si36430145wjb.100.2015.01.12.08.10.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 08:10:13 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id l15so15718591wiw.4
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 08:10:13 -0800 (PST)
Date: Mon, 12 Jan 2015 17:10:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v3 5/5] oom, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150112161011.GE4877@dhcp22.suse.cz>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
 <1420801555-22659-6-git-send-email-mhocko@suse.cz>
 <20150110194322.GE25319@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150110194322.GE25319@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sat 10-01-15 14:43:22, Tejun Heo wrote:
> On Fri, Jan 09, 2015 at 12:05:55PM +0100, Michal Hocko wrote:
> ...
> > @@ -142,7 +118,6 @@ static bool check_frozen_processes(void)
> >  int freeze_processes(void)
> >  {
> >  	int error;
> > -	int oom_kills_saved;
> >  
> >  	error = __usermodehelper_disable(UMH_FREEZING);
> >  	if (error)
> > @@ -157,29 +132,22 @@ int freeze_processes(void)
> >  	pm_wakeup_clear();
> >  	pr_info("Freezing user space processes ... ");
> >  	pm_freezing = true;
> > -	oom_kills_saved = oom_kills_count();
> >  	error = try_to_freeze_tasks(true);
> >  	if (!error) {
> >  		__usermodehelper_set_disable_depth(UMH_DISABLED);
> > -		oom_killer_disable();
> > -
> > -		/*
> > -		 * There might have been an OOM kill while we were
> > -		 * freezing tasks and the killed task might be still
> > -		 * on the way out so we have to double check for race.
> > -		 */
> > -		if (oom_kills_count() != oom_kills_saved &&
> > -		    !check_frozen_processes()) {
> > -			__usermodehelper_set_disable_depth(UMH_ENABLED);
> > -			pr_cont("OOM in progress.");
> > -			error = -EBUSY;
> > -		} else {
> > -			pr_cont("done.");
> > -		}
> > +		pr_cont("done.");
> >  	}
> >  	pr_cont("\n");
> >  	BUG_ON(in_atomic());
> >  
> > +	/*
> > +	 * Now that the whole userspace is frozen we need to disbale
> > +	 * the OOM killer to disallow any further interference with
> > +	 * killable tasks.
> > +	 */
> > +	if (!error && !oom_killer_disable())
> 
> So, previously, oom killer was disabled at the top of
> freeze_kernel_threads(), right?  I think that was the better spot to
> do that.  We don't want to disable oom killer before the system is
> just about to enter total quiescence which is freeze_kernel_threads().
> We want to delay this as long as possible.  Let's please disable oom
> killing in at the top of freeze_kernel_threads() and re-enable at the
> bottom of thaw_kernel_threads().

Yes I had it this way but it didn't work out because thaw_kernel_threads
is not called on the resume because it is only used as a fail
path when kernel threads freezing fails. I would rather keep the
enabling/disabling points as we had them. This is less risky IMHO.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
