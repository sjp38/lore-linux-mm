From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
Date: Tue, 10 Jul 2007 14:12:19 -0500
References: <4692D616.4010004@oracle.com> <200707101219.29743.dave.mccracken@oracle.com> <Pine.LNX.4.64.0707101857310.20758@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0707101857310.20758@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707101412.19785.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: herbert.van.den.bergh@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 July 2007, Hugh Dickins wrote:
> On Tue, 10 Jul 2007, Dave McCracken wrote:
> > Given that RLIMIT_DATA is pretty much meaningless in current kernels, I
> > would put forward the argument that this change is extremely unlikely to
> > break anything because no one is currently setting it to anything other
> > than unlimited.  Adding this feature would give administrators another
> > tool, a way to control the private data size of a process without
> > restricting its ability to attach to large shared mappings.
>
> That may be a good argument (though "extremely unlikely to break"s
> have a nasty habit of biting).  I'd still say that the contribution
> to Committed_AS is more appropriate and more useful here.

You may be right... I suppose everything will bite someone somewhere with a 
sufficiently large user base.

As for whether Committed_AS is more appropriate, I'll have to defer to Herbert 
on this one.  He stated that RLIMIT_DATA no longer does what it was intended 
to do, and offered a fix for it, and I agreed with him.  I do believe his 
patch does a reasonable approximation of the original intent of RLIMIT_DATA, 
but I didn't delve into the actual intended use of it once it's fixed.

> > > That change to /proc/PID/status VmData:
> > > -	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
> > > +	data = mm->total_vm - mm->shared_vm - mm->stack_vm - mm->exec_vm;
> > > looks plausible, but isn't exec_vm already counted as shared_vm,
> > > so now being doubly subtracted?  Besides which, we wouldn't want
> > > to change those numbers again without consulting Albert.
> >
> > As I recall, this was added after Herbert discovered that exec_vm is not
> > counted as shared_vm.  It's actually mapped as private/readonly.
>
> Mapped private readonly yes, but vm_stat_account() says
> 	if (file) {
> 		mm->shared_vm += pages;
> 		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
> 			mm->exec_vm += pages;

In that code shared_vm includes everything that's mmap()ed, including private 
mappings.  But if you look at Herbert's patch he has the following change:

        if (file) {
-               mm->shared_vm += pages;
+               if (flags & VM_SHARED)
+                       mm->shared_vm += pages;
                if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
                        mm->exec_vm += pages;

This means that shared_vm now is truly only memory that's mapped VM_SHARED and 
does not include VM_EXEC memory.  That necessitates the separate subtraction 
of exec_vm in the data calculations.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
