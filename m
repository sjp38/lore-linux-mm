Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF3A8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 22:18:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so11549656pfr.6
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 19:18:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 70sor9924009pgf.87.2019.01.18.19.18.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 19:18:05 -0800 (PST)
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Message-Id: <518EEF18-BD87-4D9C-AE03-43F42150161D@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_3A858F5B-C03C-4AEF-A631-D4E5AFD3AD11"
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
Date: Sat, 19 Jan 2019 11:17:56 +0800
In-Reply-To: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
 <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
 <CAHbLzkpHst6bA=eVjoHRFuCuOfo8kKnCPE7Tg4voaJ_kwruVqw@mail.gmail.com>
 <C7C72217-D4AF-474C-A98E-975E389BC85C@bytedance.com>
 <CAHbLzkoy02EvyrDv3v5zFpFRZ0XCg0HZr85nG=rge5nPPGHqjA@mail.gmail.com>
 <99AFB530-E90E-4784-B199-FA3F91171649@bytedance.com>
 <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com


--Apple-Mail=_3A858F5B-C03C-4AEF-A631-D4E5AFD3AD11
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Hi Yang Shi:
We had try your patch. But  still there are lots of memcgroup can=E2=80=99=
t be release.
We guest maybe trylock(pagecache) fail may cause of that.
So we think we should try more force empty  in another time.
Inspired by you, I made a series patchs that are valid in our business =
sysetem. Memcgroup has decrease to 100 instead of 100000.

We think if memcgroup didn=E2=80=99t release. We should trigger force =
empty in 1 2  4 8 16 =E2=80=A6 second. That will get better chance to =
release this memcgroup.



bytedance.net
=E6=AE=B5=E7=86=8A=E6=98=A5
duanxiongchun@bytedance.com




