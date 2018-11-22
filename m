Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59A536B290E
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:56:11 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so12837678pll.0
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:56:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y64sor46223274pgd.38.2018.11.21.18.56.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 18:56:09 -0800 (PST)
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Message-Id: <7348A2DF-87E8-4F88-B270-7FB71DB5C8CB@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_B44ED4FD-3340-4525-B0B2-D7F8D1C4E36F"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Date: Thu, 22 Nov 2018 10:56:04 +0800
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


--Apple-Mail=_B44ED4FD-3340-4525-B0B2-D7F8D1C4E36F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

We worry about that because in our system ,we use systemd manager our =
service . One day we find some machine suddenly eat lots of memory.
we find in some case=EF=BC=8Cour server will start fail just recording a =
log then exit=E3=80=82 but the systemd will relaunch this server every 2 =
second. That  server is limit memory access by memcg.

After long time dig, we find their lots of offline but not release memcg =
object in memory eating lots of memory.
Why this memcg not release? Because the inode pagecache use  some page =
which is charged to those memcg,

And we find some time the inode(log file inode ) is also charged to one  =
memcg.  The only way to release that memcg is to free the inode =
object(example, to remove the log file.)

No matter which allocator  using (slab or slub), the problem is aways =
there.=20

After  I view the code in slab ,slub and memcg. I think in above general =
scenario there maybe a problem.

Thanks for replying
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


--Apple-Mail=_B44ED4FD-3340-4525-B0B2-D7F8D1C4E36F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">We =
worry about that because in our system ,we use systemd manager our =
service . One day we find some machine suddenly eat lots of memory.<div =
class=3D"">we find in some case=EF=BC=8Cour server will start fail just =
recording a log then exit=E3=80=82 but the systemd will relaunch this =
server every 2 second. That &nbsp;server is limit memory access by =
memcg.</div><div class=3D""><br class=3D""></div><div class=3D"">After =
long time dig, we find their lots of offline but not release memcg =
object in memory eating lots of memory.</div><div class=3D"">Why this =
memcg not release? Because the inode pagecache use &nbsp;some page which =
is charged to those memcg,</div><div class=3D""><br class=3D""></div><div =
class=3D"">And we find some time the inode(log file inode ) is also =
charged to one &nbsp;memcg. &nbsp;The only way to release that memcg is =
to free the inode object(example, to remove the log file.)</div><div =
class=3D""><br class=3D""></div><div class=3D"">No matter which =
allocator &nbsp;using (slab or slub), the problem is aways =
there.&nbsp;</div><div class=3D""><br class=3D""></div><div =
class=3D"">After &nbsp;I view the code in slab ,slub and memcg. I think =
in above general scenario there maybe a problem.</div><div class=3D""><br =
class=3D""></div><div class=3D"">Thanks for replying</div><div =
class=3D""><div class=3D"">
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

--Apple-Mail=_B44ED4FD-3340-4525-B0B2-D7F8D1C4E36F--
