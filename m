Date: Fri, 11 Apr 2008 13:47:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v9)
Message-Id: <20080411134739.1aae8bae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47FEE89A.1010102@linux.vnet.ibm.com>
References: <20080410091602.4472.32172.sendpatchset@localhost.localdomain>
	<20080411123339.89aea319.kamezawa.hiroyu@jp.fujitsu.com>
	<47FEE89A.1010102@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Apr 2008 09:57:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > maybe I don't undestand correctlly...
> > 
> > On Thu, 10 Apr 2008 14:46:02 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >>  
> >> +config MM_OWNER
> >> +	bool
> >> +
> > no default is ok here  ? what value will this have if not selected ?
> > I'm sorry if I misunderstand Kconfig.
> > 
> 
> The way this works is
> 
> If I select memory resource controller, CONFIG_MM_OWNER is set to y, else it
> does not even show up in the .config
> 
ok, sorry for noise.

> > 
> >> +	/*
> >> +	 * Search through everything else. We should not get
> >> +	 * here often
> >> +	 */
> >> +	do_each_thread(g, c) {
> >> +		if (c->mm == mm)
> >> +			goto assign_new_owner;
> >> +	} while_each_thread(g, c);
> >> +
> > 
> > Again, do_each_thread() is suitable here ?
> > for_each_process() ?
> > 
> 
> do_each_thread(), while_each_thread() walks all processes and threads of those
> processes in the system. It is a common pattern used in the kernel (see
> try_to_freeze_tasks() or oom_kill_task() for example).
> 

What you want is finding a thread which has the "mm_struct". Why search all
threads ? I think you only have to search processes(i.e. thread-group-leaders).

try_to_freeze_tasks()/oom_kill_task() have to chase all threads because
it have to check flags in task_structs in a process.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
