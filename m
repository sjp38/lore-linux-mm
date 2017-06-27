Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 507A583296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:21:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g6so5563517wmc.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:21:10 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id q73si2988568wmd.8.2017.06.27.08.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 08:21:08 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id 77so161018753wrb.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:21:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170627071104.GB28078@dhcp22.suse.cz>
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
 <20170627071104.GB28078@dhcp22.suse.cz>
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 27 Jun 2017 08:21:07 -0700
Message-ID: <CAA25o9T1q9gWzb0BeXY3mvLOth-ow=yjVuwD9ct5f1giBWo=XQ@mail.gmail.com>
Subject: Re: OOM kills with lots of free swap
Content-Type: multipart/alternative; boundary="001a113c2ba4e809aa0552f29d39"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

--001a113c2ba4e809aa0552f29d39
Content-Type: text/plain; charset="UTF-8"

(copying Minchan because I just asked him the same question.)

Thank you, I can try this on ToT, although I think that the problem is not
with the OOM killer itself but earlier---i.e. invoking the OOM killer seems
unnecessary and wrong.  Here's the question.

The general strategy for page allocation seems to be (please correct me as
needed):

1. look in the free lists
2. if that did not succeed, try to reclaim, then try again to allocate
3. keep trying as long as progress is made (i.e. something was reclaimed)
4. if no progress was made and no pages were found, invoke the OOM killer.

I'd like to know if that "progress is made" notion is possibly buggy.
Specifically, does it mean "progress is made by this task"?  Is it possible
that resource contention creates a situation where most tasks in most cases
can reclaim and allocate, but one task randomly fails to make progress?


On Tue, Jun 27, 2017 at 12:11 AM, Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 23-06-17 16:29:39, Luigi Semenzato wrote:
> > It is fairly easy to trigger OOM-kills with almost empty swap, by
> > running several fast-allocating processes in parallel.  I can
> > reproduce this on many 3.x kernels (I think I tried also on 4.4 but am
> > not sure).  I am hoping this is a known problem.
>
> The oom detection code has been reworked considerably in 4.7 so I would
> like to see whether your problem is still presenet with more up-to-date
> kernels. Also an OOM report is really necessary to get any clue what
> might have been going on.
>
> --
> Michal Hocko
> SUSE Labs
>

--001a113c2ba4e809aa0552f29d39
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>(copying Minchan because I just asked him the same qu=
estion.)</div><div><br></div>Thank you, I can try this on ToT, although I t=
hink that the problem is not with the OOM killer itself but earlier---i.e. =
invoking the OOM killer seems unnecessary and wrong.=C2=A0 Here&#39;s the q=
uestion.<div><br></div><div>The general strategy for page allocation seems =
to be (please correct me as needed):</div><div><br></div><div>1. look in th=
e free lists</div><div>2. if that did not succeed, try to reclaim, then try=
 again to allocate</div><div>3. keep trying as long as progress is made (i.=
e. something was reclaimed)</div><div>4. if no progress was made and no pag=
es were found, invoke the OOM killer.</div><div><br></div><div>I&#39;d like=
 to know if that &quot;progress is made&quot; notion is possibly buggy.=C2=
=A0 Specifically, does it mean &quot;progress is made by this task&quot;?=
=C2=A0 Is it possible that resource contention creates a situation where mo=
st tasks in most cases can reclaim and allocate, but one task randomly fail=
s to make progress?</div><div><br></div></div><div class=3D"gmail_extra"><b=
r><div class=3D"gmail_quote">On Tue, Jun 27, 2017 at 12:11 AM, Michal Hocko=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blan=
k">mhocko@kernel.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
"><span class=3D"">On Fri 23-06-17 16:29:39, Luigi Semenzato wrote:<br>
&gt; It is fairly easy to trigger OOM-kills with almost empty swap, by<br>
&gt; running several fast-allocating processes in parallel.=C2=A0 I can<br>
&gt; reproduce this on many 3.x kernels (I think I tried also on 4.4 but am=
<br>
&gt; not sure).=C2=A0 I am hoping this is a known problem.<br>
<br>
</span>The oom detection code has been reworked considerably in 4.7 so I wo=
uld<br>
like to see whether your problem is still presenet with more up-to-date<br>
kernels. Also an OOM report is really necessary to get any clue what<br>
might have been going on.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div>

--001a113c2ba4e809aa0552f29d39--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
