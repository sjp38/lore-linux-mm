Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 7FB9F6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 15:27:12 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id c10so4095382wiw.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 12:27:11 -0700 (PDT)
Date: Tue, 4 Jun 2013 21:27:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130604192708.GD9321@dhcp22.suse.cz>
References: <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603153432.GC18588@dhcp22.suse.cz>
 <20130603164839.GG15576@cmpxchg.org>
 <20130603183018.GJ15576@cmpxchg.org>
 <20130604091749.GB31242@dhcp22.suse.cz>
 <20130604184852.GO15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604184852.GO15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 04-06-13 14:48:52, Johannes Weiner wrote:
> On Tue, Jun 04, 2013 at 11:17:49AM +0200, Michal Hocko wrote:
[...]
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 6dc1882..ff5e2d7 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -1815,7 +1815,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > >  			while (!(page = follow_page_mask(vma, start,
> > >  						foll_flags, &page_mask))) {
> > >  				int ret;
> > > -				unsigned int fault_flags = 0;
> > > +				unsigned int fault_flags = FAULT_FLAG_KERNEL;
> > >  
> > >  				/* For mlock, just skip the stack guard page. */
> > >  				if (foll_flags & FOLL_MLOCK) {
> > 
> > This is also a bit tricky. Say there is an unlikely situation when a
> > task fails to charge because of memcg OOM, it couldn't lock the oom
> > so it ended up with current->memcg_oom set and __get_user_pages will
> > turn VM_FAULT_OOM into ENOMEM but memcg_oom is still there. Then the
> > following global OOM condition gets confused (well the oom will be
> > triggered by somebody else so it shouldn't end up in the endless loop
> > but still...), doesn't it?
> 
> But current->memcg_oom is not set up unless current->in_userfault.
> And get_user_pages does not set this flag.

And my selective blindness strikes again :/ For some reason I have read
those places as they enable the fault flag. Which would make some sense
if there was a post handling...

Anyway, I will get back to the updated patch tomorrow with a clean and
fresh head.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
