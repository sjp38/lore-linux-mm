Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65444C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 08:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E02D52064A
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 08:52:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gyFrxRGR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E02D52064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 483E76B0003; Tue,  2 Jul 2019 04:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435A28E0003; Tue,  2 Jul 2019 04:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325D58E0001; Tue,  2 Jul 2019 04:52:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D72276B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 04:52:15 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b67so21424wmd.0
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 01:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JTuhwljJOUZWHBvoSy7PoPPesGty2fbaYJd2quprX/U=;
        b=Rx8J5kOORMu8dPWAdUSfB4UtrgXbD7aQ9s541SxCboBd9Z+GiMONSql0TPmBiDZXEi
         d7039w94Uj3OeMnHRunUCzD206JM1SjjNvvNj/dYWXEyNDJmWpZuONps6bBBadzNT6oq
         CLHimPMi5Lyxk1Q3kGC07DsZh3KNTyLBX8MXFb2V/TWa3s0j0D1RhhKVwLXa3O2NK1wC
         U4NopV3kVnSXwHj3RRO24ZqKrr3gbNel9nXQQWwfjx/KAAc1bg7q82XL/PEmZqs9bn7u
         OMZVMSSD0qtIm52bUHMEtu3jUDYanYgMF5uhmKIRnr7L1eqV8k5e7nksWgyOBt+6Sban
         UoBQ==
X-Gm-Message-State: APjAAAXBMvO6qGKI8zs2BiU2U4lzK6MKi2EVUOFrXR5Wqx2Z3QdZoOEW
	SLlA8VAMyq+x2tTHsCLuiFhdgYE0n2w6WGSSH1fhI0ACW7iNNSlHQjgypeRcTQ6Grlc5XXOKpts
	g7BrPcqu9WtX8XKFeQ6fZTNH69Wb7wfhaFc1ty99vznJGf8DsiSch/ye4Ki97JHgYUQ==
X-Received: by 2002:a5d:5342:: with SMTP id t2mr16302438wrv.126.1562057535197;
        Tue, 02 Jul 2019 01:52:15 -0700 (PDT)
X-Received: by 2002:a5d:5342:: with SMTP id t2mr16302332wrv.126.1562057534220;
        Tue, 02 Jul 2019 01:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562057534; cv=none;
        d=google.com; s=arc-20160816;
        b=Eyk/TG9w1ES07Uo2ip99sON4XrD/WJissNVQnI4FY6xhII93YiF5SxLyfvD98aaAjj
         qsSrfIj6iHyaDtvOW0i/3r4/Aar2Gx6JS+kfRnuBa8epDazWA4Lji3wTGk7rhS+KCxz/
         hWZo8eWNXyBsmR9bY1aejl4oSI8eG1N2T6+l+IWYJysixkgHA7fJSyNQlIERGqWbwt9g
         VB/K8HUuzrgDx9XtIqmRIveCCYwGuwbRcLusNih7aw+TjFihfptqEKTBFfO2HZcQsLSv
         mJTD95KkPRtBlIBofto6HoV5ReNPdzVhZFEaGoZR1r53jTQ5TfidAUlYD97WBaoaPtGg
         ZTWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JTuhwljJOUZWHBvoSy7PoPPesGty2fbaYJd2quprX/U=;
        b=G2pHb80Hvypuc2h8zF9UwzH9pP1s4QcP2tcgPqRK7aPa8sq10yja9BCcKlVri+jlB9
         y5dTiX1/IeTNaJf5GQFI5d9OFZIlrFkhxv/619J7d4FBLVHLN0uf6992df13cC+1M179
         29DGnUdnmREiZ4r1PnjSrrKqrDAyLtdfK5X/6bUaJ4rfux4+8yhDVwD/1ta8hXbg3Mfl
         VThcV837hrG+KagiyT85yPWFMQkbib8A/tOE9orsfOH2vEnlvq4JBD5Oa4XarNhycQvR
         RioU30tJsWdC9/EmhawpUkQv4f+F2y/icgrPQleH3YzPjhGYGbCMptsgUaWzHqNLRyg0
         6VAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gyFrxRGR;
       spf=pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmicy@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor1306398wml.2.2019.07.02.01.52.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 01:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gyFrxRGR;
       spf=pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmicy@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JTuhwljJOUZWHBvoSy7PoPPesGty2fbaYJd2quprX/U=;
        b=gyFrxRGRBB0PW/iAXzXxeu20ngLXqzjxj13Pcw4A2Vp+aP7mMauGwbU2lB4kp3t5SM
         IIQUPZ/eebH5OeAMEGHgPNDejFgUfZbMAVm/TwDaGkBg4G0X9pEcOaxpzUzI46pOrnBU
         y4upf6OU2QpL5LAJgmNAmMsj2rQdl7RStR29Rr31hu7AJpH+8La532MHHR2WjiQthOCp
         nCVuXc1bzoIt/G5T/kR4C/fc4LHurYpBCnRcNkBJw5mGhBljLRDaRQaM5wdsQw4Dc/h9
         q31VqHS2v2fMgXE8XIz3eDUzd/zacxQNXt/plZScOzLplpmgs92Byp7gr4tF/GpGiTY1
         6KXg==
