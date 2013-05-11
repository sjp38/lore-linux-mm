Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0625A6B0033
	for <linux-mm@kvack.org>; Sat, 11 May 2013 04:20:06 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id ey16so1323916wid.12
        for <linux-mm@kvack.org>; Sat, 11 May 2013 01:20:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <518D6C18.4070607@gmx.de>
References: <518D6C18.4070607@gmx.de>
Date: Sat, 11 May 2013 10:20:05 +0200
Message-ID: <CAFLxGvwen6WwNoh3iZ2j+dK8iQsxVkjhnvaXjdfXATF+mmwtuw@mail.gmail.com>
Subject: Re: [uml-user] WARNING: at mm/slab_common.c:376 kmalloc_slab+0x33/0x80()
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "user-mode-linux-user@lists.sourceforge.net" <user-mode-linux-user@lists.sourceforge.net>

On Fri, May 10, 2013 at 11:52 PM, Toralf F=F6rster <toralf.foerster@gmx.de>=
 wrote:
> The bisected commit introduced this WARNING: on a user mode linux guest
> if the UML guest is fuzz tested with trinity :
>
>
> 2013-05-10T22:38:42.191+02:00 trinity kernel: ------------[ cut here ]---=
---------
> 2013-05-10T22:38:42.191+02:00 trinity kernel: WARNING: at mm/slab_common.=
c:376 kmalloc_slab+0x33/0x80()
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fda8:  [<08336928>] dum=
p_stack+0x22/0x24
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fdc0:  [<0807c2da>] war=
n_slowpath_common+0x5a/0x80
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fde8:  [<0807c3a3>] war=
n_slowpath_null+0x23/0x30
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fdf8:  [<080dfc93>] kma=
lloc_slab+0x33/0x80
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe0c:  [<080f8beb>] __k=
malloc_track_caller+0x1b/0x110
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe30:  [<080dc866>] mem=
dup_user+0x26/0x70
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe4c:  [<080dca6e>] str=
ndup_user+0x3e/0x60
> 2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe68:  [<0811ba60>] cop=
y_mount_string+0x30/0x50
> 2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fe7c:  [<0811c46a>] sys=
_mount+0x1a/0xe0
> 2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2feac:  [<08062b32>] han=
dle_syscall+0x82/0xb0
> 2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fef4:  [<0807520d>] use=
rspace+0x46d/0x590
> 2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2ffec:  [<0805f7fc>] for=
k_handler+0x6c/0x70
> 2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fffc:  [<00000000>] 0x0
> 2013-05-10T22:38:42.195+02:00 trinity kernel:
> 2013-05-10T22:38:42.195+02:00 trinity kernel: ---[ end trace 17e5931469d0=
697d ]---
>
>
> Tested with host kernel 3.9.1, host and client were 32bit stable Gentoo L=
inux.
>
>
> 6286ae97d10ea2b5cd90532163797ab217bfdbdf is the first bad commit
> commit 6286ae97d10ea2b5cd90532163797ab217bfdbdf
> Author: Christoph Lameter <cl@linux.com>
> Date:   Fri May 3 15:43:18 2013 +0000
>
>     slab: Return NULL for oversized allocations
>
>     The inline path seems to have changed the SLAB behavior for very larg=
e
>     kmalloc allocations with  commit e3366016 ("slab: Use common
>     kmalloc_index/kmalloc_size functions"). This patch restores the old
>     behavior but also adds diagnostics so that we can figure where in the
>     code these large allocations occur.
>
>     Reported-and-tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne=
.jp>
>     Signed-off-by: Christoph Lameter <cl@linux.com>
>     Link: http://lkml.kernel.org/r/201305040348.CIF81716.OStQOHFJMFLOVF@I=
-love.SAKURA.ne.jp
>     [ penberg@kernel.org: use WARN_ON_ONCE ]
>     Signed-off-by: Pekka Enberg <penberg@kernel.org>
>

So, we trigger "if (WARN_ON_ONCE(size > KMALLOC_MAX_SIZE))".
Now I'm wondering what kind of argument string trinity gave to mount().
How long is it?

BTW: Toralf, why are you sending this to user-mode-linux-*user*@lists...?
We also have a -devel list. Please at least CC me.
Otherwise it is most likely that I miss such reports...

--
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
