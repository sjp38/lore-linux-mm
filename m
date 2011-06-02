Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 74A3E6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 02:19:04 -0400 (EDT)
Received: by qwa26 with SMTP id 26so319916qwa.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 23:19:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527150956.e55577c5.akpm@linux-foundation.org>
References: <1306468203-8683-1-git-send-email-lliubbo@gmail.com>
	<20110527150956.e55577c5.akpm@linux-foundation.org>
Date: Thu, 2 Jun 2011 14:19:02 +0800
Message-ID: <BANLkTikcS9VqKHqUofJKJ9GJ4cgd1tgQBQ@mail.gmail.com>
Subject: Re: [PATCH] mm: nommu: fix remap_pfn_range()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, geert@linux-m68k.org, vapier@gentoo.org, linux-mm@kvack.org

On Sat, May 28, 2011 at 6:09 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 27 May 2011 11:50:03 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> remap_pfn_range() does not update vma->end on no mmu arch which will
>> cause munmap() fail because it can't match the vma.
>>
>> eg. fb_mmap() in fbmem.c will call io_remap_pfn_range() which is
>> remap_pfn_range() on nommu arch, if an address is not page aligned vma->=
start
>> will be changed in remap_pfn_range(), but neither size nor vma->end will=
 be
>> updated. Then munmap(start, len) can't find the vma to free, because it =
need to
>> compare (start + len) with vma->end.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/nommu.c | =C2=A0 =C2=A01 +
>> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/nommu.c b/mm/nommu.c
>> index 1fd0c51..829848a 100644
>> --- a/mm/nommu.c
>> +++ b/mm/nommu.c
>> @@ -1817,6 +1817,7 @@ int remap_pfn_range(struct vm_area_struct *vma, un=
signed long from,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long to, unsig=
ned long size, pgprot_t prot)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 vma->vm_start =3D vma->vm_pgoff << PAGE_SHIFT;
>> + =C2=A0 =C2=A0 vma->vm_end =3D vma->vm_start + size;
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL(remap_pfn_range);
>
> hm.
>
> The MMU version of remap_pfn_range() doesn't do this. =C2=A0Seems that it
> just leaves the omitted parts of the vma unmapped. =C2=A0Obviously nommu
> can't do that, but the divergence is always a concern.
>
> Thsi implementation could lead to overlapping vmas. =C2=A0Should we be
> checking that it fits?
>

Hi, Andrew

Sorry for the late response and thanks for your review.
I think the overlapping vmas could exist whether this patch or not.
Maybe extra check is needed but since nobody run into that cases,
could we check it in future patches?

Thanks
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