> On Jan 17, 2019, at 1:06 PM, Yang Shi <shy828301@gmail.com> wrote:
>=20
> On Wed, Jan 16, 2019 at 6:41 PM Fam Zheng <zhengfeiran@bytedance.com =
<mailto:zhengfeiran@bytedance.com>> wrote:
>>=20
>>=20
>>=20
>>> On Jan 17, 2019, at 05:06, Yang Shi <shy828301@gmail.com> wrote:
>>>=20
>>> On Tue, Jan 15, 2019 at 7:52 PM Fam Zheng =
<zhengfeiran@bytedance.com> wrote:
>>>>=20
>>>>=20
>>>>=20
>>>>> On Jan 16, 2019, at 08:50, Yang Shi <shy828301@gmail.com> wrote:
>>>>>=20
>>>>> On Thu, Jan 10, 2019 at 12:30 AM Fam Zheng =
<zhengfeiran@bytedance.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>>> On Jan 10, 2019, at 13:36, Yang Shi <shy828301@gmail.com> wrote:
>>>>>>>=20
>>>>>>> On Sun, Jan 6, 2019 at 9:10 PM Fam Zheng =
<zhengfeiran@bytedance.com> wrote:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> =
wrote:
>>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>> drop_caches would drop all page caches globally. You may not =
want to
>>>>>>>>> drop the page caches used by other memcgs.
>>>>>>>>=20
>>>>>>>> We=E2=80=99ve tried your async force_empty patch (with a =
modification to default it to true to make it transparently enabled for =
the sake of testing), and for the past few days the stale mem cgroups =
still accumulate, up to 40k.
>>>>>>>>=20
>>>>>>>> We=E2=80=99ve double checked that the force_empty routines are =
invoked when a mem cgroup is offlined. But this doesn=E2=80=99t look =
very effective so far. Because, once we do `echo 1 > =
/proc/sys/vm/drop_caches`, all the groups immediately go away.
>>>>>>>>=20
>>>>>>>> This is a bit unexpected.
>>>>>>>>=20
>>>>>>>> Yang, could you hint what are missing in the force_empty =
operation, compared to a blanket drop cache?
>>>>>>>=20
>>>>>>> Drop caches does invalidate pages inode by inode. But, memcg
>>>>>>> force_empty does call memcg direct reclaim.
>>>>>>=20
>>>>>> But force_empty touches things that drop_caches doesn=E2=80=99t? =
If so then maybe combining both approaches is more reliable. Since like =
you said,
>>>>>=20
>>>>> AFAICS, force_empty may unmap pages, but drop_caches doesn't.
>>>>>=20
>>>>>> dropping _all_ pages is usually too much thus not desired, we may =
want to somehow limit the dropped caches to those that are in the memory =
cgroup in question. What do you think?
>>>>>=20
>>>>> This is what force_empty is supposed to do.  But, as your test =
shows
>>>>> some page cache may still remain after force_empty, then cause =
offline
>>>>> memcgs accumulated.  I haven't figured out what happened.  You may =
try
>>>>> what Michal suggested.
>>>>=20
>>>> None of the existing patches helped so far, but we suspect that the =
pages cannot be locked at the force_empty moment. We have being working =
on a =E2=80=9Cretry=E2=80=9D patch which does solve the problem. We=E2=80=99=
ll do more tracing (to have a better understanding of the issue) and =
post the findings and/or the patch later. Thanks.
>>>=20
>>> You mean it solves the problem by retrying more times?  Actually, =
I'm
>>> not sure if you have swap setup in your test, but force_empty does =
do
>>> swap if swap is on. This may cause it can't reclaim all the page =
cache
>>> in 5 retries.  I have a patch within that series to skip swap.
>>=20
>> Basically yes, retrying solves the problem. But compared to immediate =
retries, a scheduled retry in a few seconds is much more effective.
>=20
> This may suggest doing force_empty in a worker is more effective in
> fact. Not sure if this is good enough to convince Johannes or not.
>=20
>>=20
>> We don=E2=80=99t have swap on.
>>=20
>> What do you mean by 5 retries? I=E2=80=99m still a bit lost in the =
LRU code and patches.
>=20
> MEM_CGROUP_RECLAIM_RETRIES is 5.
>=20
> Yang
>=20
>>=20
>>>=20
>>> Yang
>>>=20
>>>>=20
>>>> Fam
>>>>=20
>>>>>=20
>>>>> Yang
>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>>>=20
>>>>>>> Offlined memcgs will not go away if there is still page charged. =
Maybe
>>>>>>> relate to per cpu memcg stock. I recall there are some commits =
which
>>>>>>> do solve the per cpu page counter cache problem.
>>>>>>>=20
>>>>>>> 591edfb10a94 mm: drain memcg stocks on css offlining
>>>>>>> d12c60f64cf8 mm: memcontrol: drain memcg stock on force_empty
>>>>>>> bb4a7ea2b144 mm: memcontrol: drain stocks on resize limit
>>>>>>>=20
>>>>>>> Not sure if they would help out.
>>>>>>=20
>>>>>> These are all in 4.20, which is tested but not helpful.
>>>>>>=20
>>>>>> Fam


--Apple-Mail=_3A858F5B-C03C-4AEF-A631-D4E5AFD3AD11
Content-Type: multipart/mixed;
	boundary="Apple-Mail=_08CA4644-2FA6-4C7F-876E-CC1804D508E6"


--Apple-Mail=_08CA4644-2FA6-4C7F-876E-CC1804D508E6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">Hi =
Yang Shi:<div class=3D"">We had try your patch. But &nbsp;still there =
are lots of memcgroup can=E2=80=99t be release.</div><div class=3D"">We =
guest maybe trylock(pagecache) fail may cause of that.</div><div =
class=3D"">So we think we should try more force empty &nbsp;in another =
time.</div><div class=3D"">Inspired by you, I made a series patchs that =
are valid in our business sysetem. Memcgroup has decrease to 100 instead =
of 100000.</div><div class=3D""><div class=3D""><br class=3D""></div><div =
class=3D"">We think if memcgroup didn=E2=80=99t release. We should =
trigger force empty in 1 2 &nbsp;4 8 16 =E2=80=A6 second. That will get =
better chance to release this memcgroup.</div><div class=3D""><br =
class=3D""></div><div class=3D""></div></div></body></html>=

--Apple-Mail=_08CA4644-2FA6-4C7F-876E-CC1804D508E6
Content-Disposition: attachment;
	filename=memcgroup_release.patch.tar.gz
