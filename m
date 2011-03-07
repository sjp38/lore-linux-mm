Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 32FCF8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 06:43:54 -0500 (EST)
Message-ID: <4D74C531.7070305@cn.fujitsu.com>
Date: Mon, 07 Mar 2011 19:44:49 +0800
From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
References: <1298888105-3778-1-git-send-email-arighi@develer.com> <20110228230114.GB20845@redhat.com> <20110302132830.GB2061@linux.develer.com> <20110302214705.GD2547@redhat.com> <20110306155247.GA1687@linux.develer.com> <4D7489BF.9030808@cn.fujitsu.com> <20110307113411.GA4485@linux.develer.com>
In-Reply-To: <20110307113411.GA4485@linux.develer.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrea Righi wrote:
> On Mon, Mar 07, 2011 at 03:31:11PM +0800, Gui Jianfeng wrote:
>> Andrea Righi wrote:
>>> On Wed, Mar 02, 2011 at 04:47:05PM -0500, Vivek Goyal wrote:
>>>> On Wed, Mar 02, 2011 at 02:28:30PM +0100, Andrea Righi wrote:
>>>>> On Mon, Feb 28, 2011 at 06:01:14PM -0500, Vivek Goyal wrote:
>>>>>> On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
>>>>>>> Overview
>>>>>>> =3D=3D=3D=3D=3D=3D=3D=3D
>>>>>>> Currently the blkio.throttle controller only support synchronous IO=
 requests.
>>>>>>> This means that we always look at the current task to identify the =
"owner" of
>>>>>>> each IO request.
>>>>>>>
>>>>>>> However dirty pages in the page cache can be wrote to disk asynchro=
nously by
>>>>>>> the per-bdi flusher kernel threads or by any other thread in the sy=
stem,
>>>>>>> according to the writeback policy.
>>>>>>>
>>>>>>> For this reason the real writes to the underlying block devices may
>>>>>>> occur in a different IO context respect to the task that originally
>>>>>>> generated the dirty pages involved in the IO operation. This makes =
the
>>>>>>> tracking and throttling of writeback IO more complicate respect to =
the
>>>>>>> synchronous IO from the blkio controller's perspective.
>>>>>>>
>>>>>>> Proposed solution
>>>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>>>> In the previous patch set http://lwn.net/Articles/429292/ I propose=
d to resolve
>>>>>>> the problem of the buffered writes limitation by tracking the owner=
ship of all
>>>>>>> the dirty pages in the system.
>>>>>>>
>>>>>>> This would allow to always identify the owner of each IO operation =
at the block
>>>>>>> layer and apply the appropriate throttling policy implemented by the
>>>>>>> blkio.throttle controller.
>>>>>>>
>>>>>>> This solution makes the blkio.throttle controller to work as expect=
ed also for
>>>>>>> writeback IO, but it does not resolve the problem of faster cgroups=
 getting
>>>>>>> blocked by slower cgroups (that would expose a potential way to cre=
ate DoS in
>>>>>>> the system).
>>>>>>>
>>>>>>> In fact, at the moment critical IO requests (that have dependency w=
ith other IO
>>>>>>> requests made by other cgroups) and non-critical requests are mixed=
 together at
>>>>>>> the filesystem layer in a way that throttling a single write reques=
t may stop
>>>>>>> also other requests in the system, and at the block layer it's not =
possible to
>>>>>>> retrieve such informations to make the right decision.
>>>>>>>
>>>>>>> A simple solution to this problem could be to just limit the rate o=
f async
>>>>>>> writes at the time a task is generating dirty pages in the page cac=
he. The
>>>>>>> big advantage of this approach is that it does not need the overhea=
d of
>>>>>>> tracking the ownership of the dirty pages, because in this way from=
 the blkio
>>>>>>> controller perspective all the IO operations will happen from the p=
rocess
>>>>>>> context: writes in memory and synchronous reads from the block devi=
ce.
>>>>>>>
>>>>>>> The drawback of this approach is that the blkio.throttle controller=
 becomes a
>>>>>>> little bit leaky, because with this solution the controller is stil=
l affected
>>>>>>> by the IO spikes during the writeback of dirty pages executed by th=
e kernel
>>>>>>> threads.
>>>>>>>
>>>>>>> Probably an even better approach would be to introduce the tracking=
 of the
