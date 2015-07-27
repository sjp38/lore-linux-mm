Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8554E6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 15:18:58 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so85747155igb.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:18:58 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id d6si7004567igz.14.2015.07.27.12.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 12:18:58 -0700 (PDT)
Received: by iggf3 with SMTP id f3so90818585igg.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:18:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
Date: Mon, 27 Jul 2015 12:18:57 -0700
Message-ID: <CAGXu5jLPT-2c_H3kjCzbVgRKQO0xMskVd7JcAMmWZSmFgzZ4ng@mail.gmail.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, Linux API <linux-api@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 21, 2015 at 4:34 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 19 Jul 2015 15:31:09 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
>> To mark a page idle one should set the bit corresponding to the
>>    page by writing to the file. A value written to the file is OR-ed with the
>>    current bitmap value. Only user memory pages can be marked idle, for other
>>    page types input is silently ignored. Writing to this file beyond max PFN
>>    results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
>>    set.
>>
>>    This file can be used to estimate the amount of pages that are not
>>    used by a particular workload as follows:
>>
>>    1. mark all pages of interest idle by setting corresponding bits in the
>>       /proc/kpageidle bitmap
>>    2. wait until the workload accesses its working set
>>    3. read /proc/kpageidle and count the number of bits set
>
> Security implications.  This interface could be used to learn about a
> sensitive application by poking data at it and then observing its
> memory access patterns.  Perhaps this is why the proc files are
> root-only (whcih I assume is sufficient).  Some words here about the
> security side of things and the reasoning behind the chosen permissions
> would be good to have.

As long as this stays true-root-only, I think it should be safe enough.

>>  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
>>    memory cgroup each page is charged to, indexed by PFN.
>
> Actually "closest online ancestor".  This also should be in the
> interface documentation.
>
>> Only available when CONFIG_MEMCG is set.
>
> CONFIG_MEMCG and CONFIG_IDLE_PAGE_TRACKING I assume?
>
>>
>>    This file can be used to find all pages (including unmapped file
>>    pages) accounted to a particular cgroup. Using /proc/kpageidle, one
>>    can then estimate the cgroup working set size.
>>
>> For an example of using these files for estimating the amount of unused
>> memory pages per each memory cgroup, please see the script attached
>> below.
>
> Why were these put in /proc anyway?  Rather than under /sys/fs/cgroup
> somewhere?  Presumably because /proc/kpageidle is useful in non-memcg
> setups.

Do we need a /proc/vm/ for holding these kinds of things? We're
collecting a lot there. Or invent some way for this to be sensible in
/sys?

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
