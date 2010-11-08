Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98D286B0071
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 14:01:26 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oA8J1K5P010699
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 11:01:21 -0800
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by hpaq5.eem.corp.google.com with ESMTP id oA8J193P011525
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 11:01:19 -0800
Received: by pxi3 with SMTP id 3so1683156pxi.40
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 11:01:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101108154524.GA9530@localhost>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
 <20101106010357.GD23393@cmpxchg.org> <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
 <20101107215030.007259800@cmpxchg.org> <20101107220353.964566018@cmpxchg.org>
 <AANLkTinh+LEQYGe9dDOKBwNnVVXMiFYpDqkqvvpNe9H8@mail.gmail.com>
 <20101108093715.GJ23393@cmpxchg.org> <20101108154524.GA9530@localhost>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 8 Nov 2010 11:00:56 -0800
Message-ID: <AANLkTim6ATcv_MOi0JJorH-wpTk1bUyyeAhbrUkyNimT@mail.gmail.com>
Subject: Re: memcg writeout throttling, was: [patch 4/4] memcg: use native
 word page statistics counters
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 7:45 AM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Mon, Nov 08, 2010 at 05:37:16PM +0800, Johannes Weiner wrote:
>> On Mon, Nov 08, 2010 at 09:07:35AM +0900, Minchan Kim wrote:
>> > BTW, let me ask a question.
>> > dirty_writeback_pages seems to be depends on mem_cgroup_page_stat's
>> > result(ie, negative) for separate global and memcg.
>> > But mem_cgroup_page_stat could return negative value by per-cpu as
>> > well as root cgroup.
>> > If I understand right, Isn't it a problem?
>>
>> Yes, the numbers are not reliable and may be off by some. =A0It appears
>> to me that the only sensible interpretation of a negative sum is to
>> assume zero, though. =A0So to be honest, I don't understand the fallback
>> to global state when the local state fluctuates around low values.
>
> Agreed. It does not make sense to compare values from different domains.
>
> The bdi stats use percpu_counter_sum_positive() which never return
> negative values. It may be suitable for memcg page counts, too.
>
>> This function is also only used in throttle_vm_writeout(), where the
>> outcome is compared to the global dirty threshold. =A0So using the
>> number of writeback pages _from the current cgroup_ and falling back
>> to global writeback pages when this number is low makes no sense to me
>> at all.
>>
>> I looks like it should rather compare the cgroup state with the cgroup
>> limit, and the global state with the global limit.
>
> Right.
>
>> Can somebody explain the reasoning behind this? =A0And in case it makes
>> sense after all, put a comment into this function?
>
> It seems a better match to test sc->mem_cgroup rather than
> mem_cgroup_from_task(current). The latter could make mismatches. When
> someone is changing the memcg limits and hence triggers memcg
> reclaims, the current task is actually the (unrelated) shell. It's
> also possible for the memcg task to trigger _global_ direct reclaim.

Good point.  I am writing a patch that will pass mem_cgroup from
sc->mem_cgroup into mem_cgroup_page_stat() rather than using
mem_cgroup_from_task(current).  I will post this patch in a few hours.

I will also fix the negative value issue in mem_cgroup_page_stat().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
