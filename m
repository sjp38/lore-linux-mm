Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6953B6B005D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 15:49:26 -0400 (EDT)
Received: by ggm4 with SMTP id 4so5362584ggm.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:49:25 -0700 (PDT)
Date: Fri, 20 Jul 2012 12:49:20 -0700
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
Message-ID: <20120720194920.GB21218@google.com>
References: <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2012 at 07:39:32PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We dropped cgroup mutex, because of a deadlock between memcg and cpuset.
> cpuset took hotplug lock followed by cgroup_mutex, where as memcg pre_destroy
> did lru_add_drain_all() which took hotplug lock while already holding
> cgroup_mutex. The deadlock is explained in 3fa59dfbc3b223f02c26593be69ce6fc9a940405
> But dropping cgroup_mutex in cgroup_rmdir also means tasks could get
> added to cgroup while we are in pre_destroy. This makes error handling in
> pre_destroy complex. So move the unlock/lock to memcg pre_destroy callback.
> Core cgroup will now call pre_destroy with cgroup_mutex held.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

So, umm, let's not do this at this point.  Please just fix memcg such
that it doesn't fail ->pre_destroy() and drop
subsys->__DEPRECATED_clear_css_refs.  cgroup core won't give away new
references during or after pre_destroy that way and memcg is the ONLY
subsystem needing the deprecated behavior so it's rather
counter-productive to implement work-around at this point.

 Nacked-And-Please-Drop-The-DEPRECATED-Behavior-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
