Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 5A9A26B009D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:45:34 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7995602dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:45:33 -0700 (PDT)
Date: Tue, 26 Jun 2012 01:45:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11/11] protect architectures where THREAD_SIZE >= PAGE_SIZE
 against fork bombs
In-Reply-To: <4FE96358.6080601@parallels.com>
Message-ID: <alpine.DEB.2.00.1206260143450.16020@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-12-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252157000.30072@chino.kir.corp.google.com> <4FE96358.6080601@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@redhat.com>

On Tue, 26 Jun 2012, Glauber Costa wrote:

> > > diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> > > index ccc1899..914ec07 100644
> > > --- a/include/linux/thread_info.h
> > > +++ b/include/linux/thread_info.h
> > > @@ -61,6 +61,12 @@ extern long do_no_restart_syscall(struct restart_block
> > > *parm);
> > >   # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
> > >   #endif
> > > 
> > > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> > > +# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
> > > +#else
> > > +# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP)
> > > +#endif
> > > +
> > 
> > This type of requirement is going to become nasty very quickly if nobody
> > can use __GFP_KMEMCG without testing for CONFIG_CGROUP_MEM_RES_CTLR_KMEM.
> > Perhaps define __GFP_KMEMCG to be 0x0 if it's not enabled, similar to how
> > kmemcheck does?
> > 
> That is what I've done in my first version of this patch. At that time,
> Christoph wanted it to be this way so we would make sure it would never be
> used with #CONFIG_CGROUP_MEM_RES_CTLR_KMEM defined. A value of zero will
> generate no errors. Undefined value will.
> 
> Now, if you ask me, I personally prefer following what kmemcheck does here...
> 

Right, because I'm sure that __GFP_KMEMCG will be used in additional 
places outside of this patchset and it will be a shame if we have to 
always add #ifdef's.  I see no reason why we would care if __GFP_KMEMCG 
was used when CONFIG_CGROUP_MEM_RES_CTLR_KMEM=n with the semantics that it 
as in this patchset.  It's much cleaner by making it 0x0 when disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
