Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28FE26B04FB
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:57:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 184so21108630wmo.7
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:57:38 -0700 (PDT)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id j20si960003wrb.31.2017.07.28.01.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 01:49:13 -0700 (PDT)
Received: by mail-wr0-x236.google.com with SMTP id 12so152629349wrb.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:49:13 -0700 (PDT)
MIME-Version: 1.0
Reply-To: dmitriyz@waymo.com
In-Reply-To: <41954034-9de1-de8e-f915-51a4b0334f98@suse.cz>
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
 <20170727164608.12701-1-dmitriyz@waymo.com> <41954034-9de1-de8e-f915-51a4b0334f98@suse.cz>
From: Dima Zavin <dmitriyz@waymo.com>
Date: Fri, 28 Jul 2017 01:48:50 -0700
Message-ID: <CAPz4a6C3JDPdkcvgo1JfynDfheDy2gkE1JcOZVhChry7C1yBwQ@mail.gmail.com>
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of cpusets_enabled()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>

On Fri, Jul 28, 2017 at 12:45 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> [+CC PeterZ]
>
> On 07/27/2017 06:46 PM, Dima Zavin wrote:
>> In codepaths that use the begin/retry interface for reading
>> mems_allowed_seq with irqs disabled, there exists a race condition that
>> stalls the patch process after only modifying a subset of the
>> static_branch call sites.
>>
>> This problem manifested itself as a dead lock in the slub
>> allocator, inside get_any_partial. The loop reads
>> mems_allowed_seq value (via read_mems_allowed_begin),
>> performs the defrag operation, and then verifies the consistency
>> of mem_allowed via the read_mems_allowed_retry and the cookie
>> returned by xxx_begin. The issue here is that both begin and retry
>> first check if cpusets are enabled via cpusets_enabled() static branch.
>> This branch can be rewritted dynamically (via cpuset_inc) if a new
>> cpuset is created. The x86 jump label code fully synchronizes across
>> all CPUs for every entry it rewrites. If it rewrites only one of the
>> callsites (specifically the one in read_mems_allowed_retry) and then
>> waits for the smp_call_function(do_sync_core) to complete while a CPU is
>> inside the begin/retry section with IRQs off and the mems_allowed value
>> is changed, we can hang. This is because begin() will always return 0
>> (since it wasn't patched yet) while retry() will test the 0 against
>> the actual value of the seq counter.
>
> Hm I wonder if there are other static branch users potentially having
> similar problem. Then it would be best to fix this at static branch
> level. Any idea, Peter? An inelegant solution would be to have indicate
> static_branch_(un)likely() callsites ordering for the patching. I.e.
> here we would make sure that read_mems_allowed_begin() callsites are
> patched before read_mems_allowed_retry() when enabling the static key,
> and the opposite order when disabling the static key.
>

This was my main worry, that I'm just patching up one incarnation of
this problem
and other clients will eventually trip over this.

>> The fix is to cache the value that's returned by cpusets_enabled() at the
>> top of the loop, and only operate on the seqcount (both begin and retry) if
>> it was true.
>
> Maybe we could just return e.g. -1 in read_mems_allowed_begin() when
> cpusets are disabled, and test it in read_mems_allowed_retry() before
> doing a proper seqcount retry check? Also I think you can still do the
> cpusets_enabled() check in read_mems_allowed_retry() before the
> was_enabled (or cookie == -1) test?

Hmm, good point! If cpusets_enabled() is true, then we can still test against
was_enabled and do the right thing (adds one extra branch in that case). When
it's false, we still benefit from the static_branch fanciness. Thanks!

Re setting the cookie to -1, I didn't really want to overload the
cookie value but
rather just make the state explicit so it's easier to grawk as this is
all already
subtle enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
