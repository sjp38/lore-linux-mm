Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 200BA6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:36:16 -0400 (EDT)
Date: Thu, 28 Jun 2012 14:36:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20120628123611.GA16042@tiehlicka.suse.cz>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com>
 <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
 <20120627154827.GA4420@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, aneesh.kumar@linux.vnet.ibm.com

[Adding Kame and Aneesh to CC]

On Wed 27-06-12 13:04:51, David Rientjes wrote:
> On Wed, 27 Jun 2012, Michal Hocko wrote:
> 
> > > # mount -t cgroup -o memory xxx /cgroup/
> > > # ll /cgroup/memory.memsw.*
> > > -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.failcnt
> > > -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.limit_in_bytes
> > > -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.max_usage_in_bytes
> > > -r--r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.usage_in_bytes
> > > # cat /cgroup/memory.memsw.*
> > > cat: /cgroup/memory.memsw.failcnt: Operation not supported
> > > cat: /cgroup/memory.memsw.limit_in_bytes: Operation not supported
> > > cat: /cgroup/memory.memsw.max_usage_in_bytes: Operation not supported
> > > cat: /cgroup/memory.memsw.usage_in_bytes: Operation not supported
> > > 
> > > I'm confusing why it can't read memory.memsw.* files.
> > 
> > Those files are exported if CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y even
> > if the feature is turned off when any attempt to open the file returns
> > EOPNOTSUPP which is exactly what you are seeing.
> > This is a deliberate decision see: b6d9270d (memcg: always create memsw
> > files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP).
> > 
> 
> You mean af36f906c0f4?

Ahh, right. The other one was from the mm tree. Sorry about the confusion.

> > Does this help to explain your problem? Do you actually see any problem
> > with this behavior?
> > 
> 
> I think it's a crappy solution and one that is undocumented in 
> Documentation/cgroups/memory.txt.  

Yes the documentation part is really missing. I don't think the current
state is ideal as well...

> If you can only enable swap accounting at boot either via .config     
> or the command line then these files should never be added for        
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n or when do_swap_account is 0.       

Yes, I think we can enhance the internal implementation to support
configurable files (hugetlb controler would benefit from it as well
because the exported files depend on the supported/configured huge page
sizes). What about something like (totally untested) patch bellow? If
this sounds like a reasonable thing to support I can spin a regular
patch...
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d3f5fba..3fc7859 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -527,6 +527,7 @@ struct cgroup_subsys {
 
 	/* base cftypes, automatically [de]registered with subsys itself */
 	struct cftype *base_cftypes;
+	bool (*cftype_enabled)(const char *name);
 	struct cftype_set base_cftset;
 
 	/* should be defined only by modular subsystems */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0f3527d..0d1a25d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2726,6 +2726,9 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 	int err, ret = 0;
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
+		if (subsys->cftype_enabled && !subsys->cftype_enabled(cft->name))
+			continue;
+
 		if (is_add)
 			err = cgroup_add_file(cgrp, subsys, cft);
 		else
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a2677e0..45b65ba 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -72,6 +72,13 @@ static int really_do_swap_account __initdata = 1;
 static int really_do_swap_account __initdata = 0;
 #endif
 
+bool mem_cgroup_file_enabled(const char *name)
+{
+	if (!strncmp("memsw.", name, 6))
+		return do_swap_account;
+	return true;
+}
+
 #else
 #define do_swap_account		0
 #endif
@@ -5521,6 +5528,9 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.base_cftypes = mem_cgroup_files,
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+	.cftype_enabled = mem_cgroup_file_enabled,
+#endif
 	.early_init = 0,
 	.use_id = 1,
 	.__DEPRECATED_clear_css_refs = true,

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
