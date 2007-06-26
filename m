Date: Tue, 26 Jun 2007 22:55:33 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] oom: serialize oom killer for cpusets
Message-ID: <20070626205533.GH7059@v2.random>
References: <alpine.DEB.0.99.0706260241460.26409@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.99.0706260241460.26409@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Jun 26, 2007 at 10:00:39AM -0700, David Rientjes wrote:
> Serializes the OOM killer for tasks attached to a cpuset.

This will help reducing the spurious-oom-kill window but it won't
close it completely because no memory is released until the sigkill is
handled and do_exit is called by the current task. I suspect you could
close the race window completely by using my same TIF_MEMDIE slow-path
to clear the CS_OOM bitflag in the cpuset (where I clear the global
VM_is_OOM) instead of doing it before returning from oom-kill which is
too early on. If you do that you should then move the cpuset_enter_oom
inside the tasklist lock because the clear op will also run inside it
(it won't make much difference, but so you're sure not to delay an oom
kill by mistake, trylock won't give a chance to any lock inversion
anyway).

BTW, since you applied on top of my oom patchset, I hope somebody will
help integrating it to mainline or at least -mm! ;)

If we're worried about Rik's report for patch 01 that shows a
regression with aim, that can be deferred until we know how much to
reduce DEF_PRIORITY to regain the current VM-tune but with the
uncontrolled smp-race removed. I can't believe that smp-race does
really any good other than altering the VM-tune so that they had to
un-adjust the VM tune for it in the first place to get the current
good behavior.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
