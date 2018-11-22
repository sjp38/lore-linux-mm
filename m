Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A11BD6B28E2
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:20:04 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 89so12377239ple.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:20:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30sor56443776pgz.10.2018.11.21.18.20.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 18:20:03 -0800 (PST)
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Message-Id: <314D030F-2112-44E4-ABD3-A3A9B8597A3A@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_12BBE2AE-838C-40BB-B17E-6826CC2A0957"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Date: Thu, 22 Nov 2018 10:19:58 +0800
In-Reply-To: <20181121162747.GR12932@dhcp22.suse.cz>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
 <20181121162747.GR12932@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


--Apple-Mail=_12BBE2AE-838C-40BB-B17E-6826CC2A0957
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

I had view the slab kmem_cache_alloc function=EF=BC=8CI think the =
virtual netdevice object will charged to memcg.
Becuse the function slab_pre_alloc_hook will choose a kmem_cache, which =
belong to current task memcg.
If  virtual netdevice object not destroy by another command, the virtual =
netdevice object will still charged to memcg, and the memcg will still =
in memory.

Above is just an example.
The general scenario is as follows
if a user process which has own memcg creates a semi-permeanent kernel =
object , and does not release this kernel object before exit.
The memcg which belong to this process will just offline but not release =
until the semi-permeanent kernel object release.

I think in those case=EF=BC=8C kernel will hold more memory than =
user=E2=80=99s think=E3=80=82no just sizeof(struct blabla),but =
sizeof(struct blabla) + memory memcg used.

bytedance.net
=E6=AE=B5=E7=86=8A=E6=98=A5
duanxiongchun@bytedance.com




> On Nov 22, 2018, at 12:27 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Wed 21-11-18 17:36:51, =E6=AE=B5=E7=86=8A=E6=98=A5 wrote:
>> hi all=EF=BC=9A
>>=20
>> In same case=EF=BC=8C I think it=E2=80=99s may be a problem=E3=80=82
>>=20
>> if I create a virtual netdev device under mem cgroup(like ip link add =
ve_A type veth peer name ve_B).after that ,I destroy this mem cgroup=E3=80=
=82
>=20
> Which object is charged to that memcg? If there is no relation to any
> task context then accounting to a memcg is problematic.
>=20
> --=20
> Michal Hocko
> SUSE Labs


--Apple-Mail=_12BBE2AE-838C-40BB-B17E-6826CC2A0957
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">I =
had view the slab kmem_cache_alloc function=EF=BC=8CI think the virtual =
netdevice object will charged to memcg.<div class=3D"">Becuse the =
function slab_pre_alloc_hook will choose a kmem_cache, which belong to =
current task memcg.</div><div class=3D"">If &nbsp;virtual netdevice =
object not destroy by another command, the virtual netdevice object will =
still charged to memcg, and the memcg will still in memory.</div><div =
class=3D""><br class=3D""></div><div class=3D"">Above is just an =
example.</div><div class=3D"">The general scenario is as =
follows</div><div class=3D"">if a user process which has own memcg =
creates a semi-permeanent kernel object , and does not release this =
kernel object before exit.</div><div class=3D"">The memcg which belong =
to this process will just offline but not release until the =
semi-permeanent kernel object release.</div><div class=3D""><br =
class=3D""></div><div class=3D"">I think in those case=EF=BC=8C kernel =
will hold more memory than user=E2=80=99s think=E3=80=82no just =
sizeof(struct blabla),but sizeof(struct blabla) + memory memcg =
used.</div><div class=3D""><br class=3D""></div><div class=3D""><div =
class=3D"">
<div dir=3D"auto" style=3D"word-wrap: break-word; -webkit-nbsp-mode: =
space; line-break: after-white-space;" class=3D""><div =
style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><a href=3D"http://bytedance.net" class=3D"">bytedance.net</a><br =
class=3D"">=E6=AE=B5=E7=86=8A=E6=98=A5<br =
class=3D"">duanxiongchun@bytedance.com<br class=3D""><br =
class=3D""></div><br class=3D"Apple-interchange-newline"></div><br =
class=3D"Apple-interchange-newline">
</div>
<div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Nov 22, 2018, at 12:27 AM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><div =
class=3D"">On Wed 21-11-18 17:36:51, =E6=AE=B5=E7=86=8A=E6=98=A5 =
wrote:<br class=3D""><blockquote type=3D"cite" class=3D"">hi all=EF=BC=9A<=
br class=3D""><br class=3D"">In same case=EF=BC=8C I think it=E2=80=99s =
may be a problem=E3=80=82<br class=3D""><br class=3D"">if I create a =
virtual netdev device under mem cgroup(like ip link add ve_A type veth =
peer name ve_B).after that ,I destroy this mem cgroup=E3=80=82<br =
class=3D""></blockquote><br class=3D"">Which object is charged to that =
memcg? If there is no relation to any<br class=3D"">task context then =
accounting to a memcg is problematic.<br class=3D""><br class=3D"">-- =
<br class=3D"">Michal Hocko<br class=3D"">SUSE Labs<br =
class=3D""></div></div></blockquote></div><br =
class=3D""></div></body></html>=

--Apple-Mail=_12BBE2AE-838C-40BB-B17E-6826CC2A0957--
