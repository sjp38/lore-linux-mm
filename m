Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 6FD826B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:30:04 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4165907pbb.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 11:30:03 -0700 (PDT)
Date: Thu, 28 Jun 2012 11:29:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20120628182934.GD22641@google.com>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com>
 <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
 <20120627154827.GA4420@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
 <20120628123611.GA16042@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120628123611.GA16042@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, aneesh.kumar@linux.vnet.ibm.com

Hello, Michal.

On Thu, Jun 28, 2012 at 02:36:11PM +0200, Michal Hocko wrote:
> @@ -2726,6 +2726,9 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
>  	int err, ret = 0;
>  
>  	for (cft = cfts; cft->name[0] != '\0'; cft++) {
> +		if (subsys->cftype_enabled && !subsys->cftype_enabled(cft->name))
> +			continue;
> +
>  		if (is_add)
>  			err = cgroup_add_file(cgrp, subsys, cft);
>  		else

I hope we could avoid this dynamic decision.  That was one of the main
reasons behind doing the cftype thing.  It's better to be able to
"declare" these kind of things rather than being able to implement
fully flexible dynamic logic.  Too much flexibility often doesn't
achieve much while being a hindrance to evolution of code base (trying
to improve / simplify X - ooh... there's this single wacko corner case
YYY here which is really different from all other users).

really_do_swap_account can't change once booted, right?  Why not just
separate out memsw cfts into a separate array and call
cgroup_add_cftypes() from init path?  Can't we do that from
enable_swap_cgroup()?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
