Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 651246B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 10:16:29 -0500 (EST)
Received: by pzk34 with SMTP id 34so745595pzk.11
        for <linux-mm@kvack.org>; Fri, 06 Nov 2009 07:14:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091106133833.GA23151@gamma.logic.tuwien.ac.at>
References: <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	 <20091102155543.E60E.A69D9226@jp.fujitsu.com>
	 <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091102141917.GJ2116@gamma.logic.tuwien.ac.at>
	 <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
	 <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
	 <loom.20091105T213323-393@post.gmane.org>
	 <28c262360911051418r1aefbff6oa54a63d887c0ea48@mail.gmail.com>
	 <20091106000113.GE22289@gamma.logic.tuwien.ac.at>
	 <20091106133833.GA23151@gamma.logic.tuwien.ac.at>
Date: Sat, 7 Nov 2009 00:14:26 +0900
Message-ID: <28c262360911060714h16cf55dfibbecc090c76341ab@mail.gmail.com>
Subject: Re: OOM killer, page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: Jody Belka <jody+lkml@jj79.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 6, 2009 at 10:38 PM, Norbert Preining <preining@logic.at> wrote=
:
> Hi Kim,
>
> On Fr, 06 Nov 2009, preining wrote:
>> Recompiling already and trying to recreate the oom-killer boom.
>
> Well, after rebooting into that kernel I get *loads*, every few seconds,
> of warnings in the log. Hard to sort out what is real. Is that expected?

I guess it is VM_FAULT_NOPAGE of i915_gem or somethings.
It's not of our concern but VM_FAULT_OOM.
I couldn't expect that. So let's change debug patch following as.

Most important thing is "Who return VM_FAULT_OOM".
It it return VM_FAULT_OOM, OOM killer will kill any process who have a
high score. In case of you, it was 'X'.

If you don't see it until 2.6.32-rc5, It should be regression in somewhere.
If we can know it, we can pass the problem to maintainer of it.

Could you try it again below patch?
If you reproduce it, you can match function address of log with
function address
of your System.map. Pz, let me know it. :)

diff --git a/mm/memory.c b/mm/memory.c
index 7e91b5f..97a6fcb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2713,8 +2713,13 @@ static int __do_fault(struct mm_struct *mm,
struct vm_area_struct *vma,
    vmf.page =3D NULL;

    ret =3D vma->vm_ops->fault(vma, &vmf);
-   if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+   if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+       if (ret & VM_FAULT_OOM) {
+           printk(KERN_DEBUG "fault handler : 0x%lx\n", vma->vm_ops->fault=
);
+
+       }
        return ret;
+   }

    if (unlikely(PageHWPoison(vmf.page))) {
        if (ret & VM_FAULT_LOCKED)



>
> Excerpt from the log:
> [ 2077.753841] vma->vm_ops->fault : 0xffffffff811df4bd
> [ 2077.753842] ------------[ cut here ]------------
> [ 2077.753845] WARNING: at mm/memory.c:2722 __do_fault+0x89/0x382()
> [ 2077.753847] Hardware name: VGN-Z11VN_B
> ...
> [ 2077.753880] Pid: 4892, comm: Xorg Tainted: G =A0 =A0 =A0 =A0W =A02.6.3=
2-rc6 #5
> [ 2077.753881] Call Trace:
> [ 2077.753884] =A0[<ffffffff8108c6cc>] ? __do_fault+0x89/0x382
> [ 2077.753887] =A0[<ffffffff8108c6cc>] ? __do_fault+0x89/0x382
> [ 2077.753889] =A0[<ffffffff8103ae54>] ? warn_slowpath_common+0x77/0xa3
> [ 2077.753892] =A0[<ffffffff8108c6cc>] ? __do_fault+0x89/0x382
> [ 2077.753895] =A0[<ffffffff81341a82>] ? _spin_unlock+0x23/0x2f
> [ 2077.753898] =A0[<ffffffff8108e5d0>] ? handle_mm_fault+0x2b9/0x608
> [ 2077.753900] =A0[<ffffffff810af792>] ? do_vfs_ioctl+0x443/0x47b
> [ 2077.753903] =A0[<ffffffff81026759>] ? do_page_fault+0x25f/0x27b
> [ 2077.753906] =A0[<ffffffff81341e8f>] ? page_fault+0x1f/0x30
> [ 2077.753908] ---[ end trace d3324ef5061f0136 ]---
>
> hundreds/thousands of them.
>
> And even without starting anything else. Is that what you want?
> My syslog file has grown to some hundred megabytes ...
>
>
> Best wishes
>
> Norbert
>
> -------------------------------------------------------------------------=
------
> Dr. Norbert Preining =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0Associate Professor
> JAIST Japan Advanced Institute of Science and Technology =A0 preining@jai=
st.ac.jp
> Vienna University of Technology =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 preining@logic.at
> Debian Developer (Debian TeX Task Force) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0preining@debian.org
> gpg DSA: 0x09C5B094 =A0 =A0 =A0fp: 14DF 2E6C 0307 BE6D AD76 =A0A9C0 D2BF =
4AA3 09C5 B094
> -------------------------------------------------------------------------=
------
> LARGOWARD (n.)
> Motorists' name for the kind of pedestrian who stands beside a main
> road and waves on the traffic, as if it's their right of way.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--- Douglas Adams, The Mea=
ning of Liff
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
