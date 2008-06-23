Date: Mon, 23 Jun 2008 15:29:41 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 6/6] memcg: HARDWALL hierarchy
Message-Id: <20080623152941.1283ecce.randy.dunlap@oracle.com>
In-Reply-To: <20080613183741.5e2f7fda.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20080613183741.5e2f7fda.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 18:37:41 +0900 KAMEZAWA Hiroyuki wrote:

> Support hardwall hierarchy (and no-hierarchy) in memcg.
> 
> Change log: v3->v4
>  - cut out from memcg hierarchy patch set v4.
>  - no major changes, but some amount of functions are moved to res_counter.
>    and be more gneric.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  Documentation/controllers/memory.txt |   57 +++++++++++++++++++++++++++++-
>  mm/memcontrol.c                      |   65 +++++++++++++++++++++++++++++++++--
>  2 files changed, 118 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/memory.txt
> +++ linux-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
> @@ -154,7 +154,7 @@ The memory controller uses the following
>  
>  0. Configuration

I apologize if you have already corrected these.  I'm a bit behind
on doc reviews.


> -a. Enable CONFIG_CGROUPS
> +a. Enable CONFESS_CGROUPS

Really?  Looks odd and backwards.

>  b. Enable CONFIG_RESOURCE_COUNTERS
>  c. Enable CONFIG_CGROUP_MEM_RES_CTLR
>  
> @@ -237,7 +237,58 @@ cgroup might have some charge associated
>  tasks have migrated away from it. Such charges are automatically dropped at
>  rmdir() if there are no tasks.
>  
> -5. TODO
> +5. Supported Hierarchy Model
> +
> +Currently, memory controller supports following models of hierarchy in the
> +kernel. (see also resource_counter.txt)
> +
> +2 files are related to hierarchy.
> + - memory.hierarchy_model
> + - memory.for_children
> +
> +Basic Rule.
> +  - Hierarchy can be set per cgroup.
> +  - A child inherits parent's hierarchy model at creation.
> +  - A child can change its hierarchy only when the parent's hierarchy is
> +    NO_HIERARCY and it has no children.

       NO_HIERARCHY

> +
> +
> +5.1. NO_HIERARCHY
> +  - Each cgroup is independent from other ones.
> +  - When memory.hierarchy_model is 0, NO_HIERARCHY is used.
> +    Under this model, there is no controls based on tree of cgroups.

	                 there are no controls

> +    This is the default model of root cgroup.
> +
> +5.2 HARDWALL_HIERARCHY
> +  - A child is a isolated portion of the parent.

               is an

> +  - When memory.hierarchy_model is 1, HARDWALL_HIERARCHY is used.
> +    In this model a child's limit is charged as parent's usage.
> +
> +  Hard-Wall Hierarchy Example)

Drop ')'.

> +  1) Assume a cgroup with 1GB limits. (and no tasks belongs to this, now)
> +     - group_A limit=1G,usage=0M.

	                  , usage=0M.

> +
> +  2) create group B, C under A.
> +     - group A limit=1G, usage=0M, for_childre=0M

	                              for_children=0M

> +          - group B limit=0M, usage=0M.
> +          - group C limit=0M, usage=0M.
> +
> +  3) increase group B's limit to 300M.
> +     - group A limit=1G, usage=300M, for_children=300M
> +          - group B limit=300M, usage=0M.
> +          - group C limit=0M, usage=0M.
> +
> +  4) increase group C's limit to 500M
> +     - group A limit=1G, usage=800M, for_children=800M
> +          - group B limit=300M, usage=0M.
> +          - group C limit=500M, usage=0M.
> +
> +  5) reduce group B's limit to 100M
> +     - group A limit=1G, usage=600M, for_children=600M.
> +          - group B limit=100M, usage=0M.
> +          - group C limit=500M, usage=0M.


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
