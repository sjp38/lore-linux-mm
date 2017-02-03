Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF4F6B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 00:26:44 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id g13so8664133otd.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 21:26:44 -0800 (PST)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id l125si10393547oif.45.2017.02.02.21.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 21:26:43 -0800 (PST)
Received: by mail-oi0-x241.google.com with SMTP id u143so674365oif.3
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 21:26:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170202160145.GK22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz> <20170202104808.GG22806@dhcp22.suse.cz>
 <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
 <20170202115222.GH22806@dhcp22.suse.cz> <CAOaiJ-=pCUzaVbte-+QiQoN_XtB0KFbcB40yjU9r7OV8VOkmFg@mail.gmail.com>
 <20170202160145.GK22806@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Fri, 3 Feb 2017 10:56:42 +0530
Message-ID: <CAOaiJ-=O_SkaYry4Lay8LidvC11sTukchE_p6P4mKm=fgJz1Dg@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Feb 2, 2017 at 9:31 PM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Why would you like to chose and kill a task when the slab reclaim can
> still make sufficient progres? Are you sure that the slab contribution
> to the stats makes all the above happening?
>
I agree that a task need not be killed if sufficient progress is made
in reclaiming
memory say from slab. But here it looks like we have an impact because of just
increasing the reclaimed without touching the scanned. It could be because of
disimilar costs or not adding adding cost. I agree that vmpressure is
only a reasonable
estimate which does not already include few other costs, but I am not
sure whether it is ok
to add another element which further increases that disparity.
We noticed this problem when moving from 3.18 to 4.4 kernel version. With the
same workload, the vmpressure events differ between 3.18 and 4.4 causing the
above mentioned problem. And with this patch on 4.4 we get the same results
as in 3,18. So the slab contribution to stats is making a difference.

>> This increases the memory pressure and
>> finally result in late critical events, but by that time the task
>> launch latencies are impacted.
>

> I have seen vmpressure hitting critical events really quickly but that
> is mostly because the vmpressure uses only very simplistic
> approximation. Usually the reclaim goes well, until you hit to dirty
> or pinned pages. Then it can get really bad, so you can get from high
> effectiveness to 0 pretty quickly.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
