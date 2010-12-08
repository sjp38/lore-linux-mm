Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9BB6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 20:24:21 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oB81OEjf027619
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 17:24:14 -0800
Received: from ywl5 (ywl5.prod.google.com [10.192.12.5])
	by wpaz33.hot.corp.google.com with ESMTP id oB81NoUo000916
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 17:24:13 -0800
Received: by ywl5 with SMTP id 5so399208ywl.4
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 17:24:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
	<20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 7 Dec 2010 17:24:12 -0800
Message-ID: <AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 7, 2010 at 4:39 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 7 Dec 2010 09:28:01 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>
>> Potentially there will
>> > also be a very large number of new IO sources. I confess I haven't rea=
d the
>> > thread yet so maybe this has already been thought of but it might make=
 sense
>> > to have a 1:N relationship between kswapd and memcgroups and cycle bet=
ween
>> > containers. The difficulty will be a latency between when kswapd wakes=
 up
>> > and when a particular container is scanned. The closer the ratio is to=
 1:1,
>> > the less the latency will be but the higher the contenion on the LRU l=
ock
>> > and IO will be.
>>
>> No, we weren't talked about the mapping anywhere in the thread. Having
>> many kswapd threads
>> at the same time isn't a problem as long as no locking contention (
>> ext, 1k kswapd threads on
>> 1k fake numa node system). So breaking the zone->lru_lock should work.
>>
>
> That's me who make zone->lru_lock be shared. And per-memcg lock will make=
s
> the maintainance of memcg very bad. That will add many races.
> Or we need to make memcg's LRU not synchronized with zone's LRU, IOW, we =
need
> to have completely independent LRU.
>
> I'd like to limit the number of kswapd-for-memcg if zone->lru lock conten=
tion
> is problematic. memcg _can_ work without background reclaim.

>
> How about adding per-node kswapd-for-memcg it will reclaim pages by a mem=
cg's
> request ? as
>
> =A0 =A0 =A0 =A0memcg_wake_kswapd(struct mem_cgroup *mem)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid =3D select_victim_node=
(mem);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* ask kswapd to reclaim m=
emcg's memory */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D memcg_kswapd_queue=
_work(nid, mem); /* may return -EBUSY if very busy*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} while()
> =A0 =A0 =A0 =A0}
>
> This will make lock contention minimum. Anyway, using too much cpu for th=
is
> unnecessary_but_good_for_performance_function is bad. Throttoling is requ=
ired.

I don't see the problem of one-kswapd-per-cgroup here since there will
be no performance cost if they are not running.

I haven't measured the lock contention and cputime for each kswapd
running. Theoretically it would be a problem
if thousands of cgroups are configured on the the host and all of them
are under memory pressure.

We can either optimize the locking or make each kswapd smarter (hold
the lock less time). My current plan is to have the
one-kswapd-per-cgroup on the V2 patch w/ select_victim_node, and the
optimization for this comes as following patchset.

--Ying




>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
