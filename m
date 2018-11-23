Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D51F6B2D68
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:23:53 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a18so4127635pga.16
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:23:53 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d34si10894842pld.222.2018.11.23.05.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:23:52 -0800 (PST)
Subject: Re: [Intel-gfx] [PATCH 2/3] mm, notifier: Catch sleeping/blocking for
 !blockable
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-3-daniel.vetter@ffwll.ch>
 <20181123111237.GE8625@dhcp22.suse.cz>
 <20181123123838.GL4266@phenom.ffwll.local>
 <20181123124643.GK8625@dhcp22.suse.cz>
 <CAKMK7uGv7dHqE4_Gmsum=uhfbVo=ymq-QhsR5cHLOC4ZTq4MxA@mail.gmail.com>
From: Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>
Message-ID: <50923341-d759-2621-7166-695df4cd88fb@linux.intel.com>
Date: Fri, 23 Nov 2018 13:23:48 +0000
MIME-Version: 1.0
In-Reply-To: <CAKMK7uGv7dHqE4_Gmsum=uhfbVo=ymq-QhsR5cHLOC4ZTq4MxA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>, Michal Hocko <mhocko@kernel.org>
Cc: intel-gfx <intel-gfx@lists.freedesktop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>


On 23/11/2018 13:12, Daniel Vetter wrote:
> On Fri, Nov 23, 2018 at 1:46 PM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Fri 23-11-18 13:38:38, Daniel Vetter wrote:
>>> On Fri, Nov 23, 2018 at 12:12:37PM +0100, Michal Hocko wrote:
>>>> On Thu 22-11-18 17:51:05, Daniel Vetter wrote:
>>>>> We need to make sure implementations don't cheat and don't have a
>>>>> possible schedule/blocking point deeply burried where review can't
>>>>> catch it.
>>>>>
>>>>> I'm not sure whether this is the best way to make sure all the
>>>>> might_sleep() callsites trigger, and it's a bit ugly in the code flow.
>>>>> But it gets the job done.
>>>>
>>>> Yeah, it is quite ugly. Especially because it makes DEBUG config
>>>> bahavior much different. So is this really worth it? Has this already
>>>> discovered any existing bug?
>>>
>>> Given that we need an oom trigger to hit this we're not hitting this in CI
>>> (oom is just way to unpredictable to even try). I'd kinda like to also add
>>> some debug interface so I can provoke an oom kill of a specially prepared
>>> process, to make sure we can reliably exercise this path without killing
>>> the kernel accidentally. We do similar tricks for our shrinker already.
>>
>> Create a task with oom_score_adj = 1000 and trigger the oom killer via
>> sysrq and you should get a predictable oom invocation and execution.
> 
> Ah right. We kinda do that already in an attempt to get the tests
> killed without the runner, for accidental oom. Just didn't think about
> this in the context of intentionally firing the oom. I'll try whether
> I can bake up some new subtest in our userptr/mmu-notifier testcases.

Very handy trick - I think I will think of applying it in the shrinker 
area as well.

Regards,

Tvrtko
