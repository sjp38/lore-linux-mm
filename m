Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96F036B0253
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 19:20:38 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l125so2551294ywb.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 16:20:38 -0700 (PDT)
Received: from mail-yw0-x22d.google.com (mail-yw0-x22d.google.com. [2607:f8b0:4002:c05::22d])
        by mx.google.com with ESMTPS id h68si353596yba.334.2016.07.06.16.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 16:20:37 -0700 (PDT)
Received: by mail-yw0-x22d.google.com with SMTP id l125so1180074ywb.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 16:20:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160622061356.GW30154@twins.programming.kicks-ass.net>
References: <56EAF98B.50605@profihost.ag> <20160317184514.GA6141@kroah.com>
 <56EDD206.3070202@suse.cz> <56EF15BB.3080509@profihost.ag>
 <20160320214130.GB23920@kroah.com> <56EFD267.9070609@profihost.ag>
 <20160321133815.GA14188@kroah.com> <573AB3BF.3030604@profihost.ag>
 <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
 <CAPerZE_WLYzrALa3YOzC2+NWr--1GL9na8WLssFBNbRsXcYMiA@mail.gmail.com> <20160622061356.GW30154@twins.programming.kicks-ass.net>
From: Campbell Steven <casteven@gmail.com>
Date: Thu, 7 Jul 2016 11:20:36 +1200
Message-ID: <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Greg KH <greg@kroah.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

On 22 June 2016 at 18:13, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, Jun 22, 2016 at 01:19:54PM +1200, Campbell Steven wrote:
>> >>>>>>> This suggests the CONFIG_FAIR_GROUP_SCHED version of task_h_load:
>> >>>>>>>
>> >>>>>>>         update_cfs_rq_h_load(cfs_rq);
>> >>>>>>>         return div64_ul(p->se.avg.load_avg * cfs_rq->h_load,
>> >>>>>>>                         cfs_rq_load_avg(cfs_rq) + 1);
>> >>>>>>>
>
>
> ---
> commit 8974189222159154c55f24ddad33e3613960521a
> Author: Peter Zijlstra <peterz@infradead.org>
> Date:   Thu Jun 16 10:50:40 2016 +0200
>
>     sched/fair: Fix cfs_rq avg tracking underflow
>
>     As per commit:
>
>       b7fa30c9cc48 ("sched/fair: Fix post_init_entity_util_avg() serialization")
>
>     > the code generated from update_cfs_rq_load_avg():
>     >
>     >   if (atomic_long_read(&cfs_rq->removed_load_avg)) {
>     >           s64 r = atomic_long_xchg(&cfs_rq->removed_load_avg, 0);
>     >           sa->load_avg = max_t(long, sa->load_avg - r, 0);
>     >           sa->load_sum = max_t(s64, sa->load_sum - r * LOAD_AVG_MAX, 0);
>     >           removed_load = 1;
>     >   }


Hi Peter,

I just wanted to report back to say thanks for this, and we have (and
others) have tested this out in 4.7 rc6 and have not been able to
repeat the issue. It seems that anyone running busy ceph osd's or high
load KVM instances is able to trigger this on a dual socket box pretty
easily.

Since these early reports from Stefan and I it looks like it's been
hit but alot more folks now so I'd like to ask what the process is for
getting this backported into 4.6, 4.5 and 4.4 as in our testing all
those versions for their latest point release seem to have the same
problem.

Thanks

Campbell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