X-Google-Smtp-Source: APXvYqwfBe9NVkbZrgsqX8e7saJnRBjaDFX5BrsN0N0mu0F1DoSwKu6tEbGCM3pIr8KdVSI9bknRZkRXdlDgAQrkW2U=
X-Received: by 2002:a1c:1f06:: with SMTP id f6mr2729241wmf.60.1562057533684;
 Tue, 02 Jul 2019 01:52:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190625075227.15193-1-osalvador@suse.de> <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux> <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux> <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com> <20190702074806.GA26836@linux>
In-Reply-To: <20190702074806.GA26836@linux>
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Tue, 2 Jul 2019 18:52:01 +1000
Message-ID: <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com, 
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, 
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: multipart/alternative; boundary="0000000000006a02f4058caedcdd"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000006a02f4058caedcdd
Content-Type: text/plain; charset="UTF-8"

On Tue, Jul 2, 2019 at 5:48 PM Oscar Salvador <osalvador@suse.de> wrote:

> On Tue, Jul 02, 2019 at 04:42:34PM +1000, Rashmica Gupta wrote:
> > Hi David,
> >
> > Sorry for the late reply.
> >
> > On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
> > > On 26.06.19 10:15, Oscar Salvador wrote:
> > > > On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
> > > > > Back then, I already mentioned that we might have some users that
> > > > > remove_memory() they never added in a granularity it wasn't
> > > > > added. My
> > > > > concerns back then were never fully sorted out.
> > > > >
> > > > > arch/powerpc/platforms/powernv/memtrace.c
> > > > >
> > > > > - Will remove memory in memory block size chunks it never added
> > > > > - What if that memory resides on a DIMM added via
> > > > > MHP_MEMMAP_DEVICE?
> > > > >
> > > > > Will it at least bail out? Or simply break?
> > > > >
> > > > > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save
> > > > > to be
> > > > > introduced.
> > > >
> > > > Uhm, I will take a closer look and see if I can clear your
> > > > concerns.
> > > > TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
> > > > yet.
> > > >
> > > > I will get back to you once I tried it out.
> > > >
> > >
> > > BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
> > > very ugly and dangerous.
> >
> > Yes it would be nice to clean this up.
> >
> > > We should never allow to manually
> > > offline/online pages / hack into memory block states.
> > >
> > > What I would want to see here is rather:
> > >
> > > 1. User space offlines the blocks to be used
> > > 2. memtrace installs a hotplug notifier and hinders the blocks it
> > > wants
> > > to use from getting onlined.
> > > 3. memory is not added/removed/onlined/offlined in memtrace code.
> > >
> >
> > I remember looking into doing it a similar way. I can't recall the
> > details but my issue was probably 'how does userspace indicate to
> > the kernel that this memory being offlined should be removed'?
> >
> > I don't know the mm code nor how the notifiers work very well so I
> > can't quite see how the above would work. I'm assuming memtrace would
> > register a hotplug notifier and when memory is offlined from userspace,
> > the callback func in memtrace would be called if the priority was high
> > enough? But how do we know that the memory being offlined is intended
> > for usto touch? Is there a way to offline memory from userspace not
> > using sysfs or have I missed something in the sysfs interface?
> >
> > On a second read, perhaps you are assuming that memtrace is used after
> > adding new memory at runtime? If so, that is not the case. If not, then
> > would you be able to clarify what I'm not seeing?
>
> Hi Rashmica,
>
> let us go the easy way here.
> Could you please explain:
>
>
Sure!


