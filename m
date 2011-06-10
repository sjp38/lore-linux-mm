Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3FD846B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 23:52:05 -0400 (EDT)
Message-ID: <4DF194A6.3020606@snapgear.com>
Date: Fri, 10 Jun 2011 13:51:02 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] nommu: add page_align to mmap
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>	<4DE88112.3090908@snapgear.com>	<BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>	<4DEEFEEB.3090103@snapgear.com>	<BANLkTi=8G6Z5RpvK6wDuzdF-0t7wDwnTOA@mail.gmail.com>	<4DEF4CC5.7040403@snapgear.com> <BANLkTi=AJ=0pFx2OXENZF4p4gh7V2RXmXw@mail.gmail.com>
In-Reply-To: <BANLkTi=AJ=0pFx2OXENZF4p4gh7V2RXmXw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

Hi Bob,

On 09/06/11 20:30, Bob Liu wrote:
> On Wed, Jun 8, 2011 at 6:19 PM, Greg Ungerer<gerg@snapgear.com>  wrote:
>>>>>> When booting on a ColdFire (m68knommu) target the init process (or
>>>>>> there abouts at least) fails. Last console messages are:
>>>>>>
>>>>>> ...
>>>>>> VFS: Mounted root (romfs filesystem) readonly on device 31:0.
>>>>>> Freeing unused kernel memory: 52k freed (0x401aa000 - 0x401b6000)
>>>>>> Unable to mmap process text, errno 22
>>>>>>
>>>>>
>>>>> Oh, bad news. I will try to reproduce it on my board.
>>>>> If you are free please enable debug in nommu.c and then we can see wh=
at
>>>>> caused the problem.
>>>>
>>>> Yep, with debug on:
>>>>
>>>> =AD...
>>>> VFS: Mounted root (romfs filesystem) readonly on device 31:0.
>>>> Freeing unused kernel memory: 52k freed (0x4018c000 - 0x40198000)
>>>> =3D=3D>  =C3=A1do_mmap_pgoff(,0,6780,5,1002,0)
>>>> <=3D=3D do_mmap_pgoff() =3D -22
>>>> Unable to mmap process text, errno 22
>>>>
>>>
>>> Since I can't reproduce this problem, could you please attach the
>>> whole dmesg log with nommu debug on or
>>> you can step into to see why errno 22 is returned, is it returned by
>>> do_mmap_private()?
>>
>> There was no other debug messages with debug turned on in nommu.c.
>> (I can give you the boot msgs before this if you want, but there
>> was no nommu.c debug in it).
>>
>> But I did trace it into do_mmap_pgoff() to see what was failing.
>> It fails based on the return value from:
>>
>> addr =3D file->f_op->get_unmapped_area(file, addr, len,
>>                                            =A1pgoff, flags);
>>
>
> Thanks for this information.
> But it's a callback function. I still can't know what's the problem maybe=
.
> Would you do me a favor to do more trace to see where it callback to,
> fs or some driver etc..?

Its calling to romfs_get_unmapped_area() [fs/romfs/mmap-nommu.c]. It is
being called with:

   romfs_get_unmapped_area(addr=3D0,len=3D7000,pgoff=3D0,flags=3D1002)

This is failing the first size check because isize comes back
as 0x6ca8, and this is smaller then len (0x7000). Thus returning
-EINVAL.

That code is trying to map the contents of the file /bin/init
directly from the romfs filesystem (which is in RAM). The init
binary is 0x6ca8 bytes in size (that is the isize above).

Regards
Greg


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
