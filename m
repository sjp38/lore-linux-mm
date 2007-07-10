Date: Tue, 10 Jul 2007 17:58:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
In-Reply-To: <200707091954.10502.dave.mccracken@oracle.com>
Message-ID: <Pine.LNX.4.64.0707101727510.4717@blonde.wat.veritas.com>
References: <4692D616.4010004@oracle.com> <200707091954.10502.dave.mccracken@oracle.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1657808215-1184086692=:4717"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: herbert.van.den.bergh@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--8323584-1657808215-1184086692=:4717
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 9 Jul 2007, Dave McCracken wrote:
> On Monday 09 July 2007, Herbert van den Bergh wrote:
> > With this patch, not only memory in the data segment of a process, but
> > also private data mappings, both file-based and anonymous, are counted
> > toward the RLIMIT_DATA resource limit. =C2=A0Executable mappings, such =
as
> > text segments of shared objects, are not counted toward the private dat=
a
> > limit. =C2=A0The result is that malloc() will fail once the combined si=
ze of
> > the data segment and private data mappings reaches this limit.
> >
> > This brings the Linux behavior in line with what is documented in the
> > POSIX man page for setrlimit(3p).

Which says malloc() can fail from it, but conspicuously not that mmap()
can fail from it: unlike the RLIMIT_AS case.  Would we be better off?

>=20
> I believe this patch is a simple and obvious fix to a hole introduced whe=
n=20
> libc malloc() began using mmap() instead of brk().

But didn't libc start doing that many years ago?  Wouldn't that have
been the time for such a patch rather than now: when it can only break
apps that are currently working?

> We took away the ability=20
> to control how much data space processes could soak up.  This patch retur=
ns=20
> that control to the user.

I remember thinking that the idea of data ulimit had become obsolete
(just preserved for compatibility) back when mmap() got invented and
used for dynamic libraries.  I think that's when they brought in
RLIMIT_AS, something which could make sense in the mmap() world.

This patch does give it more meaning.  But if we are prepared to
take the risk of breaking things in this way (I think not but don't
mind being corrected), it would be more accurate to take writability
into account, and use that quantity (sadly not stored in mm_struct,
would have to be added) which we do security_vm_enough_memory() upon,
which totals up into /proc/meminfo's Committed_AS.

That change to /proc/PID/status VmData:=20
-=09data =3D mm->total_vm - mm->shared_vm - mm->stack_vm;
+=09data =3D mm->total_vm - mm->shared_vm - mm->stack_vm - mm->exec_vm;
looks plausible, but isn't exec_vm already counted as shared_vm,
so now being doubly subtracted?  Besides which, we wouldn't want
to change those numbers again without consulting Albert.

Hugh
--8323584-1657808215-1184086692=:4717--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
