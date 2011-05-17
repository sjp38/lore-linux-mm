Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB3E6B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:00:42 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4HK0LoM019108
	for <linux-mm@kvack.org>; Tue, 17 May 2011 13:00:22 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by hpaq3.eem.corp.google.com with ESMTP id p4HJxNjd000434
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 13:00:20 -0700
Received: by qwk3 with SMTP id 3so447694qwk.19
        for <linux-mm@kvack.org>; Tue, 17 May 2011 13:00:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
Date: Tue, 17 May 2011 13:00:14 -0700
Message-ID: <BANLkTinQR2BSdyPfgTaY3my4W28czuWqpg@mail.gmail.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem fix
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c6d6ab404a37e389b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

--0016360e3f5c6d6ab404a37e389b
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 17, 2011 at 11:24 AM, Hugh Dickins <hughd@google.com> wrote:

> mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> target mm, not for current mm (but of course they're usually the same).
>
> We don't know the target mm in shmem_getpage(), so do it at the outer
> level in shmem_fault(); and it's easier to follow if we move the
> count_vm_event(PGMAJFAULT) there too.
>
> Hah, it was using __count_vm_event() before, sneaking that update into
> the unpreemptible section under info->lock: well, it comes to the same
> on x86 at least, and I still think it's best to keep these together.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
>  mm/shmem.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
>
> --- mmotm/mm/shmem.c    2011-05-13 14:57:45.367884578 -0700
> +++ linux/mm/shmem.c    2011-05-17 10:27:19.901934756 -0700
> @@ -1293,14 +1293,10 @@ repeat:
>                swappage = lookup_swap_cache(swap);
>                if (!swappage) {
>                        shmem_swp_unmap(entry);
> +                       spin_unlock(&info->lock);
>                        /* here we actually do the io */
> -                       if (type && !(*type & VM_FAULT_MAJOR)) {
> -                               __count_vm_event(PGMAJFAULT);
> -                               mem_cgroup_count_vm_event(current->mm,
> -                                                         PGMAJFAULT);
> +                       if (type)
>                                *type |= VM_FAULT_MAJOR;
> -                       }
> -                       spin_unlock(&info->lock);
>                        swappage = shmem_swapin(swap, gfp, info, idx);
>                        if (!swappage) {
>                                spin_lock(&info->lock);
> @@ -1539,7 +1535,10 @@ static int shmem_fault(struct vm_area_st
>        error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE,
> &ret);
>        if (error)
>                return ((error == -ENOMEM) ? VM_FAULT_OOM :
> VM_FAULT_SIGBUS);
> -
> +       if (ret & VM_FAULT_MAJOR) {
> +               count_vm_event(PGMAJFAULT);
> +               mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +       }
>        return ret | VM_FAULT_LOCKED;
>  }
>
> Thank you Hugh for the fix.

Acked-by: Ying Han<yinghan@google.com>

--Ying

--0016360e3f5c6d6ab404a37e389b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 17, 2011 at 11:24 AM, Hugh D=
ickins <span dir=3D"ltr">&lt;<a href=3D"mailto:hughd@google.com">hughd@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the<br>
target mm, not for current mm (but of course they&#39;re usually the same).=
<br>
<br>
We don&#39;t know the target mm in shmem_getpage(), so do it at the outer<b=
r>
level in shmem_fault(); and it&#39;s easier to follow if we move the<br>
count_vm_event(PGMAJFAULT) there too.<br>
<br>
Hah, it was using __count_vm_event() before, sneaking that update into<br>
the unpreemptible section under info-&gt;lock: well, it comes to the same<b=
r>
on x86 at least, and I still think it&#39;s best to keep these together.<br=
>
<br>
Signed-off-by: Hugh Dickins &lt;<a href=3D"mailto:hughd@google.com">hughd@g=
oogle.com</a>&gt;<br>
---<br>
<br>
=A0mm/shmem.c | =A0 13 ++++++-------<br>
=A01 file changed, 6 insertions(+), 7 deletions(-)<br>
<br>
--- mmotm/mm/shmem.c =A0 =A02011-05-13 14:57:45.367884578 -0700<br>
+++ linux/mm/shmem.c =A0 =A02011-05-17 10:27:19.901934756 -0700<br>
@@ -1293,14 +1293,10 @@ repeat:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swappage =3D lookup_swap_cache(swap);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!swappage) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shmem_swp_unmap(entry);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;info-&gt;loc=
k);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* here we actually do the =
io */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (type &amp;&amp; !(*type &=
amp; VM_FAULT_MAJOR)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_ev=
ent(PGMAJFAULT);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_co=
unt_vm_event(current-&gt;mm,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PGMAJFAULT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (type)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*type |=3D =
VM_FAULT_MAJOR;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;info-&gt;loc=
k);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swappage =3D shmem_swapin(s=
wap, gfp, info, idx);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!swappage) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&=
amp;info-&gt;lock);<br>
@@ -1539,7 +1535,10 @@ static int shmem_fault(struct vm_area_st<br>
 =A0 =A0 =A0 =A0error =3D shmem_getpage(inode, vmf-&gt;pgoff, &amp;vmf-&gt;=
page, SGP_CACHE, &amp;ret);<br>
 =A0 =A0 =A0 =A0if (error)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ((error =3D=3D -ENOMEM) ? VM_FAULT_O=
OM : VM_FAULT_SIGBUS);<br>
-<br>
+ =A0 =A0 =A0 if (ret &amp; VM_FAULT_MAJOR) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(PGMAJFAULT);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_count_vm_event(vma-&gt;vm_mm, PGMA=
JFAULT);<br>
+ =A0 =A0 =A0 }<br>
 =A0 =A0 =A0 =A0return ret | VM_FAULT_LOCKED;<br>
=A0}<br>
<br></blockquote><div>Thank you Hugh for the fix.</div><div>=A0</div></div>=
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><s=
pan class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-fam=
ily: arial, sans-serif; font-size: 13px; ">Acked-by: Ying Han&lt;<a href=3D=
"mailto:yinghan@google.com">yinghan@google.com</a>&gt;</span><div>
<span class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-f=
amily: arial, sans-serif; font-size: 13px; "><br></span></div><div><span cl=
ass=3D"Apple-style-span" style=3D"border-collapse: collapse; font-family: a=
rial, sans-serif; font-size: 13px; ">--Ying</span></div>

--0016360e3f5c6d6ab404a37e389b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
