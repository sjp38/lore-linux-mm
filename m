Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3AF18E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:21:39 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id v184so1569286oie.6
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:21:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor9221080oti.126.2018.12.18.08.21.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 08:21:38 -0800 (PST)
MIME-Version: 1.0
References: <1545110684-8730-1-git-send-email-gchen.guomin@gmail.com> <20181218095226.GD17870@dhcp22.suse.cz>
In-Reply-To: <20181218095226.GD17870@dhcp22.suse.cz>
From: gchen chen <gchen.guomin@gmail.com>
Date: Wed, 19 Dec 2018 00:21:27 +0800
Message-ID: <CAEEwsfRb-FDCLp-b3-n2+vvgWttv6FQhjkLxpJwA==_+89iY=w@mail.gmail.com>
Subject: Re: [PATCH] Fix mm->owner point to a tsk that has been free
Content-Type: multipart/alternative; boundary="000000000000b8398d057d4e4a72"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, gchen <guominchen@tencent.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--000000000000b8398d057d4e4a72
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Oh, yes, the patch 39af176 has been skip the kthread
on mm_update_next_owner .
Thanks for your tips.

thanks and regards


Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B412=E6=9C=8818=E6=97=
=A5=E5=91=A8=E4=BA=8C =E4=B8=8B=E5=8D=885:52=E5=86=99=E9=81=93=EF=BC=9A

> On Tue 18-12-18 13:24:44, gchen.guomin@gmail.com wrote:
> > From: guomin chen <gchen.guomin@gmail.com>
> >
> > When mm->owner is modified by exit_mm, if the new owner directly calls
> > unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
> > directly sets tsk->mm=3DNULL.
> >
> >  Under normal circumstances,When do_exit exits, mm->owner will
> >  be updated on exit_mm(). but when the kernel process calls
> >  unuse_mm() and then exits,mm->owner cannot be updated. And it
> >  will point to a task that has been released.
> >
> > The current issue flow is as follows: (Process A,B,C use the same mm)
> > Process C              Process A         Process B
> > qemu-system-x86_64:     kernel:vhost_net  kernel: vhost_net
> > open /dev/vhost-net
> >   VHOST_SET_OWNER   create kthread vhost-%d  create kthread vhost-%d
> >   network init           use_mm()          use_mm()
> >    ...                   ...
> >    Abnormal exited
> >    ...
> >   do_exit
> >   exit_mm()
> >   update mm->owner to A
> >   exit_files()
> >    close_files()
> >    kthread_should_stop() unuse_mm()
> >     Stop Process A       tsk->mm=3DNULL
> >                          do_exit()
> >                          can't update owner
> >                          A exit completed  vhost-%d  rcv first package
> >                                            vhost-%d build rcv buffer fo=
r
> vq
> >                                            page fault
> >                                            access mm & mm->owner
> >                                            NOW,mm->owner still pointer =
A
> >                                            kernel UAF
> >     stop Process B
> >
> > Although I am having this issue on vhost_net,But it affects all users o=
f
> > unuse_mm.
>
> I am confused. How can we ever assign the owner to a kernel thread. We
> skip those explicitly. It simply doesn't make any sense to have an owner
> a kernel thread.
> --
> Michal Hocko
> SUSE Labs
>

--000000000000b8398d057d4e4a72
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div di=
r=3D"ltr">Oh, yes, the patch=C2=A039af176 has been skip the kthread on=C2=
=A0mm_update_next_owner .=C2=A0</div><div>Thanks for your tips.</div><div><=
br></div><div>thanks and regards</div><div><br></div></div></div></div></di=
v><br><div class=3D"gmail_quote"><div dir=3D"ltr">Michal Hocko &lt;<a href=
=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; =E4=BA=8E2018=E5=B9=
=B412=E6=9C=8818=E6=97=A5=E5=91=A8=E4=BA=8C =E4=B8=8B=E5=8D=885:52=E5=86=99=
=E9=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1e=
x">On Tue 18-12-18 13:24:44, <a href=3D"mailto:gchen.guomin@gmail.com" targ=
et=3D"_blank">gchen.guomin@gmail.com</a> wrote:<br>
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
&gt; The current issue flow is as follows: (Process A,B,C use the same mm)<=
br>
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
<br>
I am confused. How can we ever assign the owner to a kernel thread. We<br>
skip those explicitly. It simply doesn&#39;t make any sense to have an owne=
r<br>
a kernel thread.<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--000000000000b8398d057d4e4a72--
