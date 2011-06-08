Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EA4D26B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 00:54:24 -0400 (EDT)
Message-ID: <4DEEFEEB.3090103@snapgear.com>
Date: Wed, 8 Jun 2011 14:47:39 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] nommu: add page_align to mmap
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>	<4DE88112.3090908@snapgear.com> <BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>
In-Reply-To: <BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

Hi Bob,

On 07/06/11 16:19, Bob Liu wrote:
> On Fri, Jun 3, 2011 at 2:37 PM, Greg Ungerer<gerg@snapgear.com>  wrote:
>> Hi Bob,
>>
>> On 06/05/11 16:03, Bob Liu wrote:
>>>
>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>> page_align()
>>> which isn't consist with mmu arch and cause some issues.
>>>
>>> First, some drivers' mmap() function depends on vma->vm_end - vma->star=
t
>>> is
>>> page aligned which is true on mmu arch but not on nommu. eg: uvc camera
>>> driver.
>>>
>>> Second munmap() may return -EINVAL[split file] error in cases when end =
is
>>> not
>>> page aligned(passed into from userspace) but vma->vm_end is aligned dur=
e
>>> to
>>> split or driver's mmap() ops.
>>>
>>> This patch add page align to fix those issues.
>>
>> This is actually causing me problems on head at the moment.
>> git bisected to this patch as the cause.
>>
>> When booting on a ColdFire (m68knommu) target the init process (or
>> there abouts at least) fails. Last console messages are:
>>
>> =C3=A1...
>> =C3=A1VFS: Mounted root (romfs filesystem) readonly on device 31:0.
>> =C3=A1Freeing unused kernel memory: 52k freed (0x401aa000 - 0x401b6000)
>> =C3=A1Unable to mmap process text, errno 22
>>
>
> Oh, bad news. I will try to reproduce it on my board.
> If you are free please enable debug in nommu.c and then we can see what
> caused the problem.

Yep, with debug on:

   ...
   VFS: Mounted root (romfs filesystem) readonly on device 31:0.
   Freeing unused kernel memory: 52k freed (0x4018c000 - 0x40198000)
   =3D=3D> do_mmap_pgoff(,0,6780,5,1002,0)
   <=3D=3D do_mmap_pgoff() =3D -22
   Unable to mmap process text, errno 22

I can confirm that the PAGE_ALIGN(len) change in do_mmap_pgoff()
is enough to cause this too.

Regards
Greg




>> I haven't really debugged it any further yet. But that error message
>> comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.
>>
>> Reverting that this patch and no more problem.
>>
>> Regards
>> Greg
>>

------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
