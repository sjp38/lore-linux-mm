Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A0C826B0025
	for <linux-mm@kvack.org>; Thu,  5 May 2011 20:33:36 -0400 (EDT)
Message-ID: <4DC34185.4040106@snapgear.com>
Date: Fri, 6 May 2011 10:32:05 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH] nommu: add page_align to mmap
References: <1303888334-16062-1-git-send-email-lliubbo@gmail.com>	<20110504141353.842409e1.akpm@linux-foundation.org>	<4DC1FFA5.1090207@snapgear.com> <BANLkTimB+ZnvH2BdP5m=VypDnYKNbnmZVQ@mail.gmail.com>
In-Reply-To: <BANLkTimB+ZnvH2BdP5m=VypDnYKNbnmZVQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, Geert Uytterhoeven <geert@linux-m68k.org>

Hi Bob,

On 05/05/11 20:19, Bob Liu wrote:
> On Thu, May 5, 2011 at 9:38 AM, Greg Ungerer<gerg@snapgear.com>  wrote:
>> On 05/05/11 07:13, Andrew Morton wrote:
>>>
>>> On Wed, 27 Apr 2011 15:12:14 +0800
>>> Bob Liu<lliubbo@gmail.com>  =C3=A1wrote:
>>>
>>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>>> page_align()
>>>> which is incorrect and not consist with mmu arch.
>>>> This patch fix it.
>>>>
>>>
>>> Can you explain this fully please? =C3=A1What was the user-observeable
>>> behaviour before the patch, and after?
>>>
>>> And some input from nommu maintainers would be nice.
>>
>> Its not obvious to me that there is a problem here. Are there
>> any issues caused by the current behavior that this fixes?
>>
>
> Yes, there is a issue.
>
> Some drivers'  mmap() function depend on (vma->vm_end - vma->start) is
> page aligned which is true on mmu arch but not on nommu.
> eg: uvc camera driver.
>
> What's more, sometimes I got munmap() error.
> The reason is split file: mm/nommu.c
>                     do {
> 1614                         if (start>  vma->vm_start) {
> 1615                                 kleave(" =3D -EINVAL [miss]");
> 1616                                 return -EINVAL;
> 1617                         }
> 1618                         if (end =3D=3D vma->vm_end)
> 1619                                 goto erase_whole_vma;
>
> <<=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3Dhere
> 1620                         rb =3D rb_next(&vma->vm_rb);
> 1621                         vma =3D rb_entry(rb, struct vm_area_struct, =
vm_rb);
> 1622                 } while (rb);
> 1623                 kleave(" =3D -EINVAL [split file]");
>
> Because end is not page aligned (passed into from userspace) while
> some unknown reason
> vma->vm_end is aligned,  this loop will fail and -EINVAL[split file]
> error returned.
> But it's hard to reproduce.
>
> And in my opinion consist with mmu alway a better choice.
>
> Thanks for your review.

Ok, makes sense. Can you add some of this writeup to the patch
commit message?

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
