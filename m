Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA57D6B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 01:44:43 -0400 (EDT)
Received: by qyk29 with SMTP id 29so1924277qyk.14
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 22:44:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4EAA2492.3020907@cn.fujitsu.com>
References: <4EAA2492.3020907@cn.fujitsu.com>
Date: Fri, 28 Oct 2011 13:44:40 +0800
Message-ID: <CAA_GA1dr1j-LbO_DmEwzKm8ncypn65He=_AXY0LQk6BW8qKB5g@mail.gmail.com>
Subject: Re: [possible deadlock][3.1.0-g138c4ae] possible circular locking
 dependency detected
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaowanlong@cn.fujitsu.com
Cc: linux-fsdevel@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Oct 28, 2011 at 11:42 AM, Wanlong Gao <gaowanlong@cn.fujitsu.com> w=
rote:
> Hi folks:
>
> My dmesg said that:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> [ INFO: possible circular locking dependency detected ]
> 3.1.0-138c4ae #2
> -------------------------------------------------------
> hugemmap05/18198 is trying to acquire lock:
> =C2=A0(&mm->mmap_sem){++++++}, at: [<ffffffff8114d85c>] might_fault+0x5c/=
0xb0
>
> but task is already holding lock:
> =C2=A0(&sb->s_type->i_mutex_key#21){+.+.+.}, at: [<ffffffff811a10f6>] vfs=
_readdir+0x86/0xe0
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #1 (&sb->s_type->i_mutex_key#21){+.+.+.}:
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810afd34>] validate_chain+0x704/0x860
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810b018c>] __lock_acquire+0x2fc/0x500
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810b0b01>] lock_acquire+0xb1/0x1a0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff815464f2>] __mutex_lock_common+0x62/0x420
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff81546a1a>] mutex_lock_nested+0x4a/0x60
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff8120b4ba>] hugetlbfs_file_mmap+0xaa/0x160
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff81158071>] mmap_region+0x3e1/0x590
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff81158584>] do_mmap_pgoff+0x364/0x3b0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff811587d9>] sys_mmap_pgoff+0x209/0x240
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff8101aac9>] sys_mmap+0x29/0x30
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff81551542>] system_call_fastpath+0x16/0x1b
>
> -> #0 (&mm->mmap_sem){++++++}:
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810af607>] check_prev_add+0x537/0x560
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810afd34>] validate_chain+0x704/0x860
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810b018c>] __lock_acquire+0x2fc/0x500
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff810b0b01>] lock_acquire+0xb1/0x1a0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff8114d889>] might_fault+0x89/0xb0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff811a0f2e>] filldir+0x7e/0xe0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff811b445e>] dcache_readdir+0x5e/0x230
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff811a1130>] vfs_readdir+0xc0/0xe0
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff811a12c9>] sys_getdents+0x89/0x100
> =C2=A0 =C2=A0 =C2=A0 [<ffffffff81551542>] system_call_fastpath+0x16/0x1b
>
> other info that might help us debug this:
>
> =C2=A0Possible unsafe locking scenario:
>
> =C2=A0 =C2=A0 =C2=A0 CPU0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0CPU1
> =C2=A0 =C2=A0 =C2=A0 ---- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0----
> =C2=A0lock(&sb->s_type->i_mutex_key);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(&mm->mmap_sem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(&sb->s_type->i_mutex_key);
> =C2=A0lock(&mm->mmap_sem);
>
> =C2=A0*** DEADLOCK ***
>
> 1 lock held by hugemmap05/18198:
> =C2=A0#0: =C2=A0(&sb->s_type->i_mutex_key#21){+.+.+.}, at: [<ffffffff811a=
10f6>] vfs_readdir+0x86/0xe0
>
> stack backtrace:
> Pid: 18198, comm: hugemmap05 Not tainted 3.1.0-138c4ae #2
> Call Trace:
> =C2=A0[<ffffffff810ad469>] print_circular_bug+0x109/0x110
> =C2=A0[<ffffffff810af607>] check_prev_add+0x537/0x560
> =C2=A0[<ffffffff8114e112>] ? do_anonymous_page+0xf2/0x2d0
> =C2=A0[<ffffffff810afd34>] validate_chain+0x704/0x860
> =C2=A0[<ffffffff810b018c>] __lock_acquire+0x2fc/0x500
> =C2=A0[<ffffffff810b0b01>] lock_acquire+0xb1/0x1a0
> =C2=A0[<ffffffff8114d85c>] ? might_fault+0x5c/0xb0
> =C2=A0[<ffffffff8114d889>] might_fault+0x89/0xb0
> =C2=A0[<ffffffff8114d85c>] ? might_fault+0x5c/0xb0
> =C2=A0[<ffffffff81546763>] ? __mutex_lock_common+0x2d3/0x420
> =C2=A0[<ffffffff811a10f6>] ? vfs_readdir+0x86/0xe0
> =C2=A0[<ffffffff811a0f2e>] filldir+0x7e/0xe0
> =C2=A0[<ffffffff811b445e>] dcache_readdir+0x5e/0x230
> =C2=A0[<ffffffff811a0eb0>] ? filldir64+0xf0/0xf0
> =C2=A0[<ffffffff811a0eb0>] ? filldir64+0xf0/0xf0
> =C2=A0[<ffffffff811a0eb0>] ? filldir64+0xf0/0xf0
> =C2=A0[<ffffffff811a1130>] vfs_readdir+0xc0/0xe0
> =C2=A0[<ffffffff8118e9be>] ? fget+0xee/0x220
> =C2=A0[<ffffffff8118e8d0>] ? fget_raw+0x220/0x220
> =C2=A0[<ffffffff811a12c9>] sys_getdents+0x89/0x100
> =C2=A0[<ffffffff81551542>] system_call_fastpath+0x16/0x1b
>

Please try this patch "lockdep: Add helper function for dir vs file
i_mutex annotation" by josh.
http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3Dcommitd=
iff;h=3De096d0c7e2e4e5893792db865dd065ac73cf1f00

>
>
> Wile hugemmap05 is a test case from LTP.
> http://ltp.git.sourceforge.net/git/gitweb.cgi?p=3Dltp/ltp.git;a=3Dblob;f=
=3Dtestcases/kernel/mem/hugetlb/hugemmap/hugemmap05.c;h=3D50bb8ca23ae968666=
2740f9ea5d7187affff8b60;hb=3DHEAD
>
> But I don't know how to reproduce this.
>
>
> Thanks
> -Wanlong Gao
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
