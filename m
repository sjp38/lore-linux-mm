Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 90A39280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:44:29 -0400 (EDT)
Received: by ieik3 with SMTP id k3so22539817iei.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:44:29 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id a5si9351918igm.0.2015.07.14.16.44.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 16:44:29 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so58782051igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:44:29 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:44:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 1/3] mm, oom: organize oom context into struct
In-Reply-To: <20150714155251.ddb7ef5a54b3b1f49d5fc968@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1507141641380.16182@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com> <alpine.DEB.2.10.1507011435150.14014@chino.kir.corp.google.com> <alpine.DEB.2.10.1507081641480.16585@chino.kir.corp.google.com>
 <20150714155251.ddb7ef5a54b3b1f49d5fc968@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 14 Jul 2015, Andrew Morton wrote:

> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -12,6 +12,14 @@ struct notifier_block;
> >  struct mem_cgroup;
> >  struct task_struct;
> >  
> > +struct oom_control {
> > +	struct zonelist *zonelist;
> > +	nodemask_t	*nodemask;
> > +	gfp_t		gfp_mask;
> > +	int		order;
> > +	bool		force_kill;
> > +};
> 
> Some docs would be nice.
> 

Ok!

> gfp_mask and order are what the page-allocating caller originally asked
> for, I think?  They haven't been mucked with?
> 

Yes, it's a good opportunity to make them const.

> It's somewhat obvious what force_kill does, but why is it provided, why
> is it set?  And what does it actually kill?  A process which was
> selected based on the other fields...
> 

It's removed in the next patch since it's unneeded, so I'll define what 
order == -1 means.

> Also, it's a bit odd that zonelist and nodemask are here.  They're
> low-level implementation details whereas the other three fields are
> high-level caller control stuff.
> 

Zonelist and nodemask are indeed pretty weird here.  We use them to 
determine if the oom kill is constrained by cpuset and/or mempolicy, 
respectively so we don't kill things unnecessarily and leave a cpuset 
still oom, for example.  We could determine that before actually calling 
the oom killer and passing the enum oom_constraint in, but its purpose is 
for the oom killer so it's just a part of that logical unit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