>>>>>>> dirty page ownership to properly account the cost of each IO operat=
ion at the
>>>>>>> block layer and apply the throttling of async writes in memory only=
 when IO
>>>>>>> limits are exceeded.
>>>>>> Andrea, I am curious to know more about it third option. Can you giv=
e more
>>>>>> details about accouting in block layer but throttling in memory. So =
say=20
>>>>>> a process starts IO, then it will still be in throttle limits at blo=
ck
>>>>>> layer (because no writeback has started), then the process will write
>>>>>> bunch of pages in cache. By the time throttle limits are crossed at
>>>>>> block layer, we already have lots of dirty data in page cache and
>>>>>> throttling process now is already late?
>>>>> Charging the cost of each IO operation at the block layer would allow
>>>>> tasks to write in memory at the maximum speed. Instead, with the 3rd
>>>>> approach, tasks are forced to write in memory at the rate defined by =
the
>>>>> blkio.throttle.write=5F*=5Fdevice (or blkio.throttle.async.write=5F*=
=5Fdevice).
>>>>>
>>>>> When we'll have the per-cgroup dirty memory accounting and limiting
>>>>> feature, with this approach each cgroup could write to its dirty memo=
ry
>>>>> quota at the maximum rate.
>>>> Ok, so this is option 3 which you have already implemented in this
>>>> patchset.=20
>>>>
>>>> I guess then I am confused with option 2. Can you elaborate a little
>>>> more there.
>>> With option 3, we can just limit the rate at which dirty pages are
>>> generated in memory. And this can be done introducing the files
>>> blkio.throttle.async.write=5Fbps/iops=5Fdevice.
>>>
>>> At the moment in blk=5Fthrotl=5Fbio() we charge the dispatched bytes/io=
ps
>>> =5Fand=5F we check if the bio can be dispatched. These two distinct
>>> operations are now done by the same function.
>>>
>>> With option 2, I'm proposing to split these two operations and place
>>> throtl=5Fcharge=5Fio() at the block layer in =5F=5Fgeneric=5Fmake=5Freq=
uest() and an
>>> equivalent of tg=5Fmay=5Fdispatch=5Fbio() (maybe a better name would be
>>> blk=5Fis=5Fthrottled()) at the page cache layer, in
>>> balance=5Fdirty=5Fpages=5Fratelimited=5Fnr():
>>>
>>> A prototype for blk=5Fis=5Fthrottled() could be the following:
>>>
>>> bool blk=5Fis=5Fthrottled(void);
>>>
>>> This means in balance=5Fdirty=5Fpages=5Fratelimited=5Fnr() we won't cha=
rge any
>>> bytes/iops to the cgroup, but we'll just check if the limits are
>>> exceeded. And stop it in that case, so that no more dirty pages can be
>>> generated by this cgroup.
>>>
>>> Instead at the block layer WRITEs will be always dispatched in
>>> blk=5Fthrotl=5Fbio() (tg=5Fmay=5Fdispatch=5Fbio() will always return tr=
ue), but
>>> the throtl=5Fcharge=5Fio() would charge the cost of the IO operation to=
 the
>>> right cgroup.
>>>
>>> To summarize:
>>>
>>> =5F=5Fgeneric=5Fmake=5Frequest():
>>> 	blk=5Fthrotl=5Fbio(q, &bio);
>>>
>>> balance=5Fdirty=5Fpages=5Fratelimited=5Fnr():
>>> 	if (blk=5Fis=5Fthrottled())
>>> 		// add the current task into a per-group wait queue and
>>> 		// wake up once this cgroup meets its quota
>>>
>>> What do you think?
>> Hi Andrea,
>>
>> This means when you throttle writes, the reads issued by this task are a=
lso throttled?
>>
>> Thanks,
>> Gui
>=20
> Exactly, we're treating the throttling of READs and WRITEs in two
> different ways.
>=20
> READs will be always throttled synchronously in the
> =5F=5Fgeneric=5Fmake=5Frequest() -> blk=5Fthrotl=5Fbio() path.

Andrea=EF=BC=8C

I means If the task exceeds write limit, this task will be put to sleep, ri=
ght?
So It doesn't get a chance to issue read requests.

Gui

>=20
> -Andrea
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--=20
Regards
Gui Jianfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
