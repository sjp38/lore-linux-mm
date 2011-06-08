Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7392A6B0083
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 06:20:07 -0400 (EDT)
Message-ID: <4DEF4CC5.7040403@snapgear.com>
Date: Wed, 8 Jun 2011 20:19:49 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] nommu: add page_align to mmap
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>	<4DE88112.3090908@snapgear.com>	<BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>	<4DEEFEEB.3090103@snapgear.com> <BANLkTi=8G6Z5RpvK6wDuzdF-0t7wDwnTOA@mail.gmail.com>
In-Reply-To: <BANLkTi=8G6Z5RpvK6wDuzdF-0t7wDwnTOA@mail.gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org


Hi Bob,

On 08/06/11 17:18, Bob Liu wrote:
> Hi, Greg
>
> On Wed, Jun 8, 2011 at 12:47 PM, Greg Ungerer<gerg@snapgear.com>  wrote:
>> Hi Bob,
>>
>> On 07/06/11 16:19, Bob Liu wrote:
>>>
>>> On Fri, Jun 3, 2011 at 2:37 PM, Greg Ungerer<gerg@snapgear.com>  =C3=A1=
wrote:
>>>>
>>>> Hi Bob,
>>>>
>>>> On 06/05/11 16:03, Bob Liu wrote:
>>>>>
>>>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>>>> page_align()
>>>>> which isn't consist with mmu arch and cause some issues.
>>>>>
>>>>> First, some drivers' mmap() function depends on vma->vm_end - vma->st=
art
>>>>> is
>>>>> page aligned which is true on mmu arch but not on nommu. eg: uvc came=
ra
>>>>> driver.
>>>>>
>>>>> Second munmap() may return -EINVAL[split file] error in cases when en=
d
>>>>> is
>>>>> not
>>>>> page aligned(passed into from userspace) but vma->vm_end is aligned d=
ure
>>>>> to
>>>>> split or driver's mmap() ops.
>>>>>
>>>>> This patch add page align to fix those issues.
>>>>
>>>> This is actually causing me problems on head at the moment.
>>>> git bisected to this patch as the cause.
>>>>
>>>> When booting on a ColdFire (m68knommu) target the init process (or
>>>> there abouts at least) fails. Last console messages are:
>>>>
>>>> =E2=94=9C=C3=AD...
>>>> =E2=94=9C=C3=ADVFS: Mounted root (romfs filesystem) readonly on device=
 31:0.
>>>> =E2=94=9C=C3=ADFreeing unused kernel memory: 52k freed (0x401aa000 - 0=
x401b6000)
>>>> =E2=94=9C=C3=ADUnable to mmap process text, errno 22
>>>>
>>>
>>> Oh, bad news. I will try to reproduce it on my board.
>>> If you are free please enable debug in nommu.c and then we can see what
>>> caused the problem.
>>
>> Yep, with debug on:
>>
>> =C3=A1...
>> =C3=A1VFS: Mounted root (romfs filesystem) readonly on device 31:0.
>> =C3=A1Freeing unused kernel memory: 52k freed (0x4018c000 - 0x40198000)
>> =C3=A1=3D=3D>  do_mmap_pgoff(,0,6780,5,1002,0)
>> =C3=A1<=3D=3D do_mmap_pgoff() =3D -22
>> =C3=A1Unable to mmap process text, errno 22
>>
>
> Since I can't reproduce this problem, could you please attach the
> whole dmesg log with nommu debug on or
> you can step into to see why errno 22 is returned, is it returned by
> do_mmap_private()?

There was no other debug messages with debug turned on in nommu.c.
(I can give you the boot msgs before this if you want, but there
was no nommu.c debug in it).

But I did trace it into do_mmap_pgoff() to see what was failing.
It fails based on the return value from:

           addr =3D file->f_op->get_unmapped_area(file, addr, len,
                                                       pgoff, flags);


Theres only one call of this inside do_mmap_pgoff() so you its
easy to find.

Regards
Greg



>> I can confirm that the PAGE_ALIGN(len) change in do_mmap_pgoff()
>> is enough to cause this too.
>>
>> Regards
>> Greg
>>
>>
>>
>>
>>>> I haven't really debugged it any further yet. But that error message
>>>> comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.
>>>>
>>>> Reverting that this patch and no more problem.
>>>>
>>>> Regards
>>>> Greg
>>>>
>>
>> ------------------------------------------------------------------------
>> Greg Ungerer =C3=A1-- =C3=A1Principal Engineer =C3=A1 =C3=A1 =C3=A1 =C3=
=A1EMAIL: =C3=A1 =C3=A1 gerg@snapgear.com
>> SnapGear Group, McAfee =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =
=C3=A1 =C3=A1 =C3=A1 =C3=A1PHONE: =C3=A1 =C3=A1 =C3=A1 +61 7 3435 2888
>> 8 Gardner Close =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =
=C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 FAX: =C3=A1 =C3=A1 =C3=A1 =C3=A1 =
+61 7 3217 5323
>> Milton, QLD, 4064, Australia =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =C3=A1 =
=C3=A1 =C3=A1WEB: http://www.SnapGear.com
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
