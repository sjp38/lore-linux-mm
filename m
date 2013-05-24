Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B0E376B0034
	for <linux-mm@kvack.org>; Fri, 24 May 2013 05:02:33 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hj6so1343028wib.5
        for <linux-mm@kvack.org>; Fri, 24 May 2013 02:02:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
	<20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
Date: Fri, 24 May 2013 13:02:30 +0400
Message-ID: <CAJGZr0LwivLTH+E7WAR1B9_6B4e=jv04KgCUL_PdVpi9JjDpBw@mail.gmail.com>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
From: Maxim Uvarov <muvarov@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f234ce515854f04dd730f9a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, jingbai.ma@hp.com, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, "Eric W. Biederman" <ebiederm@xmission.com>, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, walken@google.com, Cliff Wickman <cpw@sgi.com>, Vivek Goyal <vgoyal@redhat.com>

--e89a8f234ce515854f04dd730f9a
Content-Type: text/plain; charset=ISO-8859-1

2013/5/24 Andrew Morton <akpm@linux-foundation.org>

> On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <
> d.hatayama@jp.fujitsu.com> wrote:
>
> > This patch introduces mmap_vmcore().
> >
> > Don't permit writable nor executable mapping even with mprotect()
> > because this mmap() is aimed at reading crash dump memory.
> > Non-writable mapping is also requirement of remap_pfn_range() when
> > mapping linear pages on non-consecutive physical pages; see
> > is_cow_mapping().
> >
> > Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by
> > remap_vmalloc_range_pertial at the same time for a single
> > vma. do_munmap() can correctly clean partially remapped vma with two
> > functions in abnormal case. See zap_pte_range(), vm_normal_page() and
> > their comments for details.
> >
> > On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This
> > limitation comes from the fact that the third argument of
> > remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned long.
>
> More reviewing and testing, please.
>
>
Do you have git pull for both kernel and userland changes? I would like to
do some more testing on my machines.

Maxim.


