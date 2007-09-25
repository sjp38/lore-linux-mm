Date: Tue, 25 Sep 2007 12:18:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <46F949DC.1070806@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.0.9999.0709251208580.20644@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com> <46F949DC.1070806@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Balbir Singh wrote:

> > If an OOM was triggered as a result a cgroup's memory controller, the
> > tasklist shall be filtered to exclude tasks that are not a member of the
> > same group.
> > 
> > Creates a helper function to return non-zero if a task is a member of a
> > mem_cgroup:
> > 
> > 	int task_in_mem_cgroup(const struct task_struct *task,
> > 			       const struct mem_cgroup *mem);
> > 
> > Cc: Christoph Lameter <clameter@sgi.com>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Thanks for doing this. The number of parameters to OOM kill
> have grown, may at the time of the next addition of parameter,
> we should consider using a structure similar to scan_control
> and pass the structure instead of all the parameters.
> 

I mentioned in the description of patch #5 in this set that the kernel 
will probably eventually want a generic tasklist dumping interface that 
allows users to specify what they want displayed for each task, even 
though that's going to introduce a large number of new flags like 
DUMP_PID, DUMP_TOTAL_VM_SIZE, etc.

It would be trivial to include a callback function to do the filtering for 
such a tasklist dumping interface that returns non-zero to display a task 
and zero otherwise.

So now our interface prototype looks like this:

	void dump_tasks(int (*filter)(const struct task_struct *),
		        unsigned long flags)

That's simple enough, but the work in converting other tasklist dumps over 
to using this interface and the number of flags this mechanism would 
require may not be so popular.  But, I agree, it's something that the 
kernel should have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