> 1) How memtrace works
>

 You write the size of the chunk of memory you want into the debugfs file
and memtrace will attempt to find a contiguous section of memory of that
size
that can be offlined. If it finds that, then the memory is removed from the
kernel's mappings. If you want a different size, then you write that to the
debugsfs file and memtrace will re-add the memory it first removed and then
try to offline and remove the a chunk of the new size.



> 2) Why it was designed, what is the goal of the interface?
> 3) When it is supposed to be used?
>
>
There is a hardware debugging facility (htm) on some power chips. To use
this you need a contiguous portion of memory for the output to be dumped
to - and we obviously don't want this memory to be simultaneously used by
the kernel.

At boot time we can portion off a section of memory for this (and not tell
the
kernel about it), but sometimes you want to be able to use the hardware
debugging facilities and you haven't done this and you don't want to reboot
your machine - and memtrace is the solution for this.

If you're curious one tool that uses this debugging facility is here:
https://github.com/open-power/pdbg. Relevant files are libpdbg/htm.c and
src/htm.c.


I have seen a couple of reports in the past from people running memtrace
> and failing to do so sometimes, and back then I could not grasp why people
> was using it, or under which circumstances was nice to have.
> So it would be nice to have a detailed explanation from the person who
> wrote
> it.
>
>
Is that enough detail?


> Thanks
>
> --
> Oscar Salvador
> SUSE L3
>

--0000000000006a02f4058caedcdd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Tue, Jul 2, 2019 at 5:48 PM Oscar =
Salvador &lt;<a href=3D"mailto:osalvador@suse.de">osalvador@suse.de</a>&gt;=
 wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px =
0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Tue, =
Jul 02, 2019 at 04:42:34PM +1000, Rashmica Gupta wrote:<br>
&gt; Hi David,<br>
&gt; <br>
&gt; Sorry for the late reply.<br>
&gt; <br>
&gt; On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:<br>
&gt; &gt; On 26.06.19 10:15, Oscar Salvador wrote:<br>
&gt; &gt; &gt; On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand =
wrote:<br>
&gt; &gt; &gt; &gt; Back then, I already mentioned that we might have some =
users that<br>
&gt; &gt; &gt; &gt; remove_memory() they never added in a granularity it wa=
sn&#39;t<br>
&gt; &gt; &gt; &gt; added. My<br>
&gt; &gt; &gt; &gt; concerns back then were never fully sorted out.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; arch/powerpc/platforms/powernv/memtrace.c<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; - Will remove memory in memory block size chunks it nev=
er added<br>
&gt; &gt; &gt; &gt; - What if that memory resides on a DIMM added via<br>
&gt; &gt; &gt; &gt; MHP_MEMMAP_DEVICE?<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; Will it at least bail out? Or simply break?<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE=
 is save<br>
