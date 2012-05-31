Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 228B66B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 10:01:50 -0400 (EDT)
Date: Thu, 31 May 2012 16:01:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V7 10/14] hugetlbfs: Add new HugeTLB cgroup
Message-ID: <20120531140146.GC12809@tiehlicka.suse.cz>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1338388739-22919-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338388739-22919-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 30-05-12 20:08:55, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch implements a new controller that allows us to control HugeTLB
> allocations. The extension allows to limit the HugeTLB usage per control
> group and enforces the controller limit during page fault.  Since HugeTLB
> doesn't support page reclaim, enforcing the limit at page fault time implies
> that, the application will get SIGBUS signal if it tries to access HugeTLB
> pages beyond its limit. This requires the application to know beforehand
> how much HugeTLB pages it would require for its use.

You forgot to mention that the tracking is based on page_cgroup which
is essential IMO. This also means that shadow pages are allocated for
_every_ single page in the system even though only a preallocated huge
pages (their heads to be precise) use them. Please mention that in the
Kconfig help text as well. Users should be aware of that.
The overhead is huge but this might change in future because there is
tendency to merge page_cgroup with struct page.

I would also appreciate if you describe the motivation why is this a
separate controller here in the description.

You are also changing behavior of cgroup_disable slightly. Many users of
distribution kernels are used to disable memory controller (which is
compiled in by default) because of its memory footprint primarily so
they use cgroup_disable=memory boot parameter. Things changed with
this patch because this won't be enough and they have to learn about
hugetlb controller which has to be disabled as well (distributions will
have to compile it in as well).

As I already mentioned earlier I do not see any of these as a show
stopper. If people feel strong that this should be separate because
they need only hugetlb pages tracking without memcg then why not.
It is definitely much better than range tracking proposed at the
beginning.

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
