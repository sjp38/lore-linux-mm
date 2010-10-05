Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7851A6B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 05:18:30 -0400 (EDT)
Date: Tue, 5 Oct 2010 11:18:36 +0200
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty
 limits
Message-ID: <20101005091836.GA1698@linux.develer.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
 <1286175485-30643-9-git-send-email-gthelen@google.com>
 <20101005161340.9bb7382e.kamezawa.hiroyu@jp.fujitsu.com>
 <xr93r5g5w0uc.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93r5g5w0uc.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 05, 2010 at 12:33:15AM -0700, Greg Thelen wrote:
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > On Sun,  3 Oct 2010 23:58:03 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> Add cgroupfs interface to memcg dirty page limits:
> >>   Direct write-out is controlled with:
> >>   - memory.dirty_ratio
> >>   - memory.dirty_bytes
> >> 
> >>   Background write-out is controlled with:
> >>   - memory.dirty_background_ratio
> >>   - memory.dirty_background_bytes
> >> 
> >> Signed-off-by: Andrea Righi <arighi@develer.com>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > a question below.
> >
> >
> >> ---
> >>  mm/memcontrol.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  1 files changed, 89 insertions(+), 0 deletions(-)
> >> 
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 6ec2625..2d45a0a 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -100,6 +100,13 @@ enum mem_cgroup_stat_index {
> >>  	MEM_CGROUP_STAT_NSTATS,
> >>  };
> >>  
> >> +enum {
> >> +	MEM_CGROUP_DIRTY_RATIO,
> >> +	MEM_CGROUP_DIRTY_BYTES,
> >> +	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> >> +	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> >> +};
> >> +
> >>  struct mem_cgroup_stat_cpu {
> >>  	s64 count[MEM_CGROUP_STAT_NSTATS];
> >>  };
> >> @@ -4292,6 +4299,64 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
> >>  	return 0;
> >>  }
> >>  
> >> +static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
> >> +{
> >> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> >> +	bool root;
> >> +
> >> +	root = mem_cgroup_is_root(mem);
> >> +
> >> +	switch (cft->private) {
> >> +	case MEM_CGROUP_DIRTY_RATIO:
> >> +		return root ? vm_dirty_ratio : mem->dirty_param.dirty_ratio;
> >> +	case MEM_CGROUP_DIRTY_BYTES:
> >> +		return root ? vm_dirty_bytes : mem->dirty_param.dirty_bytes;
> >> +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> >> +		return root ? dirty_background_ratio :
> >> +			mem->dirty_param.dirty_background_ratio;
> >> +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> >> +		return root ? dirty_background_bytes :
> >> +			mem->dirty_param.dirty_background_bytes;
> >> +	default:
> >> +		BUG();
> >> +	}
> >> +}
> >> +
> >> +static int
> >> +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> >> +{
> >> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> >> +	int type = cft->private;
> >> +
> >> +	if (cgrp->parent == NULL)
> >> +		return -EINVAL;
> >> +	if ((type == MEM_CGROUP_DIRTY_RATIO ||
> >> +	     type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)
> >> +		return -EINVAL;
> >> +	switch (type) {
> >> +	case MEM_CGROUP_DIRTY_RATIO:
> >> +		memcg->dirty_param.dirty_ratio = val;
> >> +		memcg->dirty_param.dirty_bytes = 0;
> >> +		break;
> >> +	case MEM_CGROUP_DIRTY_BYTES:
> >> +		memcg->dirty_param.dirty_bytes = val;
> >> +		memcg->dirty_param.dirty_ratio  = 0;
> >> +		break;
> >> +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> >> +		memcg->dirty_param.dirty_background_ratio = val;
> >> +		memcg->dirty_param.dirty_background_bytes = 0;
> >> +		break;
> >> +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> >> +		memcg->dirty_param.dirty_background_bytes = val;
> >> +		memcg->dirty_param.dirty_background_ratio = 0;
> >> +		break;
> >
> >
> > Curious....is this same behavior as vm_dirty_ratio ?
> 
> I think this is same behavior as vm_dirty_ratio.  When vm_dirty_ratio is
> changed then dirty_ratio_handler() will set vm_dirty_bytes=0.  When
> vm_dirty_bytes is written dirty_bytes_handler() will set
> vm_dirty_ratio=0.  So I think that the per-memcg dirty memory parameters
> mimic the behavior of vm_dirty_ratio, vm_dirty_bytes and the other
> global dirty parameters.
> 
> Am I missing your question?

mmh... looking at the code it seems the same behaviour, but in
Documentation/sysctl/vm.txt we say a different thing (i.e., for
dirty_bytes):

"If dirty_bytes is written, dirty_ratio becomes a function of its value
(dirty_bytes / the amount of dirtyable system memory)."

However, in dirty_bytes_handler()/dirty_ratio_handler() we actually set
the counterpart value as 0.

I think we should clarify the documentation.

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 Documentation/sysctl/vm.txt |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b606c2c..30289fa 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -80,8 +80,10 @@ dirty_background_bytes
 Contains the amount of dirty memory at which the pdflush background writeback
 daemon will start writeback.
 
-If dirty_background_bytes is written, dirty_background_ratio becomes a function
-of its value (dirty_background_bytes / the amount of dirtyable system memory).
+Note: dirty_background_bytes is the counterpart of dirty_background_ratio. Only
+one of them may be specified at a time. When one sysctl is written it is
+immediately taken into account to evaluate the dirty memory limits and the
+other appears as 0 when read.
 
 ==============================================================
 
@@ -97,8 +99,10 @@ dirty_bytes
 Contains the amount of dirty memory at which a process generating disk writes
 will itself start writeback.
 
-If dirty_bytes is written, dirty_ratio becomes a function of its value
-(dirty_bytes / the amount of dirtyable system memory).
+Note: dirty_bytes is the counterpart of dirty_ratio. Only one of them may be
+specified at a time. When one sysctl is written it is immediately taken into
+account to evaluate the dirty memory limits and the other appears as 0 when
+read.
 
 Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
 value lower than this limit will be ignored and the old configuration will be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
