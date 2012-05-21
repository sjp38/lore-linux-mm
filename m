Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 86D1C6B00E7
	for <linux-mm@kvack.org>; Mon, 21 May 2012 15:39:41 -0400 (EDT)
Received: by wefh52 with SMTP id h52so5429220wef.14
        for <linux-mm@kvack.org>; Mon, 21 May 2012 12:39:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120521154709.GA8697@redhat.com>
References: <20120517213120.GA12329@redhat.com> <20120518185851.GA5728@redhat.com>
 <20120521154709.GA8697@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 May 2012 12:39:19 -0700
Message-ID: <CA+55aFyqMJ1X08kQwJ7snkYo6MxfVKqFJx7LXBkP_ug4LTCZ=Q@mail.gmail.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

Added some more people explicitly to the cc, in case they don't peruse
the mailing lists as carefully as their personal emails.

It certainly looks like some kind of mpol_get/put imbalance.

However, looking at mm/mempolicy.c, I really want to just dig out my
own eyes with a spoon. All the games with MPOL_F_SHARED in particular
look *really* unsafe. In particular, why i it safe to suddenly set
MPOL_F_SHARED in sp_alloc(), when it previously was unshared and might
have random stale refcounts if so?

The locking is also *really* hard to read. It's full of conditional
locks/unlock things, see for example do_mbind(), which really is
inexcusably ugly in just about all respects.

But there's not a lot of recent stuff. The thing that jumps out is Mel
Gorman's recent commit cc9a6c8776615 ("cpuset: mm: reduce large
amounts of memory barrier related damage v3"), which has a whole new
loop with that scary mpol_cond_put() usage. And there's we had
problems with vma merging..

Dave, how recent is this problem? Have you already tried older kernels?

Kosaki, Mel, Christoph, please give Dave's system call fuzzer a test,
maybe you can see what the problem is quickly..

                              Linus

On Mon, May 21, 2012 at 8:47 AM, Dave Jones <davej@redhat.com> wrote:
> On Fri, May 18, 2012 at 02:58:51PM -0400, Dave Jones wrote:
> =A0> On Thu, May 17, 2012 at 05:31:20PM -0400, Dave Jones wrote:
> =A0>
> =A0> =A0> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> =A0> =A0> BUG numa_policy (Not tainted): Poison overwritten
> =A0> =A0> ---------------------------------------------------------------=
--------------
> =A0> =A0>
> =A0> =A0> INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a in=
stead of 0x6b
> =A0> =A0> INFO: Allocated in mpol_new+0xa3/0x140 age=3D46310 cpu=3D6 pid=
=3D32154
> =A0> =A0> =A0 __slab_alloc+0x3d3/0x445
> =A0> =A0> =A0 kmem_cache_alloc+0x29d/0x2b0
> =A0> =A0> =A0 mpol_new+0xa3/0x140
> =A0> =A0> =A0 sys_mbind+0x142/0x620
> =A0> =A0> =A0 system_call_fastpath+0x16/0x1b
> =A0> =A0> INFO: Freed in __mpol_put+0x27/0x30 age=3D46268 cpu=3D6 pid=3D3=
2154
> =A0> =A0> =A0 __slab_free+0x2e/0x1de
> =A0> =A0> =A0 kmem_cache_free+0x25a/0x260
> =A0> =A0> =A0 __mpol_put+0x27/0x30
> =A0> =A0> =A0 remove_vma+0x68/0x90
> =A0> =A0> =A0 exit_mmap+0x118/0x140
> =A0> =A0> =A0 mmput+0x73/0x110
> =A0> =A0> =A0 exit_mm+0x108/0x130
> =A0> =A0> =A0 do_exit+0x162/0xb90
> =A0> =A0> =A0 do_group_exit+0x4f/0xc0
> =A0> =A0> =A0 sys_exit_group+0x17/0x20
> =A0> =A0> =A0 system_call_fastpath+0x16/0x1b
> =A0> =A0> INFO: Slab 0xffffea0005192600 objects=3D27 used=3D27 fp=3D0x =
=A0 =A0 =A0 =A0 =A0(null) flags=3D0x20000000004080
> =A0> =A0> INFO: Object 0xffff880146498250 @offset=3D592 fp=3D0xffff880146=
49b9d0
> =A0>
> =A0> As I can reproduce this fairly easily, I enabled the dynamic debug p=
rints for mempolicy.c,
> =A0> and noticed something odd (but different to the above trace..)
> =A0>
> =A0> INFO: 0xffff88014649abf0-0xffff88014649abf0. First byte 0x6a instead=
 of 0x6b
> =A0> INFO: Allocated in mpol_new+0xa3/0x140 age=3D196087 cpu=3D7 pid=3D11=
496
> =A0> =A0__slab_alloc+0x3d3/0x445
> =A0> =A0kmem_cache_alloc+0x29d/0x2b0
> =A0> =A0mpol_new+0xa3/0x140
> =A0> =A0sys_mbind+0x142/0x620
> =A0> =A0system_call_fastpath+0x16/0x1b
> =A0> INFO: Freed in __mpol_put+0x27/0x30 age=3D40838 cpu=3D7 pid=3D20824
> =A0> =A0__slab_free+0x2e/0x1de
> =A0> =A0kmem_cache_free+0x25a/0x260
> =A0> =A0__mpol_put+0x27/0x30
> =A0> =A0mpol_set_shared_policy+0xe6/0x280
> =A0> =A0shmem_set_policy+0x2a/0x30
> =A0> =A0shm_set_policy+0x28/0x30
> =A0> =A0sys_mbind+0x4e7/0x620
> =A0> =A0system_call_fastpath+0x16/0x1b
> =A0> INFO: Slab 0xffffea0005192600 objects=3D27 used=3D27 fp=3D0x =A0 =A0=
 =A0 =A0 =A0(null) flags=3D0x20000000004080
> =A0> INFO: Object 0xffff88014649abf0 @offset=3D11248 fp=3D0xffff880146498=
de0
> =A0>
> =A0> In this case, it seems the policy was allocated by pid 11496, and fr=
eed by a different pid!
> =A0> How is that possible ? =A0(Does kind of explain why it looks like a =
double-free though I guess).
> =A0>
> =A0> debug printout for the relevant pids below, in case it yields furthe=
r clues..
>
> Anyone ? =A0This can be reproduced very quickly by doing..
>
> $ git clone git://git.codemonkey.org.uk/trinity.git
> $ make
> $ ./trinity -q -c mbind
>
> On my 8-core box, it happens within 30 seconds.
>
> If I run this long enough, the box wedges completely, needing a power cyc=
le to reboot.
>
> =A0 =A0 =A0 =A0Dave
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