Content-Type: application/x-gzip;
	x-unix-mode=0644;
	name="memcgroup_release.patch.tar.gz"
Content-Transfer-Encoding: base64

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
eXlO5QB4AAA=
--Apple-Mail=_08CA4644-2FA6-4C7F-876E-CC1804D508E6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><div =
class=3D""><div class=3D""></div><div class=3D""><br =
class=3D""></div></div><div class=3D""><div class=3D"">
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
class=3D"">On Jan 17, 2019, at 1:06 PM, Yang Shi &lt;<a =
href=3D"mailto:shy828301@gmail.com" class=3D"">shy828301@gmail.com</a>&gt;=
 wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span=
 style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">On Wed, Jan 16, 2019 at 6:41 PM =
Fam Zheng &lt;</span><a href=3D"mailto:zhengfeiran@bytedance.com" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;" =
class=3D"">zhengfeiran@bytedance.com</a><span style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">&gt; wrote:</span><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br class=3D""><br class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D"">On Jan 17, 2019, at =
05:06, Yang Shi &lt;<a href=3D"mailto:shy828301@gmail.com" =
class=3D"">shy828301@gmail.com</a>&gt; wrote:<br class=3D""><br =
class=3D"">On Tue, Jan 15, 2019 at 7:52 PM Fam Zheng &lt;<a =
href=3D"mailto:zhengfeiran@bytedance.com" =
class=3D"">zhengfeiran@bytedance.com</a>&gt; wrote:<br =
class=3D""><blockquote type=3D"cite" class=3D""><br class=3D""><br =
class=3D""><br class=3D""><blockquote type=3D"cite" class=3D"">On Jan =
16, 2019, at 08:50, Yang Shi &lt;<a href=3D"mailto:shy828301@gmail.com" =
class=3D"">shy828301@gmail.com</a>&gt; wrote:<br class=3D""><br =
class=3D"">On Thu, Jan 10, 2019 at 12:30 AM Fam Zheng &lt;<a =
href=3D"mailto:zhengfeiran@bytedance.com" =
class=3D"">zhengfeiran@bytedance.com</a>&gt; wrote:<br =
class=3D""><blockquote type=3D"cite" class=3D""><br class=3D""><br =
class=3D""><br class=3D""><blockquote type=3D"cite" class=3D"">On Jan =
10, 2019, at 13:36, Yang Shi &lt;<a href=3D"mailto:shy828301@gmail.com" =
class=3D"">shy828301@gmail.com</a>&gt; wrote:<br class=3D""><br =
class=3D"">On Sun, Jan 6, 2019 at 9:10 PM Fam Zheng &lt;<a =
href=3D"mailto:zhengfeiran@bytedance.com" =
class=3D"">zhengfeiran@bytedance.com</a>&gt; wrote:<br =
class=3D""><blockquote type=3D"cite" class=3D""><br class=3D""><br =
class=3D""><br class=3D""><blockquote type=3D"cite" class=3D"">On Jan 5, =
2019, at 03:36, Yang Shi &lt;<a href=3D"mailto:shy828301@gmail.com" =
class=3D"">shy828301@gmail.com</a>&gt; wrote:<br class=3D""><br =
class=3D""><br class=3D"">drop_caches would drop all page caches =
globally. You may not want to<br class=3D"">drop the page caches used by =
other memcgs.<br class=3D""></blockquote><br class=3D"">We=E2=80=99ve =
tried your async force_empty patch (with a modification to default it to =
true to make it transparently enabled for the sake of testing), and for =
the past few days the stale mem cgroups still accumulate, up to 40k.<br =
class=3D""><br class=3D"">We=E2=80=99ve double checked that the =
force_empty routines are invoked when a mem cgroup is offlined. But this =
doesn=E2=80=99t look very effective so far. Because, once we do `echo 1 =
&gt; /proc/sys/vm/drop_caches`, all the groups immediately go away.<br =
class=3D""><br class=3D"">This is a bit unexpected.<br class=3D""><br =
class=3D"">Yang, could you hint what are missing in the force_empty =
operation, compared to a blanket drop cache?<br =
class=3D""></blockquote><br class=3D"">Drop caches does invalidate pages =
inode by inode. But, memcg<br class=3D"">force_empty does call memcg =
direct reclaim.<br class=3D""></blockquote><br class=3D"">But =
force_empty touches things that drop_caches doesn=E2=80=99t? If so then =
maybe combining both approaches is more reliable. Since like you =
said,<br class=3D""></blockquote><br class=3D"">AFAICS, force_empty may =
unmap pages, but drop_caches doesn't.<br class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D"">dropping _all_ pages is =
usually too much thus not desired, we may want to somehow limit the =
dropped caches to those that are in the memory cgroup in question. What =
do you think?<br class=3D""></blockquote><br class=3D"">This is what =
force_empty is supposed to do. &nbsp;But, as your test shows<br =
class=3D"">some page cache may still remain after force_empty, then =
cause offline<br class=3D"">memcgs accumulated. &nbsp;I haven't figured =
out what happened. &nbsp;You may try<br class=3D"">what Michal =
suggested.<br class=3D""></blockquote><br class=3D"">None of the =
existing patches helped so far, but we suspect that the pages cannot be =
locked at the force_empty moment. We have being working on a =E2=80=9Cretr=
y=E2=80=9D patch which does solve the problem. We=E2=80=99ll do more =
tracing (to have a better understanding of the issue) and post the =
findings and/or the patch later. Thanks.<br class=3D""></blockquote><br =
class=3D"">You mean it solves the problem by retrying more times? =
&nbsp;Actually, I'm<br class=3D"">not sure if you have swap setup in =
your test, but force_empty does do<br class=3D"">swap if swap is on. =
This may cause it can't reclaim all the page cache<br class=3D"">in 5 =
retries. &nbsp;I have a patch within that series to skip swap.<br =
class=3D""></blockquote><br class=3D"">Basically yes, retrying solves =
the problem. But compared to immediate retries, a scheduled retry in a =
few seconds is much more effective.<br class=3D""></blockquote><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">This may suggest doing =
force_empty in a worker is more effective in</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">fact. Not sure if this is good =
enough to convince Johannes or not.</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><br class=3D"">We don=E2=80=99t have =
swap on.<br class=3D""><br class=3D"">What do you mean by 5 retries? =
I=E2=80=99m still a bit lost in the LRU code and patches.<br =
class=3D""></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">MEM_CGROUP_RECLAIM_RETRIES is 5.</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">Yang</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" =
class=3D""><blockquote type=3D"cite" style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><br =
class=3D""><blockquote type=3D"cite" class=3D""><br class=3D"">Yang<br =
class=3D""><br class=3D""><blockquote type=3D"cite" class=3D""><br =
class=3D"">Fam<br class=3D""><br class=3D""><blockquote type=3D"cite" =
class=3D""><br class=3D"">Yang<br class=3D""><br class=3D""><blockquote =
type=3D"cite" class=3D""><br class=3D""><br class=3D""><blockquote =
type=3D"cite" class=3D""><br class=3D"">Offlined memcgs will not go away =
if there is still page charged. Maybe<br class=3D"">relate to per cpu =
memcg stock. I recall there are some commits which<br class=3D"">do =
solve the per cpu page counter cache problem.<br class=3D""><br =
class=3D"">591edfb10a94 mm: drain memcg stocks on css offlining<br =
class=3D"">d12c60f64cf8 mm: memcontrol: drain memcg stock on =
force_empty<br class=3D"">bb4a7ea2b144 mm: memcontrol: drain stocks on =
resize limit<br class=3D""><br class=3D"">Not sure if they would help =
out.<br class=3D""></blockquote><br class=3D"">These are all in 4.20, =
which is tested but not helpful.<br class=3D""><br =
class=3D"">Fam</blockquote></blockquote></blockquote></blockquote></blockq=
uote></div></blockquote></div><br class=3D""></div></body></html>=

--Apple-Mail=_08CA4644-2FA6-4C7F-876E-CC1804D508E6--

--Apple-Mail=_3A858F5B-C03C-4AEF-A631-D4E5AFD3AD11--
