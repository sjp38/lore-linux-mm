Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48D0A8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 00:12:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so29976068pgb.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 21:12:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k196sor25747789pga.61.2019.01.03.21.12.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 21:12:37 -0800 (PST)
From: Fam Zheng <zhengfeiran@bytedance.com>
Message-Id: <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_71B2F602-8443-4CFB-A28C-E3CD2C057CD5"
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
Date: Fri, 4 Jan 2019 13:12:29 +0800
In-Reply-To: <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com


--Apple-Mail=_71B2F602-8443-4CFB-A28C-E3CD2C057CD5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On Jan 4, 2019, at 13:00, Yang Shi <shy828301@gmail.com> wrote:
>=20
> On Thu, Jan 3, 2019 at 8:45 PM Fam Zheng <zhengfeiran@bytedance.com =
<mailto:zhengfeiran@bytedance.com>> wrote:
>>=20
>> Fixing the mm list address. Sorry for the noise.
>>=20
>> Fam
>>=20
>>=20
>>> On Jan 4, 2019, at 12:43, Fam Zheng <zhengfeiran@bytedance.com> =
wrote:
>>>=20
>>> Hi,
>>>=20
>>> In our server which frequently spawns containers, we find that if a =
process used pagecache in memory cgroup, after the process exits and =
memory cgroup is offlined, because the pagecache is still charged in =
this memory cgroup, this memory cgroup will not be destroyed until the =
pagecaches are dropped. This brings huge memory stress over time. We =
find that over one hundred thounsand such offlined memory cgroup in =
system hold too much memory (~100G). This memory can not be released =
immediately even after all associated pagecahes are released, because =
those memory cgroups are destroy asynchronously by a kworker. In some =
cases this can cause oom, since the synchronous memory allocation =
failed.
>>>=20
>=20
> Does force_empty help out your usecase? You can write to
> memory.force_empty to reclaim as much as possible memory before
> rmdir'ing memcg. This would prevent from page cache accumulating.

Hmm, this might be an option. FWIW we have been using drop_caches to =
workaround.

>=20
> BTW, this is cgroup v1 only, I'm working on a patch to bring this back
> into v2 as discussed in https://lkml.org/lkml/2019/1/3/484 =
<https://lkml.org/lkml/2019/1/3/484>.
>=20
>>> We think a fix is to create a kworker that scans all pagecaches and =
dentry caches etc. in the background, if a referenced memory cgroup is =
offline, try to drop the cache or move it to the parent cgroup. This =
kworker can wake up periodically, or upon memory cgroup offline event =
(or both).
>=20
> Reparenting has been deprecated for a long time. I don't think we want
> to bring it back. Actually, css offline is handled by kworker now. I
> proposed a patch to do force_empty in kworker, please see
> https://lkml.org/lkml/2019/1/2/377 =
<https://lkml.org/lkml/2019/1/2/377>.

Could you elaborate a bit about why reparenting is not a good idea?

>=20
>>>=20
>>> There is a similar problem in inode. After digging in ext4 code, we =
find that when creating inode cache, SLAB_ACCOUNT is used. In this case, =
inode will alloc in slab which belongs to the current memory cgroup. =
After this memory cgroup goes offline, this inode may be held by a =
dentry cache. If another process uses the same file. this inode will be =
held by that process, preventing the previous memory cgroup from being =
destroyed until this other process closes the file and drops the dentry =
cache.
>=20
> I'm not sure if you really need kmem charge. If not, you may try
> cgroup.memory=3Dnokmem.

A very good hint, we=E2=80=99ll investigate, thanks!

Fam

>=20
> Regards,
> Yang
>=20
>>>=20
>>> We still don't have a reasonable way to fix this.
>>>=20
>>> Ideas?


--Apple-Mail=_71B2F602-8443-4CFB-A28C-E3CD2C057CD5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Jan 4, 2019, at 13:00, Yang Shi &lt;<a =
href=3D"mailto:shy828301@gmail.com" class=3D"">shy828301@gmail.com</a>&gt;=
 wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span=
 style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">On Thu, Jan =
