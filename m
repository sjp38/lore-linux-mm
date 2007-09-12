Date: Wed, 12 Sep 2007 12:08:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 23 of 24] serialize for cpusets
In-Reply-To: <20070912061003.39506e07.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709121207170.16331@chino.kir.corp.google.com>
References: <patchbomb.1187786927@v2.random> <a3d679df54ebb1f977b9.1187786950@v2.random> <20070912061003.39506e07.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> > # HG changeset patch
> > # User David Rientjes <rientjes@google.com>
> > # Date 1187778125 -7200
> > # Node ID a3d679df54ebb1f977b97ab6b3e501134bf9e7ef
> > # Parent  8807a4d14b241b2d1132fde7f83834603b6cf093
> > serialize for cpusets
> > 
> > Adds a last_tif_memdie_jiffies field to struct cpuset to store the
> > jiffies value at the last OOM kill.  This will detect deadlocks in the
> > CONSTRAINT_CPUSET case and kill another task if its detected.
> > 
> > Adds a CS_OOM bit to struct cpuset's flags field.  This will be tested,
> > set, and cleared atomically to denote a cpuset that currently has an
> > attached task exiting as a result of the OOM killer.  We are required to
> > take p->alloc_lock to dereference p->cpuset so this cannot be implemented
> > as a simple trylock.
> > 
> > As a result, we cannot allow the detachment of a task from a cpuset that
> > is currently OOM killing one of its tasks.  If we did, we would end up
> > clearing the CS_OOM bit in the wrong cpuset upon that task's exit.
> > 
> > sysctl's panic_on_oom is now only effected in the non-cpuset-constrained
> > case.
> > 
> > Cc: Andrea Arcangeli <andrea@suse.de>
> > Cc: Christoph Lameter <clameter@sgi.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> I understand that SGI's HPC customers care rather a lot about oom handling
> in cpusets.  It'd be nice if people@sgi could carefully review-and-test
> changes such as this before we go and break stuff for them, please.
> 

During the initial review of this change, Paul Jackson suggested adding 
oom_kill_asking_task, which the next patch in this series does, to switch 
this on and off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
