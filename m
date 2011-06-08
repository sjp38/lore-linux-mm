Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 629F16B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 03:18:56 -0400 (EDT)
Received: by qwa26 with SMTP id 26so120310qwa.14
        for <linux-mm@kvack.org>; Wed, 08 Jun 2011 00:18:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DEEFEEB.3090103@snapgear.com>
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>
	<4DE88112.3090908@snapgear.com>
	<BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>
	<4DEEFEEB.3090103@snapgear.com>
Date: Wed, 8 Jun 2011 15:18:55 +0800
Message-ID: <BANLkTi=8G6Z5RpvK6wDuzdF-0t7wDwnTOA@mail.gmail.com>
Subject: Re: [PATCH v2] nommu: add page_align to mmap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@snapgear.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

Hi, Greg

On Wed, Jun 8, 2011 at 12:47 PM, Greg Ungerer <gerg@snapgear.com> wrote:
> Hi Bob,
>
> On 07/06/11 16:19, Bob Liu wrote:
>>
>> On Fri, Jun 3, 2011 at 2:37 PM, Greg Ungerer<gerg@snapgear.com> =C2=A0wr=
ote:
>>>
>>> Hi Bob,
>>>
>>> On 06/05/11 16:03, Bob Liu wrote:
>>>>
>>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>>> page_align()
>>>> which isn't consist with mmu arch and cause some issues.
>>>>
>>>> First, some drivers' mmap() function depends on vma->vm_end - vma->sta=
rt
>>>> is
>>>> page aligned which is true on mmu arch but not on nommu. eg: uvc camer=
a
>>>> driver.
>>>>
>>>> Second munmap() may return -EINVAL[split file] error in cases when end
>>>> is
>>>> not
>>>> page aligned(passed into from userspace) but vma->vm_end is aligned du=
re
>>>> to
>>>> split or driver's mmap() ops.
>>>>
>>>> This patch add page align to fix those issues.
>>>
>>> This is actually causing me problems on head at the moment.
>>> git bisected to this patch as the cause.
>>>
>>> When booting on a ColdFire (m68knommu) target the init process (or
>>> there abouts at least) fails. Last console messages are:
>>>
>>> =C3=83=C2=A1...
>>> =C3=83=C2=A1VFS: Mounted root (romfs filesystem) readonly on device 31:=
0.
>>> =C3=83=C2=A1Freeing unused kernel memory: 52k freed (0x401aa000 - 0x401=
b6000)
>>> =C3=83=C2=A1Unable to mmap process text, errno 22
>>>
>>
>> Oh, bad news. I will try to reproduce it on my board.
>> If you are free please enable debug in nommu.c and then we can see what
>> caused the problem.
>
> Yep, with debug on:
>
> =C2=A0...
> =C2=A0VFS: Mounted root (romfs filesystem) readonly on device 31:0.
> =C2=A0Freeing unused kernel memory: 52k freed (0x4018c000 - 0x40198000)
> =C2=A0=3D=3D> do_mmap_pgoff(,0,6780,5,1002,0)
> =C2=A0<=3D=3D do_mmap_pgoff() =3D -22
> =C2=A0Unable to mmap process text, errno 22
>

Since I can't reproduce this problem, could you please attach the
whole dmesg log with nommu debug on or
you can step into to see why errno 22 is returned, is it returned by
do_mmap_private()?

Thanks!

> I can confirm that the PAGE_ALIGN(len) change in do_mmap_pgoff()
> is enough to cause this too.
>
> Regards
> Greg
>
>
>
>
>>> I haven't really debugged it any further yet. But that error message
>>> comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.
>>>
>>> Reverting that this patch and no more problem.
>>>
>>> Regards
>>> Greg
>>>
>
> ------------------------------------------------------------------------
> Greg Ungerer =C2=A0-- =C2=A0Principal Engineer =C2=A0 =C2=A0 =C2=A0 =C2=
=A0EMAIL: =C2=A0 =C2=A0 gerg@snapgear.com
> SnapGear Group, McAfee =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0PHONE: =C2=A0 =C2=A0 =C2=A0 +61 7 3435 2888
> 8 Gardner Close =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FAX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
+61 7 3217 5323
> Milton, QLD, 4064, Australia =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0WEB: http://www.SnapGear.com
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
