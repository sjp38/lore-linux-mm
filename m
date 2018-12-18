Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9878E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 00:28:12 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id w80so748366oiw.19
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 21:28:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s49sor3025309otb.113.2018.12.17.21.28.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 21:28:11 -0800 (PST)
MIME-Version: 1.0
References: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com> <20181217233821-mutt-send-email-mst@kernel.org>
In-Reply-To: <20181217233821-mutt-send-email-mst@kernel.org>
From: gchen chen <gchen.guomin@gmail.com>
Date: Tue, 18 Dec 2018 13:27:59 +0800
Message-ID: <CAEEwsfS05aL=mQ9-YRYH48yOUeM4KZp+K1cXu81PHdN34irpWQ@mail.gmail.com>
Subject: Re: [PATCH] Export mm_update_next_owner function for unuse_mm.
Content-Type: multipart/alternative; boundary="000000000000c86fde057d452939"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, gchen <guominchen@tencent.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--000000000000c86fde057d452939
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Sorry,It does not need to be exported.
I have modified this patch and re-commit it.
Thank you very much for reminding.

thanks

Michael S. Tsirkin <mst@redhat.com> =E4=BA=8E2018=E5=B9=B412=E6=9C=8818=E6=
=97=A5=E5=91=A8=E4=BA=8C =E4=B8=8B=E5=8D=8812:38=E5=86=99=E9=81=93=EF=BC=9A

On Tue, Dec 18, 2018 at 11:42:11AM +0800, gchen.guomin@gmail.com wrote:
> From: guomin chen <gchen.guomin@gmail.com>
>
> When mm->owner is modified by exit_mm, if the new owner directly calls
> unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
> directly sets tsk->mm=3DNULL.
>
>  Under normal circumstances,When do_exit exits, mm->owner will
>  be updated on exit_mm(). but when the kernel process calls
>  unuse_mm() and then exits,mm->owner cannot be updated. And it
>  will point to a task that has been released.
>
> The current issue flow is as follows:
> Process C              Process A         Process B
> qemu-system-x86_64:     kernel:vhost_net  kernel: vhost_net
> open /dev/vhost-net
>   VHOST_SET_OWNER   create kthread vhost-%d  create kthread vhost-%d
>   network init           use_mm()          use_mm()
>    ...                   ...
>    Abnormal exited
>    ...
>   do_exit
>   exit_mm()
>   update mm->owner to A
>   exit_files()
>    close_files()
>    kthread_should_stop() unuse_mm()
>     Stop Process A       tsk->mm=3DNULL
>                          do_exit()
>                          can't update owner
>                          A exit completed  vhost-%d  rcv first package
>                                            vhost-%d build rcv buffer for
vq
>                                            page fault
>                                            access mm & mm->owner
>                                            NOW,mm->owner still pointer A
>                                            kernel UAF
>     stop Process B
>
> Although I am having this issue on vhost_net,But it affects all users of
> unuse_mm.
>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: guomin chen <gchen.guomin@gmail.com>
> ---
>  kernel/exit.c    | 1 +
>  mm/mmu_context.c | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 0e21e6d..9e046dd 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -486,6 +486,7 @@ void mm_update_next_owner(struct mm_struct *mm)
>       task_unlock(c);
>       put_task_struct(c);
>  }
> +EXPORT_SYMBOL(mm_update_next_owner);
>  #endif /* CONFIG_MEMCG */
>
>  /*

So why export it? Is that still needed?

> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3e612ae..9eb81aa 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)
>       /* active_mm is still 'mm' */
>       enter_lazy_tlb(mm, tsk);
>       task_unlock(tsk);
> +     mm_update_next_owner(mm);
>  }
>  EXPORT_SYMBOL_GPL(unuse_mm);
> --
> 1.8.3.1

--000000000000c86fde057d452939
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div di=
r=3D"ltr"><div dir=3D"ltr">Sorry,It does not need to be exported.</div><div=
 dir=3D"ltr">I have modified this patch and re-commit it.</div><div dir=3D"=
