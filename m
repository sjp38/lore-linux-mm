Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 1300E6B0081
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 07:42:31 -0400 (EDT)
Date: Thu, 19 Jul 2012 13:42:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
Message-ID: <20120719114228.GD2864@tiehlicka.suse.cz>
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120718142628.76bf78b3.akpm@linux-foundation.org>
 <87hat4794l.fsf@skywalker.in.ibm.com>
 <5007B034.4030909@huawei.com>
 <87wr20f5pj.fsf@skywalker.in.ibm.com>
 <5007E0A2.70906@jp.fujitsu.com>
 <87r4s8f0v9.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r4s8f0v9.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 19-07-12 16:56:18, Aneesh Kumar K.V wrote:
> Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> >>>>>
> >>>>> We test RES_USAGE before taking hugetlb_lock.  What prevents some other
> >>>>> thread from increasing RES_USAGE after that test?
> >>>>>
> >>>>> After walking the list we test RES_USAGE after dropping hugetlb_lock.
> >>>>> What prevents another thread from incrementing RES_USAGE before that
> >>>>> test, triggering the BUG?
> >>>>
> >>>> IIUC core cgroup will prevent a new task getting added to the cgroup
> >>>> when we are in pre_destroy. Since we already check that the cgroup doesn't
> >>>> have any task, the RES_USAGE cannot increase in pre_destroy.
> >>>>
> >>>
> >>>
> >>> You're wrong here. We release cgroup_lock before calling pre_destroy and retrieve
> >>> the lock after that, so a task can be attached to the cgroup in this interval.
> >>>
> >>
> >> But that means rmdir can be racy right ? What happens if the task got
> >> added, allocated few pages and then moved out ? We still would have task
> >> count 0 but few pages, which we missed to to move to parent cgroup.
> >>
> >
> > That's a problem even if it's verrrry unlikely.
> > I'd like to look into it and fix the race in cgroup layer.
> > But I'm sorry I'm a bit busy in these days...
> >
> 
> How about moving that mutex_unlock(&cgroup_mutex) to memcg callback ? That
> can be a patch for 3.5 ? 

Bahh, I have just posted a follow up on mm-commits email exactly about
this. Sorry I have missed that the discussion is still ongoing. I have
posted also something I guess should help. Can we follow up on that one
or should I post the patch here as well?

> 
> -aneesh
>  
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
