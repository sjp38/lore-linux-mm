Date: Wed, 26 Sep 2007 14:47:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
Message-Id: <20070926144748.768efcbe.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709261337080.23401@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
	<20070926130616.f16446fd.akpm@linux-foundation.org>
	<alpine.DEB.0.9999.0709261337080.23401@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: andrea@suse.de, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Sep 2007 13:46:49 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > Nor is it obvious why we need it at all.  This sort of information can
> > already be gathered from /proc/pid/whatever.  If the system is all wedged
> > and you can't get console control then this info dump doesn't provide you
> > with info which you're interested in anyway - you want to see the global
> > (or per-cgroup) info, not the per-task info.
> > 
> 
> It can be gathered by other means, yes, but not at the time of OOM nor 
> immediately before a task is killed.  This tasklist dump is done very 
> close to the OOM kill and it represents the per-task memory state, whether 
> system or cgroup, that triggered that event.

OK, that's useful.  But your changelog was completely wrong - it implies
that this sysctl _causes_ the dump, rather than stating that the sysctl
_enables_ an oom-kill-time dump:

  Adds a new sysctl, 'oom_dump_tasks', that dumps a list of all system
  tasks (excluding kernel threads) and their pid, uid, tgid, vm size, rss
  cpu, oom_adj score, and name.

  Helpful for determining why an OOM condition occurred and what rogue
  task caused it.

and silly me believed it.

And now I understand why it has "oom_' in the name.

I'd further suggest that the Documentation/sysctl/vm.txt buries the lede a
bit.  Better would be to start with "Enabling this causes a system-wide
task dump to be produced when the kernel performs an oom-killing ..."

>  This could be done other 
> ways, for instance with an OOM userspace notifier, but that would delay 
> the SIGKILL being sent.  So in the interest of a fast OOM killer, it's 
> best to dump the information ourselves, if the user chose to enable that 
> functionality.
> 
> The information should be displayed in a per-task manner because the 
> global memory state doesn't really matter: we know we're OOM, because 
> we're in the OOM killer.  Showing how little free memory we have isn't 
> immediately helpful on a system-wide basis.  But oom_dump_tasks, the way 
> I've written it, allows you to identify the "rogue" task that is using way 
> more memory than expected and allows you to alter oom_adj scores in the 
> case when the task you've identified, and the one you want dead, isn't the 
> one that ends up being killed.

Well I get it now ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
