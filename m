From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
Date: Tue, 10 Jul 2007 12:19:29 -0500
References: <4692D616.4010004@oracle.com> <200707091954.10502.dave.mccracken@oracle.com> <Pine.LNX.4.64.0707101727510.4717@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0707101727510.4717@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200707101219.29743.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: herbert.van.den.bergh@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 July 2007, Hugh Dickins wrote:
> On Mon, 9 Jul 2007, Dave McCracken wrote:
> > On Monday 09 July 2007, Herbert van den Bergh wrote:
> > > With this patch, not only memory in the data segment of a process, but
> > > also private data mappings, both file-based and anonymous, are counted
> > > toward the RLIMIT_DATA resource limit.  Executable mappings, such as
> > > text segments of shared objects, are not counted toward the private
> > > data limit.  The result is that malloc() will fail once the combined
> > > size of the data segment and private data mappings reaches this limit.
> > >
> > > This brings the Linux behavior in line with what is documented in the
> > > POSIX man page for setrlimit(3p).
>
> Which says malloc() can fail from it, but conspicuously not that mmap()
> can fail from it: unlike the RLIMIT_AS case.  Would we be better off?

True.  But keep in mind that when POSIX was written mmap() was new and shiny 
and pretty much only used for shared mappings, and definitely not used by 
malloc().

> > I believe this patch is a simple and obvious fix to a hole introduced
> > when libc malloc() began using mmap() instead of brk().
>
> But didn't libc start doing that many years ago?  Wouldn't that have
> been the time for such a patch rather than now: when it can only break
> apps that are currently working?

Yes, probably.  But it got missed.

> > We took away the ability
> > to control how much data space processes could soak up.  This patch
> > returns that control to the user.
>
> I remember thinking that the idea of data ulimit had become obsolete
> (just preserved for compatibility) back when mmap() got invented and
> used for dynamic libraries.  I think that's when they brought in
> RLIMIT_AS, something which could make sense in the mmap() world.
>
> This patch does give it more meaning.  But if we are prepared to
> take the risk of breaking things in this way (I think not but don't
> mind being corrected), it would be more accurate to take writability
> into account, and use that quantity (sadly not stored in mm_struct,
> would have to be added) which we do security_vm_enough_memory() upon,
> which totals up into /proc/meminfo's Committed_AS.

Given that RLIMIT_DATA is pretty much meaningless in current kernels, I would 
put forward the argument that this change is extremely unlikely to break 
anything because no one is currently setting it to anything other than 
unlimited.  Adding this feature would give administrators another tool, a way 
to control the private data size of a process without restricting its ability 
to attach to large shared mappings.

> That change to /proc/PID/status VmData:
> -	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
> +	data = mm->total_vm - mm->shared_vm - mm->stack_vm - mm->exec_vm;
> looks plausible, but isn't exec_vm already counted as shared_vm,
> so now being doubly subtracted?  Besides which, we wouldn't want
> to change those numbers again without consulting Albert.

As I recall, this was added after Herbert discovered that exec_vm is not 
counted as shared_vm.  It's actually mapped as private/readonly.

> Hugh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
