Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2943C6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:15:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id j12so389923462ywb.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:15:44 -0700 (PDT)
Received: from mail-ua0-x244.google.com (mail-ua0-x244.google.com. [2607:f8b0:400c:c08::244])
        by mx.google.com with ESMTPS id d64si3662530vkb.125.2016.08.04.11.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 11:15:43 -0700 (PDT)
Received: by mail-ua0-x244.google.com with SMTP id s7so4943147uas.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:15:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160804115809.GA447@swordfish>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl> <20160804115809.GA447@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 4 Aug 2016 14:15:02 -0400
Message-ID: <CALZtONBODigWHuCdz0j9OUTwEhs9vdfuQZ1HnjHDLXNdNdz4qg@mail.gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Content-Type: multipart/alternative; boundary=001a113ec7841e9769053942f0b8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, Vitaly Wool <vitalywool@gmail.com>, =?UTF-8?Q?Marcin_Miros=C5=82aw?= <marcin@mejor.pl>, Andrew Morton <akpm@linux-foundation.org>

--001a113ec7841e9769053942f0b8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 4, 2016 at 7:58 AM, Sergey Senozhatsky <
sergey.senozhatsky.work@gmail.com> wrote:

> Hello,
>
> Cc Seth, Dan
>
> On (08/01/16 11:03), Marcin Miros=C5=82aw wrote:
> > [  429.722411] ------------[ cut here ]------------
> > [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
> __zswap_pool_current+0x56/0x60
> > [  429.740048] Call Trace:
> > [  429.740048]  [<ffffffffad255d43>] dump_stack+0x63/0x90
> > [  429.740048]  [<ffffffffad04c997>] __warn+0xc7/0xf0
> > [  429.740048]  [<ffffffffad04cac8>] warn_slowpath_null+0x18/0x20
> > [  429.740048]  [<ffffffffad1250c6>] __zswap_pool_current+0x56/0x60
> > [  429.740048]  [<ffffffffad1250e3>] zswap_pool_current+0x13/0x20
> > [  429.740048]  [<ffffffffad125efb>] __zswap_param_set+0x1db/0x2f0
> > [  429.740048]  [<ffffffffad126042>] zswap_zpool_param_set+0x12/0x20
> > [  429.740048]  [<ffffffffad06645f>] param_attr_store+0x5f/0xc0
> > [  429.740048]  [<ffffffffad065b69>] module_attr_store+0x19/0x30
> > [  429.740048]  [<ffffffffad1b0b02>] sysfs_kf_write+0x32/0x40
> > [  429.740048]  [<ffffffffad1b0663>] kernfs_fop_write+0x113/0x190
> > [  429.740048]  [<ffffffffad13fc52>] __vfs_write+0x32/0x150
> > [  429.740048]  [<ffffffffad15f0ae>] ? __fd_install+0x2e/0xe0
> > [  429.740048]  [<ffffffffad15ef11>] ? __alloc_fd+0x41/0x180
> > [  429.740048]  [<ffffffffad0838dd>] ? percpu_down_read+0xd/0x50
> > [  429.740048]  [<ffffffffad140d33>] vfs_write+0xb3/0x1a0
> > [  429.740048]  [<ffffffffad13db81>] ? filp_close+0x51/0x70
> > [  429.740048]  [<ffffffffad142140>] SyS_write+0x50/0xc0
> > [  429.740048]  [<ffffffffad413836>] entry_SYSCALL_64_fastpath+0x1e/0xa=
8
> > [  429.764069] ---[ end trace ff7835fbf4d983b9 ]---
>
> I think it's something like this.
>
> suppose there are no pools available - the list is empty (see later).
> __zswap_param_set():
>
>         pool =3D zswap_pool_find_get(type, compressor);
>
> gives NULL. so it creates a new one
>
>         pool =3D zswap_pool_create(type, compressor);
>
> then it does
>
>         ret =3D param_set_charp(s, kp);
>
> which gives 0 -- all ok. so it goes to
>
>         if (!ret) {
>                 put_pool =3D zswap_pool_current();
>         }
>
> which gives WARN_ON(), as the list is still empty.
>
>
>
> now, how is this possible. for example, we init a zswap with the default
> configuration; but zbud is not available (can it be?). so the pool creati=
on
> fails, but init_zswap() does not set zswap_init_started back to false. it
> either must clear it at the error path, or set it to true right before
> 'return 0'.
>

yep that's exactly right.  I reproduced it with zbud compiled out.



>
> one more problem here is that param_set_charp() does GFP_KERNEL
> under zswap_pools_lock.
>

yep that's true as well.

i can get patches going for both these, unless you're already working on it=
?




>
>         -ss
>

--001a113ec7841e9769053942f0b8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Thu, Aug 4, 2016 at 7:58 AM, Sergey Senozhatsky <span dir=3D"ltr">&l=
t;<a href=3D"mailto:sergey.senozhatsky.work@gmail.com" target=3D"_blank">se=
rgey.senozhatsky.work@gmail.com</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">Hello,<br>
<br>
Cc Seth, Dan<br>
<span class=3D""><br>
On (08/01/16 11:03), Marcin Miros=C5=82aw wrote:<br>
&gt; [=C2=A0 429.722411] ------------[ cut here ]------------<br>
&gt; [=C2=A0 429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503 __zswa=
p_pool_current+0x56/0x60<br>
</span><span class=3D"">&gt; [=C2=A0 429.740048] Call Trace:<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad255d43&gt;] dump_stack+0x63/0=
x90<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad04c997&gt;] __warn+0xc7/0xf0<=
br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad04cac8&gt;] warn_slowpath_nul=
l+0x18/0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1250c6&gt;] __zswap_pool_curr=
ent+0x56/0x60<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1250e3&gt;] zswap_pool_curren=
t+0x13/0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad125efb&gt;] __zswap_param_set=
+0x1db/0x2f0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad126042&gt;] zswap_zpool_param=
_set+0x12/<wbr>0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad06645f&gt;] param_attr_store+=
0x5f/0xc0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad065b69&gt;] module_attr_store=
+0x19/0x30<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1b0b02&gt;] sysfs_kf_write+0x=
32/0x40<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1b0663&gt;] kernfs_fop_write+=
0x113/0x190<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad13fc52&gt;] __vfs_write+0x32/=
0x150<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad15f0ae&gt;] ? __fd_install+0x=
2e/0xe0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad15ef11&gt;] ? __alloc_fd+0x41=
/0x180<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad0838dd&gt;] ? percpu_down_rea=
d+0xd/0x50<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad140d33&gt;] vfs_write+0xb3/0x=
1a0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad13db81&gt;] ? filp_close+0x51=
/0x70<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad142140&gt;] SyS_write+0x50/0x=
c0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad413836&gt;] entry_SYSCALL_64_=
fastpath+<wbr>0x1e/0xa8<br>
&gt; [=C2=A0 429.764069] ---[ end trace ff7835fbf4d983b9 ]---<br>
<br>
</span>I think it&#39;s something like this.<br>
<br>
suppose there are no pools available - the list is empty (see later).<br>
__zswap_param_set():<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pool =3D zswap_pool_find_get(type, compressor);=
<br>
<br>
gives NULL. so it creates a new one<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pool =3D zswap_pool_create(type, compressor);<b=
r>
<br>
then it does<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D param_set_charp(s, kp);<br>
<br>
which gives 0 -- all ok. so it goes to<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ret) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_pool =3D zswap_=
pool_current();<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
which gives WARN_ON(), as the list is still empty.<br>
<br>
<br>
<br>
now, how is this possible. for example, we init a zswap with the default<br=
>
configuration; but zbud is not available (can it be?). so the pool creation=
<br>
fails, but init_zswap() does not set zswap_init_started back to false. it<b=
r>
either must clear it at the error path, or set it to true right before<br>
&#39;return 0&#39;.<br></blockquote><div><br></div><div>yep that&#39;s exac=
tly right.=C2=A0 I reproduced it with zbud compiled out.</div><div><br></di=
v><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
one more problem here is that param_set_charp() does GFP_KERNEL<br>
under zswap_pools_lock.<br></blockquote><div><br></div><div>yep that&#39;s =
true as well.</div><div><br></div><div>i can get patches going for both the=
se, unless you&#39;re already working on it?</div><div><br></div><div><br><=
/div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 -ss<br>
</font></span></blockquote></div><br></div></div>

--001a113ec7841e9769053942f0b8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
