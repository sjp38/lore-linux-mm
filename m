Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 660766B0011
	for <linux-mm@kvack.org>; Thu,  5 May 2011 06:19:58 -0400 (EDT)
Received: by qyk2 with SMTP id 2so4074308qyk.14
        for <linux-mm@kvack.org>; Thu, 05 May 2011 03:19:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DC1FFA5.1090207@snapgear.com>
References: <1303888334-16062-1-git-send-email-lliubbo@gmail.com>
	<20110504141353.842409e1.akpm@linux-foundation.org>
	<4DC1FFA5.1090207@snapgear.com>
Date: Thu, 5 May 2011 18:19:56 +0800
Message-ID: <BANLkTimB+ZnvH2BdP5m=VypDnYKNbnmZVQ@mail.gmail.com>
Subject: Re: [PATCH] nommu: add page_align to mmap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@snapgear.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, May 5, 2011 at 9:38 AM, Greg Ungerer <gerg@snapgear.com> wrote:
> On 05/05/11 07:13, Andrew Morton wrote:
>>
>> On Wed, 27 Apr 2011 15:12:14 +0800
>> Bob Liu<lliubbo@gmail.com> =C2=A0wrote:
>>
>>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>>> page_align()
>>> which is incorrect and not consist with mmu arch.
>>> This patch fix it.
>>>
>>
>> Can you explain this fully please? =C2=A0What was the user-observeable
>> behaviour before the patch, and after?
>>
>> And some input from nommu maintainers would be nice.
>
> Its not obvious to me that there is a problem here. Are there
> any issues caused by the current behavior that this fixes?
>

Yes, there is a issue.

Some drivers'  mmap() function depend on (vma->vm_end - vma->start) is
page aligned which is true on mmu arch but not on nommu.
eg: uvc camera driver.

What's more, sometimes I got munmap() error.
The reason is split file: mm/nommu.c
                   do {
1614                         if (start > vma->vm_start) {
1615                                 kleave(" =3D -EINVAL [miss]");
1616                                 return -EINVAL;
1617                         }
1618                         if (end =3D=3D vma->vm_end)
1619                                 goto erase_whole_vma;

<<=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3Dhere
1620                         rb =3D rb_next(&vma->vm_rb);
1621                         vma =3D rb_entry(rb, struct vm_area_struct, vm=
_rb);
1622                 } while (rb);
1623                 kleave(" =3D -EINVAL [split file]");

Because end is not page aligned (passed into from userspace) while
some unknown reason
vma->vm_end is aligned,  this loop will fail and -EINVAL[split file]
error returned.
But it's hard to reproduce.

And in my opinion consist with mmu alway a better choice.

Thanks for your review.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