ltr">Thank you very much for reminding.</div><div><br></div><div>thanks</di=
v></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">Michael S. Tsirkin =
&lt;<a href=3D"mailto:mst@redhat.com">mst@redhat.com</a>&gt; =E4=BA=8E2018=
=E5=B9=B412=E6=9C=8818=E6=97=A5=E5=91=A8=E4=BA=8C =E4=B8=8B=E5=8D=8812:38=
=E5=86=99=E9=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_quote gmail=
-__reader_view_article_wrap_18896830934744213__" style=3D"margin:0px 0px 0p=
x 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Tue, De=
c 18, 2018 at 11:42:11AM +0800, <a href=3D"mailto:gchen.guomin@gmail.com" t=
arget=3D"_blank">gchen.guomin@gmail.com</a> wrote:<br>
&gt; From: guomin chen &lt;<a href=3D"mailto:gchen.guomin@gmail.com" target=
=3D"_blank">gchen.guomin@gmail.com</a>&gt;<br>
&gt; <br>
&gt; When mm-&gt;owner is modified by exit_mm, if the new owner directly ca=
lls<br>
&gt; unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()<=
br>
&gt; directly sets tsk-&gt;mm=3DNULL.<br>
&gt; <br>
&gt;=C2=A0 Under normal circumstances,When do_exit exits, mm-&gt;owner will=
<br>
&gt;=C2=A0 be updated on exit_mm(). but when the kernel process calls<br>
&gt;=C2=A0 unuse_mm() and then exits,mm-&gt;owner cannot be updated. And it=
<br>
&gt;=C2=A0 will point to a task that has been released.<br>
&gt; <br>
&gt; The current issue flow is as follows:<br>
&gt; Process C=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Process A=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Process B<br>
&gt; qemu-system-x86_64:=C2=A0 =C2=A0 =C2=A0kernel:vhost_net=C2=A0 kernel: =
vhost_net<br>
&gt; open /dev/vhost-net<br>
&gt;=C2=A0 =C2=A0VHOST_SET_OWNER=C2=A0 =C2=A0create kthread vhost-%d=C2=A0 =
create kthread vhost-%d<br>
&gt;=C2=A0 =C2=A0network init=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0use_m=
m()=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 use_mm()<br>
&gt;=C2=A0 =C2=A0 ...=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0...<br>
&gt;=C2=A0 =C2=A0 Abnormal exited<br>
&gt;=C2=A0 =C2=A0 ...<br>
&gt;=C2=A0 =C2=A0do_exit<br>
&gt;=C2=A0 =C2=A0exit_mm()<br>
&gt;=C2=A0 =C2=A0update mm-&gt;owner to A<br>
&gt;=C2=A0 =C2=A0exit_files()<br>
&gt;=C2=A0 =C2=A0 close_files()<br>
&gt;=C2=A0 =C2=A0 kthread_should_stop() unuse_mm()<br>
&gt;=C2=A0 =C2=A0 =C2=A0Stop Process A=C2=A0 =C2=A0 =C2=A0 =C2=A0tsk-&gt;mm=
=3DNULL<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 do_exit()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 can&#39;t update owner<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 A exit completed=C2=A0 vhost-%d=C2=A0 rcv first packag=
e<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 vhost-%d build rcv buffer for vq<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 page fault<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 access mm &amp; mm-&gt;owner<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 NOW,mm-&gt;owner still pointer A<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 kernel UAF<br>
&gt;=C2=A0 =C2=A0 =C2=A0stop Process B<br>
&gt; <br>
&gt; Although I am having this issue on vhost_net,But it affects all users =
of<br>
&gt; unuse_mm.<br>
&gt; <br>
&gt; Cc: &quot;Eric W. Biederman&quot; &lt;<a href=3D"mailto:ebiederm@xmiss=
ion.com" target=3D"_blank">ebiederm@xmission.com</a>&gt;<br>
&gt; Cc: Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org" tar=
get=3D"_blank">akpm@linux-foundation.org</a>&gt;<br>
&gt; Cc: &quot;Luis R. Rodriguez&quot; &lt;<a href=3D"mailto:mcgrof@kernel.=
org" target=3D"_blank">mcgrof@kernel.org</a>&gt;<br>
&gt; Cc: Dominik Brodowski &lt;<a href=3D"mailto:linux@dominikbrodowski.net=
" target=3D"_blank">linux@dominikbrodowski.net</a>&gt;<br>
&gt; Cc: Arnd Bergmann &lt;<a href=3D"mailto:arnd@arndb.de" target=3D"_blan=
k">arnd@arndb.de</a>&gt;<br>
&gt; Cc: <a href=3D"mailto:linux-kernel@vger.kernel.org" target=3D"_blank">=
linux-kernel@vger.kernel.org</a><br>
&gt; Cc: <a href=3D"mailto:linux-mm@kvack.org" target=3D"_blank">linux-mm@k=
vack.org</a><br>
&gt; Cc: &quot;Michael S. Tsirkin&quot; &lt;<a href=3D"mailto:mst@redhat.co=
m" target=3D"_blank">mst@redhat.com</a>&gt;<br>
&gt; Cc: Jason Wang &lt;<a href=3D"mailto:jasowang@redhat.com" target=3D"_b=
lank">jasowang@redhat.com</a>&gt;<br>
&gt; Cc: Christoph Hellwig &lt;<a href=3D"mailto:hch@infradead.org" target=
=3D"_blank">hch@infradead.org</a>&gt;<br>
&gt; Signed-off-by: guomin chen &lt;<a href=3D"mailto:gchen.guomin@gmail.co=
m" target=3D"_blank">gchen.guomin@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 kernel/exit.c=C2=A0 =C2=A0 | 1 +<br>
&gt;=C2=A0 mm/mmu_context.c | 1 +<br>
&gt;=C2=A0 2 files changed, 2 insertions(+)<br>
&gt; <br>
&gt; diff --git a/kernel/exit.c b/kernel/exit.c<br>
&gt; index 0e21e6d..9e046dd 100644<br>
&gt; --- a/kernel/exit.c<br>
&gt; +++ b/kernel/exit.c<br>
&gt; @@ -486,6 +486,7 @@ void mm_update_next_owner(struct mm_struct *mm)<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(c);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0put_task_struct(c);<br>
&gt;=C2=A0 }<br>
&gt; +EXPORT_SYMBOL(mm_update_next_owner);<br>
&gt;=C2=A0 #endif /* CONFIG_MEMCG */<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 /*<br>
<br>
So why export it? Is that still needed?<br>
<br>
&gt; diff --git a/mm/mmu_context.c b/mm/mmu_context.c<br>
&gt; index 3e612ae..9eb81aa 100644<br>
&gt; --- a/mm/mmu_context.c<br>
&gt; +++ b/mm/mmu_context.c<br>
&gt; @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* active_mm is still &#39;mm&#39; */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0enter_lazy_tlb(mm, tsk);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(tsk);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0mm_update_next_owner(mm);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL_GPL(unuse_mm);<br>
&gt; -- <br>
&gt; 1.8.3.1<br>
</blockquote></div></div></div></div></div>

--000000000000c86fde057d452939--
