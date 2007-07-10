Date: Tue, 10 Jul 2007 19:06:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
In-Reply-To: <200707101219.29743.dave.mccracken@oracle.com>
Message-ID: <Pine.LNX.4.64.0707101857310.20758@blonde.wat.veritas.com>
References: <4692D616.4010004@oracle.com> <200707091954.10502.dave.mccracken@oracle.com>
 <Pine.LNX.4.64.0707101727510.4717@blonde.wat.veritas.com>
 <200707101219.29743.dave.mccracken@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: herbert.van.den.bergh@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Dave McCracken wrote:
> On Tuesday 10 July 2007, Hugh Dickins wrote:
> > > >
> > > > This brings the Linux behavior in line with what is documented in the
> > > > POSIX man page for setrlimit(3p).
> >
> > Which says malloc() can fail from it, but conspicuously not that mmap()
> > can fail from it: unlike the RLIMIT_AS case.  Would we be better off?
> 
> True.  But keep in mind that when POSIX was written mmap() was new and shiny 
> and pretty much only used for shared mappings, and definitely not used by 
> malloc().

Well, my bookmark is to SUSv3, which I think is equivalent these days?
And that specifically says malloc() or mmap() in the RLIMIT_AS case,
but only malloc() in the RLIMIT_DATA case.  We're wrong either way.

> Given that RLIMIT_DATA is pretty much meaningless in current kernels, I would 
> put forward the argument that this change is extremely unlikely to break 
> anything because no one is currently setting it to anything other than 
> unlimited.  Adding this feature would give administrators another tool, a way 
> to control the private data size of a process without restricting its ability 
> to attach to large shared mappings.

That may be a good argument (though "extremely unlikely to break"s
have a nasty habit of biting).  I'd still say that the contribution
to Committed_AS is more appropriate and more useful here.

> > That change to /proc/PID/status VmData:
> > -	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
> > +	data = mm->total_vm - mm->shared_vm - mm->stack_vm - mm->exec_vm;
> > looks plausible, but isn't exec_vm already counted as shared_vm,
> > so now being doubly subtracted?  Besides which, we wouldn't want
> > to change those numbers again without consulting Albert.
> 
> As I recall, this was added after Herbert discovered that exec_vm is not 
> counted as shared_vm.  It's actually mapped as private/readonly.

Mapped private readonly yes, but vm_stat_account() says
	if (file) {
		mm->shared_vm += pages;
		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
			mm->exec_vm += pages;

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
