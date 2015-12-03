Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D851F6B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 14:26:11 -0500 (EST)
Received: by oba1 with SMTP id 1so16046492oba.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:26:11 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id c124si9297865oia.13.2015.12.03.11.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 11:26:11 -0800 (PST)
Received: by oies6 with SMTP id s6so56579278oie.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:26:11 -0800 (PST)
MIME-Version: 1.0
References: <20151127082010.GA2500@dhcp22.suse.cz> <20151128145113.GB4135@amd>
 <20151130132129.GB21950@dhcp22.suse.cz> <20151201.153517.224543138214404348.davem@davemloft.net>
 <CAMXMK6u1vQ772SGv-J3cKvOmS6QRAjjQLYiSiWO2+T=HRTiK1A@mail.gmail.com> <20151203081646.GB9264@dhcp22.suse.cz>
In-Reply-To: <20151203081646.GB9264@dhcp22.suse.cz>
From: Chris Snook <chris.snook@gmail.com>
Date: Thu, 03 Dec 2015 19:26:01 +0000
Message-ID: <CAMXMK6v3i0djY2kW4OmJPvc5CuYFu8WeYeKa=Z0WSvk48wa6Rg@mail.gmail.com>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Content-Type: multipart/alternative; boundary=001a113cf54404df780526035d0d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, pavel@ucw.cz, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

--001a113cf54404df780526035d0d
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 3, 2015 at 12:16 AM Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 02-12-15 22:43:31, Chris Snook wrote:
> > On Tue, Dec 1, 2015 at 12:35 PM David Miller <davem@davemloft.net>
> wrote:
> >
> > > From: Michal Hocko <mhocko@kernel.org>
> > > Date: Mon, 30 Nov 2015 14:21:29 +0100
> > >
> > > > On Sat 28-11-15 15:51:13, Pavel Machek wrote:
> > > >>
> > > >> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> > > >> priority. That often breaks  networking after resume. Switch to
> > > >> GFP_KERNEL. Still not ideal, but should be significantly better.
> > > >
> > > > It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neithe=
r
> > > > from the changelog nor from the patch context.
> > >
> > > Earlier in the function we do a GFP_KERNEL kmalloc so:
> > >
> > > =C2=AF\_(=E3=83=84)_/=C2=AF
> > >
> > > It should be fine.
> > >
> >
> > AFAICT, the people who benefit from GFP_ATOMIC are the people running a=
ll
> > their storage over NFS/iSCSI who are suspending their machines while
> > they're so busy they don't have any clean order 4 pagecache to drop, an=
d
> > want the machine to panic rather than hang.
>
> Why would GFP_KERNEL order-4 allocation hang? It will fail if there are
> not >=3D4 order pages available even after reclaim and/or compaction.
> GFP_ATOMIC allocations should be used only when an access to memory
> reserves is really required. If the allocation just doesn't want to
> invoke direct reclaim then GFP_NOWAIT is a more suitable alternative.
>

The *machine* may hang if you can't bring back the interface that's
required to access the storage. It's a ridiculous use case, as Pavel noted.
I only pointed it out to note that there exists a rationale for GFP_ATOMIC.
It just isn't nearly as good as the rationale for using GFP_KERNEL.

-- Chris

--001a113cf54404df780526035d0d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><div dir=3D"ltr">On Thu, Dec 3,=
 2015 at 12:16 AM Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">mho=
cko@kernel.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On We=
d 02-12-15 22:43:31, Chris Snook wrote:<br>
&gt; On Tue, Dec 1, 2015 at 12:35 PM David Miller &lt;<a href=3D"mailto:dav=
em@davemloft.net" target=3D"_blank">davem@davemloft.net</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; From: Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org" targe=
t=3D"_blank">mhocko@kernel.org</a>&gt;<br>
&gt; &gt; Date: Mon, 30 Nov 2015 14:21:29 +0100<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Sat 28-11-15 15:51:13, Pavel Machek wrote:<br>
&gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt;&gt; atl1c driver is doing order-4 allocation with GFP_ATOMIC=
<br>
&gt; &gt; &gt;&gt; priority. That often breaks=C2=A0 networking after resum=
e. Switch to<br>
&gt; &gt; &gt;&gt; GFP_KERNEL. Still not ideal, but should be significantly=
 better.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely=
 neither<br>
&gt; &gt; &gt; from the changelog nor from the patch context.<br>
&gt; &gt;<br>
&gt; &gt; Earlier in the function we do a GFP_KERNEL kmalloc so:<br>
&gt; &gt;<br>
&gt; &gt; =C2=AF\_(=E3=83=84)_/=C2=AF<br>
&gt; &gt;<br>
&gt; &gt; It should be fine.<br>
&gt; &gt;<br>
&gt;<br>
&gt; AFAICT, the people who benefit from GFP_ATOMIC are the people running =
all<br>
&gt; their storage over NFS/iSCSI who are suspending their machines while<b=
r>
&gt; they&#39;re so busy they don&#39;t have any clean order 4 pagecache to=
 drop, and<br>
&gt; want the machine to panic rather than hang.<br>
<br>
Why would GFP_KERNEL order-4 allocation hang? It will fail if there are<br>
not &gt;=3D4 order pages available even after reclaim and/or compaction.<br=
>
GFP_ATOMIC allocations should be used only when an access to memory<br>
reserves is really required. If the allocation just doesn&#39;t want to<br>
invoke direct reclaim then GFP_NOWAIT is a more suitable alternative.<br></=
blockquote><div><br></div><div>The *machine* may hang if you can&#39;t brin=
g back the interface that&#39;s required to access the storage. It&#39;s a =
ridiculous use case, as Pavel noted. I only pointed it out to note that the=
re exists a rationale for GFP_ATOMIC. It just isn&#39;t nearly as good as t=
he rationale for using GFP_KERNEL.<br><br></div><div>-- Chris<br></div></di=
v></div>

--001a113cf54404df780526035d0d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