3, 2019 at 8:45 PM Fam Zheng &lt;</span><a =
href=3D"mailto:zhengfeiran@bytedance.com" style=3D"font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" =
class=3D"">zhengfeiran@bytedance.com</a><span style=3D"caret-color: =
rgb(0, 0, 0); font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">&gt; wrote:</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br class=3D"">Fixing the mm list =
address. Sorry for the noise.<br class=3D""><br class=3D"">Fam<br =
class=3D""><br class=3D""><br class=3D""><blockquote type=3D"cite" =
class=3D"">On Jan 4, 2019, at 12:43, Fam Zheng &lt;<a =
href=3D"mailto:zhengfeiran@bytedance.com" =
class=3D"">zhengfeiran@bytedance.com</a>&gt; wrote:<br class=3D""><br =
class=3D"">Hi,<br class=3D""><br class=3D"">In our server which =
frequently spawns containers, we find that if a process used pagecache =
in memory cgroup, after the process exits and memory cgroup is offlined, =
because the pagecache is still charged in this memory cgroup, this =
memory cgroup will not be destroyed until the pagecaches are dropped. =
This brings huge memory stress over time. We find that over one hundred =
thounsand such offlined memory cgroup in system hold too much memory =
(~100G). This memory can not be released immediately even after all =
associated pagecahes are released, because those memory cgroups are =
destroy asynchronously by a kworker. In some cases this can cause oom, =
since the synchronous memory allocation failed.<br class=3D""><br =
class=3D""></blockquote></blockquote><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">Does force_empty help out your usecase? You can write =
to</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" =
class=3D"">memory.force_empty to reclaim as much as possible memory =
before</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">rmdir'ing =
memcg. This would prevent from page cache accumulating.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""></div></blockquote><div><br class=3D""></div>Hmm, this =
might be an option. FWIW we have been using drop_caches to =
workaround.</div><div><br class=3D""><blockquote type=3D"cite" =
class=3D""><div class=3D""><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">BTW, this is cgroup v1 only, I'm working on a patch to bring =
this back</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">into v2 as =
discussed in<span class=3D"Apple-converted-space">&nbsp;</span></span><a =
href=3D"https://lkml.org/lkml/2019/1/3/484" style=3D"font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" =
class=3D"">https://lkml.org/lkml/2019/1/3/484</a><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px; text-decoration: none;" =
class=3D""><blockquote type=3D"cite" class=3D"">We think a fix is to =
create a kworker that scans all pagecaches and dentry caches etc. in the =
background, if a referenced memory cgroup is offline, try to drop the =
cache or move it to the parent cgroup. This kworker can wake up =
periodically, or upon memory cgroup offline event (or both).<br =
class=3D""></blockquote></blockquote><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">Reparenting has been deprecated for a long time. I don't =
think we want</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">to bring it =
back. Actually, css offline is handled by kworker now. I</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">proposed a =
patch to do force_empty in kworker, please see</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><a href=3D"https://lkml.org/lkml/2019/1/2/377" =
style=3D"font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;" =
class=3D"">https://lkml.org/lkml/2019/1/2/377</a><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""></div></blockquote><div><br class=3D""></div><div>Could =
you elaborate a bit about why reparenting is not a good =
idea?</div><div><br class=3D""></div><blockquote type=3D"cite" =
class=3D""><div class=3D""><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
class=3D""><br class=3D"">There is a similar problem in inode. After =
digging in ext4 code, we find that when creating inode cache, =
SLAB_ACCOUNT is used. In this case, inode will alloc in slab which =
belongs to the current memory cgroup. After this memory cgroup goes =
offline, this inode may be held by a dentry cache. If another process =
uses the same file. this inode will be held by that process, preventing =
the previous memory cgroup from being destroyed until this other process =
closes the file and drops the dentry cache.<br =
class=3D""></blockquote></blockquote><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">I'm not sure if you really need kmem charge. If not, you may =
try</span><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" =
class=3D"">cgroup.memory=3Dnokmem.</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""></div></blockquote><div><br =
class=3D""></div>A very good hint, we=E2=80=99ll investigate, =
thanks!</div><div><br class=3D""></div><div>Fam</div><div><br =
class=3D""><blockquote type=3D"cite" class=3D""><div class=3D""><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Menlo-Regular; =
font-size: 11px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Menlo-Regular; font-size: 11px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" =
class=3D"">Regards,</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">Yang</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Menlo-Regular; font-size: 11px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Menlo-Regular; font-size: 11px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; orphans: auto; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; widows: auto; word-spacing: =
0px; -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
class=3D""><br class=3D"">We still don't have a reasonable way to fix =
this.<br class=3D""><br =
class=3D"">Ideas?</blockquote></blockquote></div></blockquote></div><br =
class=3D""></body></html>=

--Apple-Mail=_71B2F602-8443-4CFB-A28C-E3CD2C057CD5--
