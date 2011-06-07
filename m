Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 36C7F6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 02:19:46 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2764133qwa.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 23:19:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DE88112.3090908@snapgear.com>
References: <1304661784-11654-1-git-send-email-lliubbo@gmail.com>
	<4DE88112.3090908@snapgear.com>
Date: Tue, 7 Jun 2011 14:19:23 +0800
Message-ID: <BANLkTikv5cuRRW+7LPX-=kSdSy=n+O3=Jg@mail.gmail.com>
Subject: Re: [PATCH v2] nommu: add page_align to mmap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@snapgear.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, geert@linux-m68k.org, uclinux-dist-devel@blackfin.uclinux.org

On Fri, Jun 3, 2011 at 2:37 PM, Greg Ungerer <gerg@snapgear.com> wrote:
> Hi Bob,
>
> On 06/05/11 16:03, Bob Liu wrote:
>>
>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do
>> page_align()
>> which isn't consist with mmu arch and cause some issues.
>>
>> First, some drivers' mmap() function depends on vma->vm_end - vma->start
>> is
>> page aligned which is true on mmu arch but not on nommu. eg: uvc camera
>> driver.
>>
>> Second munmap() may return -EINVAL[split file] error in cases when end i=
s
>> not
>> page aligned(passed into from userspace) but vma->vm_end is aligned dure
>> to
>> split or driver's mmap() ops.
>>
>> This patch add page align to fix those issues.
>
> This is actually causing me problems on head at the moment.
> git bisected to this patch as the cause.
>
> When booting on a ColdFire (m68knommu) target the init process (or
> there abouts at least) fails. Last console messages are:
>
> =C2=A0...
> =C2=A0VFS: Mounted root (romfs filesystem) readonly on device 31:0.
> =C2=A0Freeing unused kernel memory: 52k freed (0x401aa000 - 0x401b6000)
> =C2=A0Unable to mmap process text, errno 22
>

Oh, bad news. I will try to reproduce it on my board.
If you are free please enable debug in nommu.c and then we can see what
caused the problem.

Thanks!

> I haven't really debugged it any further yet. But that error message
> comes from fs/binfmt_flat.c, it is reporting a failed do_mmap() call.
>
> Reverting that this patch and no more problem.
>
> Regards
> Greg
>
>
>
>> Changelog v1->v2:
>> - added more commit message
>>
>> Signed-off-by: Bob Liu<lliubbo@gmail.com>
>> ---
>> =C2=A0mm/nommu.c | =C2=A0 24 ++++++++++++++----------
>> =C2=A01 files changed, 14 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/nommu.c b/mm/nommu.c
>> index c4c542c..3febfd9 100644
>> --- a/mm/nommu.c
>> +++ b/mm/nommu.c
>> @@ -1133,7 +1133,7 @@ static int do_mmap_private(struct vm_area_struct
>> *vma,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 unsigned long capabilities)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *pages;
>> - =C2=A0 =C2=A0 =C2=A0 unsigned long total, point, n, rlen;
>> + =C2=A0 =C2=A0 =C2=A0 unsigned long total, point, n;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0void *base;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret, order;
>>
>> @@ -1157,13 +1157,12 @@ static int do_mmap_private(struct vm_area_struct
>> *vma,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * make a private=
 copy of the data and map that instead */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> - =C2=A0 =C2=A0 =C2=A0 rlen =3D PAGE_ALIGN(len);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* allocate some memory to hold the mapping
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * - note that this may not return a page-ali=
gned address if the
>> object
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * =C2=A0 we're allocating is smaller than a =
page
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> - =C2=A0 =C2=A0 =C2=A0 order =3D get_order(rlen);
>> + =C2=A0 =C2=A0 =C2=A0 order =3D get_order(len);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0kdebug("alloc order %d for %lx", order, len);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0pages =3D alloc_pages(GFP_KERNEL, order);
>> @@ -1173,7 +1172,7 @@ static int do_mmap_private(struct vm_area_struct
>> *vma,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0total =3D 1<< =C2=A0order;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_long_add(total,&mmap_pages_allocated);
>>
>> - =C2=A0 =C2=A0 =C2=A0 point =3D rlen>> =C2=A0PAGE_SHIFT;
>> + =C2=A0 =C2=A0 =C2=A0 point =3D len>> =C2=A0PAGE_SHIFT;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* we allocated a power-of-2 sized page set, =
so we may want to trim
>> off
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * the excess */
>> @@ -1195,7 +1194,7 @@ static int do_mmap_private(struct vm_area_struct
>> *vma,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0base =3D page_address(pages);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0region->vm_flags =3D vma->vm_flags |=3D VM_MA=
PPED_COPY;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0region->vm_start =3D (unsigned long) base;
>> - =C2=A0 =C2=A0 =C2=A0 region->vm_end =C2=A0 =3D region->vm_start + rlen=
;
>> + =C2=A0 =C2=A0 =C2=A0 region->vm_end =C2=A0 =3D region->vm_start + len;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0region->vm_top =C2=A0 =3D region->vm_start + =
(total<< =C2=A0PAGE_SHIFT);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0vma->vm_start =3D region->vm_start;
>> @@ -1211,15 +1210,15 @@ static int do_mmap_private(struct vm_area_struct
>> *vma,
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0old_fs =3D get_fs=
();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_fs(KERNEL_DS)=
;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D vma->vm_file-=
>f_op->read(vma->vm_file, base,
>> rlen,&fpos);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D vma->vm_file-=
>f_op->read(vma->vm_file, base,
>> len,&fpos);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_fs(old_fs);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret< =C2=A00)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0goto error_free;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* clear the last=
 little bit */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret< =C2=A0rlen)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 memset(base + ret, 0, rlen - ret);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret< =C2=A0len)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 memset(base + ret, 0, len - ret);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> @@ -1268,6 +1267,7 @@ unsigned long do_mmap_pgoff(struct file *file,
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* we ignore the address hint */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0addr =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 len =3D PAGE_ALIGN(len);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* we've determined that we can make the mapp=
ing, now translate
>> what we
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * now know into VMA flags */
>> @@ -1645,14 +1645,16 @@ int do_munmap(struct mm_struct *mm, unsigned lon=
g
>> start, size_t len)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rb_node *rb;
>> - =C2=A0 =C2=A0 =C2=A0 unsigned long end =3D start + len;
>> + =C2=A0 =C2=A0 =C2=A0 unsigned long end;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0kenter(",%lx,%zx", start, len);
>>
>> - =C2=A0 =C2=A0 =C2=A0 if (len =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 if ((len =3D PAGE_ALIGN(len)) =3D=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;
>>
>> + =C2=A0 =C2=A0 =C2=A0 end =3D start + len;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* find the first potentially overlapping VMA=
 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0vma =3D find_vma(mm, start);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!vma) {
>> @@ -1773,6 +1775,8 @@ unsigned long do_mremap(unsigned long addr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* insanity checks first */
>> + =C2=A0 =C2=A0 =C2=A0 old_len =3D PAGE_ALIGN(old_len);
>> + =C2=A0 =C2=A0 =C2=A0 new_len =3D PAGE_ALIGN(new_len);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (old_len =3D=3D 0 || new_len =3D=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return (unsigned =
long) -EINVAL;
>>
>
>
> --
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
