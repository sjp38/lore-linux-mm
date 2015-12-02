Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 002116B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 17:43:41 -0500 (EST)
Received: by oixx65 with SMTP id x65so35463604oix.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:43:41 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id zf5si5091988obb.63.2015.12.02.14.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 14:43:41 -0800 (PST)
Received: by oies6 with SMTP id s6so35875379oie.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:43:41 -0800 (PST)
MIME-Version: 1.0
References: <20151127082010.GA2500@dhcp22.suse.cz> <20151128145113.GB4135@amd>
 <20151130132129.GB21950@dhcp22.suse.cz> <20151201.153517.224543138214404348.davem@davemloft.net>
In-Reply-To: <20151201.153517.224543138214404348.davem@davemloft.net>
From: Chris Snook <chris.snook@gmail.com>
Date: Wed, 02 Dec 2015 22:43:31 +0000
Message-ID: <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Content-Type: multipart/alternative; boundary=001a1141b7e08020590525f20178
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, mhocko@kernel.org
Cc: pavel@ucw.cz, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

--001a1141b7e08020590525f20178
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 1, 2015 at 12:35 PM David Miller <davem@davemloft.net> wrote:

> From: Michal Hocko <mhocko@kernel.org>
> Date: Mon, 30 Nov 2015 14:21:29 +0100
>
> > On Sat 28-11-15 15:51:13, Pavel Machek wrote:
> >>
> >> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> >> priority. That often breaks  networking after resume. Switch to
> >> GFP_KERNEL. Still not ideal, but should be significantly better.
> >
> > It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neither
> > from the changelog nor from the patch context.
>
> Earlier in the function we do a GFP_KERNEL kmalloc so:
>
> =C2=AF\_(=E3=83=84)_/=C2=AF
>
> It should be fine.
>

AFAICT, the people who benefit from GFP_ATOMIC are the people running all
their storage over NFS/iSCSI who are suspending their machines while
they're so busy they don't have any clean order 4 pagecache to drop, and
want the machine to panic rather than hang. The people who benefit from
GFP_KERNEL are the people who use their laptop for a while, put it to
sleep, and then wake it up again. I think the latter is the use case we
should be optimizing for.

-- Chris

--001a1141b7e08020590525f20178
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><div dir=3D"ltr">On Tue, Dec 1,=
 2015 at 12:35 PM David Miller &lt;<a href=3D"mailto:davem@davemloft.net">d=
avem@davemloft.net</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">F=
rom: Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blank=
">mhocko@kernel.org</a>&gt;<br>
Date: Mon, 30 Nov 2015 14:21:29 +0100<br>
<br>
&gt; On Sat 28-11-15 15:51:13, Pavel Machek wrote:<br>
&gt;&gt;<br>
&gt;&gt; atl1c driver is doing order-4 allocation with GFP_ATOMIC<br>
&gt;&gt; priority. That often breaks=C2=A0 networking after resume. Switch =
to<br>
&gt;&gt; GFP_KERNEL. Still not ideal, but should be significantly better.<b=
r>
&gt;<br>
&gt; It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neither<b=
r>
&gt; from the changelog nor from the patch context.<br>
<br>
Earlier in the function we do a GFP_KERNEL kmalloc so:<br>
<br>
=C2=AF\_(=E3=83=84)_/=C2=AF<br>
<br>
It should be fine.<br></blockquote><div><br></div><div>AFAICT, the people w=
ho benefit from GFP_ATOMIC are the people running all their storage over NF=
S/iSCSI who are suspending their machines while they&#39;re so busy they do=
n&#39;t have any clean order 4 pagecache to drop, and want the machine to p=
anic rather than hang. The people who benefit from GFP_KERNEL are the peopl=
e who use their laptop for a while, put it to sleep, and then wake it up ag=
ain. I think the latter is the use case we should be optimizing for.<br><br=
></div><div>-- Chris<br></div></div></div>

--001a1141b7e08020590525f20178--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
