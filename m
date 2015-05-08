Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA6A6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 20:04:28 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so29342616qge.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 17:04:28 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id f46si3759934qgd.11.2015.05.07.17.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 17:04:27 -0700 (PDT)
Received: by qkhg7 with SMTP id g7so38864953qkh.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 17:04:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150507154212.GA12245@htj.duckdns.org>
References: <20150507064557.GA26928@july>
	<20150507154212.GA12245@htj.duckdns.org>
Date: Fri, 8 May 2015 09:04:26 +0900
Message-ID: <CAH9JG2UAVRgX0Mg0d7WgG0URpkgu4q_bbNMXyOOEh9WFPztppQ@mail.gmail.com>
Subject: Re: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen processes
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "\\Rafael J. Wysocki\\" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>

On Fri, May 8, 2015 at 12:42 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Thu, May 07, 2015 at 03:45:57PM +0900, Kyungmin Park wrote:
>> From: Kyungmin Park <kyungmin.park@samsung.com>
>>
>> Some platform uses freezer cgroup for speicial purpose to schedule out some applications. but after suspend & resume, these processes are thawed and running.
>
> They shouldn't be able to leave the freezer tho.  Resuming does wake
> up all tasks but freezing() test would still evaulate to true for the
> ones frozen by cgroup freezer and they will stay inside the freezer.
>
>> but it's inteneded and don't need to thaw it.
>>
>> To avoid it, does it possible to modify resume code and don't thaw it when resume? does it resonable?
>
> I need to think more about it but as an *optimization* we can add
> freezing() test before actually waking tasks up during resume, but can
> you please clarify what you're seeing?

The mobile application has life cycle and one of them is 'suspend'
state. it's different from 'pause' or 'background'.
if there are some application and enter go 'suspend' state. all
behaviors are stopped and can't do anything. right it's suspended. but
after system suspend & resume, these application is thawed and
running. even though system know it's suspended.

We made some test application, print out some message within infinite
loop. when it goes 'suspend' state. nothing is print out. but after
system suspend & resume, it prints out again. that's not desired
behavior. and want to address it.

frozen user processes should be remained as frozen while system
suspend & resume.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