>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: vmcore-support-mmap-on-proc-vmcore-fix
>
> use min(), switch to conventional error-unwinding approach
>
> Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
> Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Lisa Mitchell <lisa.mitchell@hp.com>
> Cc: Vivek Goyal <vgoyal@redhat.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  fs/proc/vmcore.c |   27 ++++++++++-----------------
>  1 file changed, 10 insertions(+), 17 deletions(-)
>
> diff -puN fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix
> fs/proc/vmcore.c
> --- a/fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix
> +++ a/fs/proc/vmcore.c
> @@ -218,9 +218,7 @@ static int mmap_vmcore(struct file *file
>         if (start < elfcorebuf_sz) {
>                 u64 pfn;
>
> -               tsz = elfcorebuf_sz - start;
> -               if (size < tsz)
> -                       tsz = size;
> +               tsz = min(elfcorebuf_sz - (size_t)start, size);
>                 pfn = __pa(elfcorebuf + start) >> PAGE_SHIFT;
>                 if (remap_pfn_range(vma, vma->vm_start, pfn, tsz,
>                                     vma->vm_page_prot))
> @@ -236,15 +234,11 @@ static int mmap_vmcore(struct file *file
>         if (start < elfcorebuf_sz + elfnotes_sz) {
>                 void *kaddr;
>
> -               tsz = elfcorebuf_sz + elfnotes_sz - start;
> -               if (size < tsz)
> -                       tsz = size;
> +               tsz = min(elfcorebuf_sz + elfnotes_sz - (size_t)start,
> size);
>                 kaddr = elfnotes_buf + start - elfcorebuf_sz;
>                 if (remap_vmalloc_range_partial(vma, vma->vm_start + len,
> -                                               kaddr, tsz)) {
> -                       do_munmap(vma->vm_mm, vma->vm_start, len);
> -                       return -EAGAIN;
> -               }
> +                                               kaddr, tsz))
> +                       goto fail;
>                 size -= tsz;
>                 start += tsz;
>                 len += tsz;
> @@ -257,16 +251,12 @@ static int mmap_vmcore(struct file *file
>                 if (start < m->offset + m->size) {
>                         u64 paddr = 0;
>
> -                       tsz = m->offset + m->size - start;
> -                       if (size < tsz)
> -                               tsz = size;
> +                       tsz = min_t(size_t, m->offset + m->size - start,
> size);
>                         paddr = m->paddr + start - m->offset;
>                         if (remap_pfn_range(vma, vma->vm_start + len,
>                                             paddr >> PAGE_SHIFT, tsz,
> -                                           vma->vm_page_prot)) {
> -                               do_munmap(vma->vm_mm, vma->vm_start, len);
> -                               return -EAGAIN;
> -                       }
> +                                           vma->vm_page_prot))
> +                               goto fail;
>                         size -= tsz;
>                         start += tsz;
>                         len += tsz;
> @@ -277,6 +267,9 @@ static int mmap_vmcore(struct file *file
>         }
>
>         return 0;
> +fail:
> +       do_munmap(vma->vm_mm, vma->vm_start, len);
> +       return -EAGAIN;
>  }
>
>  static const struct file_operations proc_vmcore_operations = {
> _
>
>
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
>



-- 
Best regards,
Maxim Uvarov

--e89a8f234ce515854f04dd730f9a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/5/24 Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akp=
m@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;=
</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On Thu, 23 May 2013 14:25:=
48 +0900 HATAYAMA Daisuke &lt;<a href=3D"mailto:d.hatayama@jp.fujitsu.com">=
d.hatayama@jp.fujitsu.com</a>&gt; wrote:<br>

<br>
&gt; This patch introduces mmap_vmcore().<br>
&gt;<br>
&gt; Don&#39;t permit writable nor executable mapping even with mprotect()<=
br>
&gt; because this mmap() is aimed at reading crash dump memory.<br>
&gt; Non-writable mapping is also requirement of remap_pfn_range() when<br>
&gt; mapping linear pages on non-consecutive physical pages; see<br>
&gt; is_cow_mapping().<br>
&gt;<br>
&gt; Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by<br>
&gt; remap_vmalloc_range_pertial at the same time for a single<br>
&gt; vma. do_munmap() can correctly clean partially remapped vma with two<b=
r>
&gt; functions in abnormal case. See zap_pte_range(), vm_normal_page() and<=
br>
&gt; their comments for details.<br>
&gt;<br>
&gt; On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This<=
br>
&gt; limitation comes from the fact that the third argument of<br>
&gt; remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned long.<=
br>
<br>
</div>More reviewing and testing, please.<br>
<br></blockquote><div><br></div><div>Do you have git pull for both kernel a=
nd userland changes? I would like to do some more testing on my machines.<b=
r><br></div><div>Maxim.<br></div><div>=A0</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">

<br>
From: Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@l=
inux-foundation.org</a>&gt;<br>
Subject: vmcore-support-mmap-on-proc-vmcore-fix<br>
<br>
use min(), switch to conventional error-unwinding approach<br>
<br>
Cc: Atsushi Kumagai &lt;<a href=3D"mailto:kumagai-atsushi@mxc.nes.nec.co.jp=
">kumagai-atsushi@mxc.nes.nec.co.jp</a>&gt;<br>
Cc: HATAYAMA Daisuke &lt;<a href=3D"mailto:d.hatayama@jp.fujitsu.com">d.hat=
ayama@jp.fujitsu.com</a>&gt;<br>
Cc: KOSAKI Motohiro &lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu.com">k=
osaki.motohiro@jp.fujitsu.com</a>&gt;<br>
Cc: Lisa Mitchell &lt;<a href=3D"mailto:lisa.mitchell@hp.com">lisa.mitchell=
@hp.com</a>&gt;<br>
Cc: Vivek Goyal &lt;<a href=3D"mailto:vgoyal@redhat.com">vgoyal@redhat.com<=
/a>&gt;<br>
Cc: Zhang Yanfei &lt;<a href=3D"mailto:zhangyanfei@cn.fujitsu.com">zhangyan=
fei@cn.fujitsu.com</a>&gt;<br>
Signed-off-by: Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.or=
g">akpm@linux-foundation.org</a>&gt;<br>
---<br>
<br>
=A0fs/proc/vmcore.c | =A0 27 ++++++++++-----------------<br>
=A01 file changed, 10 insertions(+), 17 deletions(-)<br>
<br>
diff -puN fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix fs/proc/v=
mcore.c<br>
--- a/fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix<br>
+++ a/fs/proc/vmcore.c<br>
@@ -218,9 +218,7 @@ static int mmap_vmcore(struct file *file<br>
=A0 =A0 =A0 =A0 if (start &lt; elfcorebuf_sz) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 pfn;<br>
<div class=3D"im"><br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D elfcorebuf_sz - start;<br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size &lt; tsz)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D size;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D min(elfcorebuf_sz - (size_t)start, si=
ze);<br>
<div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn =3D __pa(elfcorebuf +=
 start) &gt;&gt; PAGE_SHIFT;<br>
</div><div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (remap_pfn_range=
(vma, vma-&gt;vm_start, pfn, tsz,<br>
</div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 vma-&gt;vm_page_prot))<br>
@@ -236,15 +234,11 @@ static int mmap_vmcore(struct file *file<br>
<div class=3D"im">=A0 =A0 =A0 =A0 if (start &lt; elfcorebuf_sz + elfnotes_s=
z) {<br>
</div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *kaddr;<br>
<div class=3D"im"><br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D elfcorebuf_sz + elfnotes_sz - start;<=
br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size &lt; tsz)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D size;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D min(elfcorebuf_sz + elfnotes_sz - (si=
ze_t)start, size);<br>
<div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kaddr =3D elfnotes_buf + =
start - elfcorebuf_sz;<br>
</div><div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (remap_vmalloc_r=
ange_partial(vma, vma-&gt;vm_start + len,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 kaddr, tsz)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_munmap(vma-&gt;vm_mm, vma-=
&gt;vm_start, len);<br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 kaddr, tsz))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size -=3D tsz;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start +=3D tsz;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D tsz;<br>
@@ -257,16 +251,12 @@ static int mmap_vmcore(struct file *file<br>
<div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (start &lt; m-&gt;offs=
et + m-&gt;size) {<br>
</div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 paddr =3D 0;<br>
<div class=3D"im"><br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D m-&gt;offset + m-&gt;=
size - start;<br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size &lt; tsz)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D size;=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsz =3D min_t(size_t, m-&gt;o=
ffset + m-&gt;size - start, size);<br>
<div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 paddr =3D=
 m-&gt;paddr + start - m-&gt;offset;<br>
</div><div class=3D"im">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if =
(remap_pfn_range(vma, vma-&gt;vm_start + len,<br>
</div>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 paddr &gt;&gt; PAGE_SHIFT, tsz,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 vma-&gt;vm_page_prot)) {<br>
<div class=3D"im">- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 do_munmap(vma-&gt;vm_mm, vma-&gt;vm_start, len);<br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EAGAIN;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 vma-&gt;vm_page_prot))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br=
>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size -=3D tsz;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start +=3D tsz;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D tsz;<br>
@@ -277,6 +267,9 @@ static int mmap_vmcore(struct file *file<br>
=A0 =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 return 0;<br>
+fail:<br>
<div class=3D"im HOEnZb">+ =A0 =A0 =A0 do_munmap(vma-&gt;vm_mm, vma-&gt;vm_=
start, len);<br>
+ =A0 =A0 =A0 return -EAGAIN;<br>
=A0}<br>
<br>
</div><div class=3D"im HOEnZb">=A0static const struct file_operations proc_=
vmcore_operations =3D {<br>
</div><div class=3D"HOEnZb"><div class=3D"h5">_<br>
<br>
<br>
_______________________________________________<br>
kexec mailing list<br>
<a href=3D"mailto:kexec@lists.infradead.org">kexec@lists.infradead.org</a><=
br>
<a href=3D"http://lists.infradead.org/mailman/listinfo/kexec" target=3D"_bl=
ank">http://lists.infradead.org/mailman/listinfo/kexec</a><br>
</div></div></blockquote></div><br><br clear=3D"all"><br>-- <br>Best regard=
s,<br>Maxim Uvarov
</div></div>

--e89a8f234ce515854f04dd730f9a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
