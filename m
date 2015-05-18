Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD7B6B00B6
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:23:30 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so69509796wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:23:30 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id r6si12722264wiv.0.2015.05.18.06.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 06:23:28 -0700 (PDT)
Received: by wgjc11 with SMTP id c11so26890054wgj.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:23:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7254.1431945085@warthog.procyon.org.uk>
References: <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com>
 <7254.1431945085@warthog.procyon.org.uk>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 18 May 2015 16:23:07 +0300
Message-ID: <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
Content-Type: multipart/alternative; boundary=f46d041828086d28b005165b196e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

--f46d041828086d28b005165b196e
Content-Type: text/plain; charset=UTF-8

On Mon, May 18, 2015 at 1:31 PM, David Howells <dhowells@redhat.com> wrote:

> I can turn on all the macros in a file just be #defining __KDEBUG at the
> top.
> When I first did this, pr_xxx() didn't exist.
>
> Note that the macros in afs, cachefiles, fscache and rxrpc are more complex
> than a grep tells you.  There are _enter(), _leave() and _debug() macros
> which
> are conditional via a module parameter.  These are trivially individually
> enableable during debugging by changing the initial underscore to a 'k'.
> They
> are otherwise enableable by module parameter (macros are individually
> selectable) or enableably by file __KDEBUG.  These are well used.  Note
> that
> just turning them all into pr_devel() would represent a loss of useful
> function.
>
> The ones in the keys directory are also very well used, though they aren't
> externally selectable.  I've added functionality to the debugging, but
> haven't
> necessarily needed to backport it to earlier variants.
>
> For the mn10300 macros, I would just recommend leaving them as is.
>
> For the nommu macros, you could convert them to pr_devel() - but putting
> all
> the information in the kenter/kleave/kdebug macro into each pr_devel macro
> would be more intrusive in the code since you'd have to move the stuff out
> of
> there macro definition into each caller.  You could also reexpress the
> macros
> in terms of pr_devel and get rid of the conditional.  OTOH, there's not
> that
> much in the nommu code, so you could probably slim down a lot of what's
> printed.
>
> For the cred macro, just convert to pr_devel() or pr_debug() and make
> pr_fmt
> insert current->comm and current->pid.
>
> > 2. Move it to general include file (for example linux/printk.h) and
> > commonize the output to be consistent between different kdebug users.
>
> I would quite like to see kenter() and kleave() be moved to printk.h,
> expressed in a similar way to pr_devel() or pr_debug() (and perhaps renamed
> pr_enter() and pr_leave()) but separately so they can be enabled
> separately.
> OTOH, possibly they should be enableable by compilation block rather than
> by
> macro set.
>
> The main thing I like out of the ones in afs, cachefiles, fscache and
> rxrpc is
> the ability to just turn on a few across a bunch of files so as not to get
> overwhelmed by data.
>
Blind conversion to pr_debug will blow the code because it will be always
compiled in. In current implementation, it replaced by empty functions
which is thrown by compiler.

Additionally, It looks like the output of these macros can be viewed by
ftrace mechanism.

Maybe we should delete them from mm/nommu.c as was pointed by Joe?



>
> David
>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--f46d041828086d28b005165b196e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><div class=3D"gmail_quote">=
On Mon, May 18, 2015 at 1:31 PM, David Howells <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:dhowells@redhat.com" target=3D"_blank">dhowells@redhat.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">I can turn on all the m=
acros in a file just be #defining __KDEBUG at the top.<br>
When I first did this, pr_xxx() didn&#39;t exist.<br>
<br>
Note that the macros in afs, cachefiles, fscache and rxrpc are more complex=
<br>
than a grep tells you.=C2=A0 There are _enter(), _leave() and _debug() macr=
os which<br>
are conditional via a module parameter.=C2=A0 These are trivially individua=
lly<br>
enableable during debugging by changing the initial underscore to a &#39;k&=
#39;.=C2=A0 They<br>
are otherwise enableable by module parameter (macros are individually<br>
selectable) or enableably by file __KDEBUG.=C2=A0 These are well used.=C2=
=A0 Note that<br>
just turning them all into pr_devel() would represent a loss of useful<br>
function.<br>
<br>
The ones in the keys directory are also very well used, though they aren&#3=
9;t<br>
externally selectable.=C2=A0 I&#39;ve added functionality to the debugging,=
 but haven&#39;t<br>
necessarily needed to backport it to earlier variants.<br>
<br>
For the mn10300 macros, I would just recommend leaving them as is.<br>
<br>
For the nommu macros, you could convert them to pr_devel() - but putting al=
l<br>
the information in the kenter/kleave/kdebug macro into each pr_devel macro<=
br>
would be more intrusive in the code since you&#39;d have to move the stuff =
out of<br>
there macro definition into each caller.=C2=A0 You could also reexpress the=
 macros<br>
in terms of pr_devel and get rid of the conditional.=C2=A0 OTOH, there&#39;=
s not that<br>
much in the nommu code, so you could probably slim down a lot of what&#39;s=
<br>
printed.<br>
<br>
For the cred macro, just convert to pr_devel() or pr_debug() and make pr_fm=
t<br>
insert current-&gt;comm and current-&gt;pid.<br>
<span class=3D""><br>
&gt; 2. Move it to general include file (for example linux/printk.h) and<br=
>
&gt; commonize the output to be consistent between different kdebug users.<=
br>
<br>
</span>I would quite like to see kenter() and kleave() be moved to printk.h=
,<br>
expressed in a similar way to pr_devel() or pr_debug() (and perhaps renamed=
<br>
pr_enter() and pr_leave()) but separately so they can be enabled separately=
.<br>
OTOH, possibly they should be enableable by compilation block rather than b=
y<br>
macro set.<br>
<br>
The main thing I like out of the ones in afs, cachefiles, fscache and rxrpc=
 is<br>
the ability to just turn on a few across a bunch of files so as not to get<=
br>
overwhelmed by data.<br></blockquote><div>Blind conversion to pr_debug will=
 blow the code because it will be always compiled in. In current implementa=
tion, it replaced by empty functions which is thrown by compiler.<br><br></=
div><div>Additionally, It looks like the output of these macros can be view=
ed by ftrace mechanism.<br><br></div><div>Maybe we should delete them from =
mm/nommu.c as was pointed by Joe?<br></div><div><br>=C2=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
David<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div clas=
s=3D"gmail_signature"><div dir=3D"ltr"><div>Leon Romanovsky | Independent L=
inux Consultant<br><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<a href=3D"http://=
www.leon.nu" target=3D"_blank">www.leon.nu</a>=C2=A0| <a href=3D"mailto:leo=
n@leon.nu" target=3D"_blank">leon@leon.nu</a><br></div></div></div></div>
</div></div>

--f46d041828086d28b005165b196e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
