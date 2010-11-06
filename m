Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 24A246B00B9
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 13:20:12 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oA6HJxEq031668
	for <linux-mm@kvack.org>; Sat, 6 Nov 2010 10:20:02 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by kpbe17.cbf.corp.google.com with ESMTP id oA6HJu6h026544
	for <linux-mm@kvack.org>; Sat, 6 Nov 2010 10:19:58 -0700
Received: by qyk32 with SMTP id 32so39755qyk.14
        for <linux-mm@kvack.org>; Sat, 06 Nov 2010 10:19:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101106010357.GD23393@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com> <20101106010357.GD23393@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Sat, 6 Nov 2010 10:19:35 -0700
Message-ID: <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
Subject: Re: [PATCH] memcg: use do_div to divide s64 in 32 bit machine.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: hannes@cmpxchg.org
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 5, 2010 at 6:03 PM,  <hannes@cmpxchg.org> wrote:
> On Sat, Nov 06, 2010 at 01:08:53AM +0900, Minchan Kim wrote:
>> Use do_div to divide s64 value. Otherwise, build would be failed
>> like Dave Young reported.
>
> I thought about that too, but then I asked myself why you would want
> to represent a number of pages as signed 64bit type, even on 32 bit?

I think the reason that 64 byte type is used for page count in
memcontrol.c is because the low level res_counter primitives operate
on 64 bit counters, even on 32 bit machines.

> Isn't the much better fix to get the types right instead?
>

I agree that consistent types between mem_cgroup_dirty_info() and
global_dirty_info() is important.  There seems to be a lot of usage of
s64 for page counts in memcontrol.c, which I think is due to the
res_counter types.  I think these s64 be switched to unsigned long
rather to be consistent with the rest of mm code.  It looks like this
will be a clean patch, except for the lowest level where
res_counter_read_u64() is used, where some casting may be needed.

I'll post a patch for that change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
