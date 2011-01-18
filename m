Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E09696B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 16:10:46 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p0ILAfp1008512
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 13:10:41 -0800
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by wpaz5.hot.corp.google.com with ESMTP id p0ILAJlq009588
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 13:10:40 -0800
Received: by qwk4 with SMTP id 4so69697qwk.4
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 13:10:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-3-git-send-email-yinghan@google.com>
	<20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
	<alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com>
Date: Tue, 18 Jan 2011 13:10:39 -0800
Message-ID: <AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 12:36 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Tue, 18 Jan 2011, Ying Han wrote:
>
>> I agree that "min_free_kbytes" concept doesn't apply well since there
>> is no notion of "reserved pool" in memcg. I borrowed it at the
>> beginning is to add a tunable to the per-memcg watermarks besides the
>> hard_limit.
>
> You may want to add a small amount of memory that a memcg may allocate
> from in oom conditions, however: memory reserves are allocated per-zone
> and if the entire system is oom and that includes several dozen memcgs,
> for example, they could all be contending for the same memory reserves.
> It would be much easier to deplete all reserves since you would have
> several tasks allowed to allocate from this pool: that's not possible
> without memcg since the oom killer is serialized on zones and does not
> kill a task if another oom killed task is already detected in the
> tasklist.

so something like per-memcg min_wmark which also needs to be reserved upfro=
nt?

> I think it would be very trivial to DoS the entire machine in this way:
> set up a thousand memcgs with tasks that have core_state, for example, an=
d
> trigger them to all allocate anonymous memory up to their hard limit so
> they oom at the same time. =A0The machine should livelock with all zones
> having 0 pages free.
>
>> I read the
>> patch posted from Satoru Moriya "Tunable watermarks", and introducing
>> the per-memcg-per-watermark tunable
>> sounds good to me. Might consider adding it to the next post.
>>
>
> Those tunable watermarks were nacked for a reason: they are internal to
> the VM and should be set to sane values by the kernel with no intevention
> needed by userspace. =A0You'd need to show why a memcg would need a user =
to
> tune its watermarks to trigger background reclaim and why that's not
> possible by the kernel and how this is a special case in comparsion to th=
e
> per-zone watermarks used by the VM.

KAMEZAWA gave an example on his early post, which some enterprise user
like to keep fixed amount of free pages
regardless of the hard_limit.

Since setting the wmarks has impact on the reclaim behavior of each
memcg,  adding this flexibility helps the system where it like to
treat memcg differently based on the priority.

--Ying


>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