&gt; &gt; &gt; &gt; to be<br>
&gt; &gt; &gt; &gt; introduced.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; Uhm, I will take a closer look and see if I can clear your<b=
r>
&gt; &gt; &gt; concerns.<br>
&gt; &gt; &gt; TBH, I did not try to use arch/powerpc/platforms/powernv/mem=
trace.c<br>
&gt; &gt; &gt; yet.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; I will get back to you once I tried it out.<br>
&gt; &gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; BTW, I consider the code in arch/powerpc/platforms/powernv/memtra=
ce.c<br>
&gt; &gt; very ugly and dangerous.<br>
&gt; <br>
&gt; Yes it would be nice to clean this up.<br>
&gt; <br>
&gt; &gt; We should never allow to manually<br>
&gt; &gt; offline/online pages / hack into memory block states.<br>
&gt; &gt; <br>
&gt; &gt; What I would want to see here is rather:<br>
&gt; &gt; <br>
&gt; &gt; 1. User space offlines the blocks to be used<br>
&gt; &gt; 2. memtrace installs a hotplug notifier and hinders the blocks it=
<br>
&gt; &gt; wants<br>
&gt; &gt; to use from getting onlined.<br>
&gt; &gt; 3. memory is not added/removed/onlined/offlined in memtrace code.=
<br>
&gt; &gt;<br>
&gt; <br>
&gt; I remember looking into doing it a similar way. I can&#39;t recall the=
<br>
&gt; details but my issue was probably &#39;how does userspace indicate to<=
br>
&gt; the kernel that this memory being offlined should be removed&#39;?<br>
&gt; <br>
&gt; I don&#39;t know the mm code nor how the notifiers work very well so I=
<br>
&gt; can&#39;t quite see how the above would work. I&#39;m assuming memtrac=
e would<br>
&gt; register a hotplug notifier and when memory is offlined from userspace=
,<br>
&gt; the callback func in memtrace would be called if the priority was high=
<br>
&gt; enough? But how do we know that the memory being offlined is intended<=
br>
&gt; for usto touch? Is there a way to offline memory from userspace not<br=
>
&gt; using sysfs or have I missed something in the sysfs interface?<br>
&gt; <br>
&gt; On a second read, perhaps you are assuming that memtrace is used after=
<br>
&gt; adding new memory at runtime? If so, that is not the case. If not, the=
n<br>
&gt; would you be able to clarify what I&#39;m not seeing?<br>
<br>
Hi Rashmica,<br>
<br>
let us go the easy way here.<br>
Could you please explain:<br>
<br></blockquote><div><br></div><div>Sure!</div><div>=C2=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px s=
olid rgb(204,204,204);padding-left:1ex">
1) How memtrace works<br></blockquote><div>=C2=A0</div><div>=C2=A0You write=
 the size of the chunk of memory you want into the debugfs file</div><div>a=
nd memtrace will attempt to find a contiguous section of memory of that siz=
e</div><div>that can be offlined. If it finds that, then the memory is remo=
ved from the</div><div>kernel&#39;s mappings. If you want a different size,=
 then you write that to the</div><div>debugsfs file and memtrace will re-ad=
d the memory it first removed and then</div><div>try to offline and remove =
the a chunk of the new size.</div><div><br></div><div>=C2=A0</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px =
solid rgb(204,204,204);padding-left:1ex">
2) Why it was designed, what is the goal of the interface?<br>
3) When it is supposed to be used?<br>
<br></blockquote><div><br></div><div>There is a hardware debugging facility=
 (htm) on some power chips. To use</div><div>this you need a contiguous por=
tion of memory for the output to be dumped</div><div>to - and we obviously =
don&#39;t want this memory to be simultaneously used by</div><div>the kerne=
l.=C2=A0</div><div><br></div><div>At boot time we can portion off a section=
 of memory for this (and not tell the</div><div>kernel about it), but somet=
imes you want to be able to use the hardware</div><div>debugging facilities=
 and you haven&#39;t done this and you don&#39;t want to reboot</div><div>y=
our machine - and memtrace is the solution for this.</div><div><br></div><d=
iv>If you&#39;re curious one tool that uses this debugging facility is here=
:</div><div><a href=3D"https://github.com/open-power/pdbg">https://github.c=
om/open-power/pdbg</a>. Relevant files are libpdbg/htm.c and src/htm.c.</di=
v><div><br></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"=
margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-lef=
t:1ex">
I have seen a couple of reports in the past from people running memtrace<br=
>
and failing to do so sometimes, and back then I could not grasp why people<=
br>
was using it, or under which circumstances was nice to have.<br>
So it would be nice to have a detailed explanation from the person who wrot=
e<br>
it.<br>
<br></blockquote><div><br></div><div>Is that enough detail?</div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex">
Thanks<br>
<br>
-- <br>
Oscar Salvador<br>
SUSE L3<br>
</blockquote></div></div>

--0000000000006a02f4058caedcdd--

