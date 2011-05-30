Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEDB6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 03:12:17 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2188543qwa.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 00:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 30 May 2011 16:12:13 +0900
Message-ID: <BANLkTi=EoetGhW5+Qnvvn_WxA2R5R+D4gw@mail.gmail.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andi Kleen <andi@firstfloor.org>

On Mon, May 30, 2011 at 4:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sun, 29 May 2011 23:19:48 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>>
>> (switched to email. =C2=A0Please respond via emailed reply-to-all, not v=
ia the
>> bugzilla web interface).
>>
>> On Mon, 30 May 2011 02:38:33 GMT bugzilla-daemon@bugzilla.kernel.org wro=
te:
>>
>> > https://bugzilla.kernel.org/show_bug.cgi?id=3D36192
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: Kernel panic when bo=
ot the 2.6.39+ kernel based off of
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
2.6.32 kernel
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Memory Management
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> > =C2=A0 =C2=A0 Kernel Version: 2.6.39+
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: Page Allocator
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: akpm@linux-foundation.org
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: qcui@redhat.com
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: Yes
>> >
>> >
>> > Created an attachment (id=3D60012)
>> > =C2=A0--> (https://bugzilla.kernel.org/attachment.cgi?id=3D60012)
>> > kernel panic console output
>> >
>> > When I updated the kernel from 2.6.32 to 2.6.39+ on a server with AMD
>> > Magny-Cours CPU, the server can not boot the 2.6.39+ kernel successful=
ly. The
>> > console ouput showed 'Kernel panic - not syncing: Attempted to kill th=
e idle
>> > task!' I have tried to set the kernel parameter idle=3Dpoll in the gru=
b file. It
>> > still failed to reboot due to the same error. But it can reboot succes=
sfully on
>> > the server with Intel CPU. The full console output is attached.
>> >
>> > Steps to reproduce:
>> > 1. install the 2.6.32 kernel
>> > 2. compile and install the kernel 2.6.39+
>> > 3. reboot
>> >
>>
>> hm, this is not good. =C2=A0Might be memcg-related?
>>
>
> yes, and the system may be able to boot with a boot option of cgroup_disa=
ble=3Dmemory.
> but the problem happens in __alloc_pages_nodemask with NULL pointer acces=
s.
> Hmm, doesn't this imply some error in building zone/pgdat ?

I have tracked down this issue.
http://marc.info/?l=3Dlinux-mm&m=3D130616558019604&w=3D2

Qiannan, Could you test it with reverting patches mentioned in above URL?

>
> Thanks,
> -Kame
>
>
>> > BUG: unable to handle kernel paging request at 0000000000001c08
>> > IP: [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
>> > PGD 0
>> > Oops: 0000 [#1] SMP
>> > last sysfs file:
>> > CPU 0
>> > Modules linked in:
>> >
>> > Pid: 0, comm: swapper Not tainted 2.6.39+ #1 AMD DRACHMA/DRACHMA
>> > RIP: 0010:[<ffffffff811076cc>] =C2=A0[<ffffffff811076cc>] __alloc_page=
s_nodemask+0x7c/0x1f0
>> > RSP: 0000:ffffffff81a01e48 =C2=A0EFLAGS: 00010246
>> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
>> > RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00000000000002d0
>> > RBP: ffffffff81a01ea8 R08: ffffffff81c03680 R09: 0000000000000000
>> > R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000002d0
>> > R13: 0000000000001c00 R14: ffffffff81a01fa8 R15: 0000000000000000
>> > FS: =C2=A00000000000000000(0000) GS:ffff880437800000(0000) knlGS:00000=
00000000000
>> > CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> > CR2: 0000000000001c08 CR3: 0000000001a03000 CR4: 00000000000006b0
>> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> > Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a=
0b020)
>> > Stack:
>> > =C2=A00000000000000000 0000000000000000 ffffffff81a01eb8 000002d000000=
008
>> > =C2=A0ffffffff00000020 ffffffff81a01ec8 ffffffff81a01e88 0000000000000=
008
>> > =C2=A00000000000100000 0000000000000000 ffffffff81a01fa8 0000000000093=
cf0
>> > Call Trace:
>> > =C2=A0[<ffffffff81107d7f>] alloc_pages_exact_nid+0x5f/0xc0
>> > =C2=A0[<ffffffff814b2dea>] alloc_page_cgroup+0x2a/0x80
>> > =C2=A0[<ffffffff814b2ece>] init_section_page_cgroup+0x8e/0x110
>> > =C2=A0[<ffffffff81c4a2f1>] page_cgroup_init+0x6e/0xa7
>> > =C2=A0[<ffffffff81c22de4>] start_kernel+0x2ae/0x366
>> > =C2=A0[<ffffffff81c22346>] x86_64_start_reservations+0x131/0x135
>> > =C2=A0[<ffffffff81c2244d>] x86_64_start_kernel+0x103/0x112
>> > Code: e0 08 83 f8 01 44 89 e0 19 db c1 e8 13 f7 d3 83 e0 01 83 e3 02 0=
9 c3 8b 05 22 e5 af 00 44 21 e0 a8 10 89 45 bc 0f 85 c4 00 00 00
>> > =C2=A083 7d 08 00 0f 84 dd 00 00 00 65 4c 8b 34 25 c0 cc 00 00 41
>> > RIP =C2=A0[<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
>> > =C2=A0RSP <ffffffff81a01e48>
>> > CR2: 0000000000001c08
>>
>>
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
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
