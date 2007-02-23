Subject: Re: [RFC] [PATCH 2.6.20-mm2] Optionally inherit mlockall()
	semantics across fork()/exec()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0702221507080.22567@schroedinger.engr.sgi.com>
References: <1172178237.5341.38.camel@localhost>
	 <Pine.LNX.4.64.0702221507080.22567@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 23 Feb 2007 09:58:01 -0500
Message-Id: <1172242682.5059.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-22 at 15:09 -0800, Christoph Lameter wrote:
> On Thu, 22 Feb 2007, Lee Schermerhorn wrote:
> 
> > Add an int to mm_struct to remember inheritance of future locks.
> 
> Should that not go into the task_struct rather than into mm_struct? 
> If you run your gizmo on a thread then all other threads of the process 
> will also be pinned.

Well, you currently can't run it on a thread--i.e., no way to affect an
existing task/thread.  It only works when launching an application.  I
have considered how to apply it to a running process, but I wanted to
float this proposal first.

The semantics of mlockall(), whether you use the '_CURRENT and/or the
'_FUTURE flag, apply to the entire address space of the process.  [See
http://www.opengroup.org/onlinepubs/7990989775/xsh/mlockall.html]  The
patch enables inheritance of these semantics across fork() [CURRENT] and
exec() [FUTURE].

> 
> Or put it into the vma like VM_MLOCK and inherit it when vmas are copied.

Again, mlockall(MCL_FUTURE) sets def_flags in the mm_struct so that it
applies to the entire address space.  Without this patch, dup_mm()
unconditionally removes the VM_LOCKED flags from vmas, in keeping with
the specified semantics of fork().  The MCL_INHERIT flag overrides this
particular semantic, and leaves the VM_LOCKED flag untouched in the
duplicated vmas.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
