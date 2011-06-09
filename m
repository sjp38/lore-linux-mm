Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 17FCF6B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 06:31:01 -0400 (EDT)
Received: by qyk30 with SMTP id 30so904848qyk.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 03:30:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DEF4CC5.7040403@snapgear.com>
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>
	<4DE88112.3090908@snapgear.com>
	<BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>
	<4DEEFEEB.3090103@snapgear.com>
	<BANLkTi=8G6Z5RpvK6wDuzdF-0t7wDwnTOA@mail.gmail.com>
	<4DEF4CC5.7040403@snapgear.com>
Date: Thu, 9 Jun 2011 18:30:59 +0800
Message-ID: <BANLkTi=AJ=0pFx2OXENZF4p4gh7V2RXmXw@mail.gmail.com>
Subject: Re: [PATCH v2] nommu: add page_align to mmap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@snapgear.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

On Wed, Jun 8, 2011 at 6:19 PM, Greg Ungerer <gerg@snapgear.com> wrote:
>
> Hi Bob,
>
> On 08/06/11 17:18, Bob Liu wrote:
>>
>> Hi, Greg
>>
>> On Wed, Jun 8, 2011 at 12:47 PM, Greg Ungerer<gerg@snapgear.com> =C2=A0w=
rote:
>>>
>>> Hi Bob,
>>>
>>> On 07/06/11 16:19, Bob Liu wrote:
>>>>
>>>> On Fri, Jun 3, 2011 at 2:37 PM, Greg Ungerer<gerg@snapgear.com>
>>>> =C2=A0=C3=83=C2=A1wrote:
>>>>>
>>>>> Hi Bob,
>>>>>
>>>>> On 06/05/11 16:03, Bob Liu wrote:
>>>>>>
>>>>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>>>>> page_align()
>>>>>> which isn't consist with mmu arch and cause some issues.
>>>>>>
>>>>>> First, some drivers' mmap() function depends on vma->vm_end -
>>>>>> vma->start
>>>>>> is
>>>>>> page aligned which is true on mmu arch but not on nommu. eg: uvc
>>>>>> camera
>>>>>> driver.
>>>>>>
>>>>>> Second munmap() may return -EINVAL[split file] error in cases when e=
nd
>>>>>> is
>>>>>> not
>>>>>> page aligned(passed into from userspace) but vma->vm_end is aligned
>>>>>> dure
>>>>>> to
>>>>>> split or driver's mmap() ops.
>>>>>>
>>>>>> This patch add page align to fix those issues.
>>>>>
>>>>> This is actually causing me problems on head at the moment.
>>>>> git bisected to this patch as the cause.
>>>>>
>>>>> When booting on a ColdFire (m68knommu) target the init process (or
>>>>> there abouts at least) fails. Last console messages are:
>>>>>
>>>>> =C3=A2=E2=80=9D=C5=93=C3=83=C2=AD...
>>>>> =C3=A2=E2=80=9D=C5=93=C3=83=C2=ADVFS: Mounted root (romfs filesystem)=
 readonly on device 31:0.
>>>>> =C3=A2=E2=80=9D=C5=93=C3=83=C2=ADFreeing unused kernel memory: 52k fr=
eed (0x401aa000 - 0x401b6000)
>>>>> =C3=A2=E2=80=9D=C5=93=C3=83=C2=ADUnable to mmap process text, errno 2=
2
>>>>>
>>>>
>>>> Oh, bad news. I will try to reproduce it on my board.
>>>> If you are free please enable debug in nommu.c and then we can see wha=
t
>>>> caused the problem.
>>>
>>> Yep, with debug on:
>>>
>>> =C3=83=C2=A1...
>>> =C3=83=C2=A1VFS: Mounted root (romfs filesystem) readonly on device 31:=
0.
>>> =C3=83=C2=A1Freeing unused kernel memory: 52k freed (0x4018c000 - 0x401=
98000)
>>> =C3=83=C2=A1=3D=3D> =C2=A0do_mmap_pgoff(,0,6780,5,1002,0)
>>> =C3=83=C2=A1<=3D=3D do_mmap_pgoff() =3D -22
>>> =C3=83=C2=A1Unable to mmap process text, errno 22
>>>
>>
>> Since I can't reproduce this problem, could you please attach the
>> whole dmesg log with nommu debug on or
>> you can step into to see why errno 22 is returned, is it returned by
>> do_mmap_private()?
>
> There was no other debug messages with debug turned on in nommu.c.
> (I can give you the boot msgs before this if you want, but there
> was no nommu.c debug in it).
>
> But I did trace it into do_mmap_pgoff() to see what was failing.
> It fails based on the return value from:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0addr =3D file->f_op->get_unmapped_area(=
file, addr, len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgoff, flags);
>

Thanks for this information.
But it's a callback function. I still can't know what's the problem maybe.
Would you do me a favor to do more trace to see where it callback to,
fs or some driver etc..?

>
> Theres only one call of this inside do_mmap_pgoff() so you its
> easy to find.
>
> Regards
> Greg
>
>
>
>>> I can confirm that the PAGE_ALIGN(len) change in do_mmap_pgoff()
>>> is enough to cause this too.
>>>
>>> Regards
>>> Greg
>>>
>>>
>>>
>>>
>>>>> I haven't really debugged it any further yet. But that error message
>>>>> comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.
>>>>>
>>>>> Reverting that this patch and no more problem.
>>>>>
>>>>> Regards
>>>>> Greg
>>>>>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
