Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1486B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 11:00:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k10so1225767wrk.4
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 08:00:25 -0700 (PDT)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id y20si1672791wrc.113.2017.09.28.08.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 08:00:24 -0700 (PDT)
Message-ID: <59CD0E85.8060707@iogearbox.net>
Date: Thu, 28 Sep 2017 17:00:21 +0200
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
References: <20170928112727.GA11310@leverpostej> <59CD093A.6030201@iogearbox.net> <20170928144538.GA32487@leverpostej>
In-Reply-To: <20170928144538.GA32487@leverpostej>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, syzkaller@googlegroups.com, "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>

On 09/28/2017 04:45 PM, Mark Rutland wrote:
> On Thu, Sep 28, 2017 at 04:37:46PM +0200, Daniel Borkmann wrote:
>> On 09/28/2017 01:27 PM, Mark Rutland wrote:
>>> Hi,
>>>
>>> While fuzzing v4.14-rc2 with Syzkaller, I found it was possible to trigger the
>>> warning at mm/percpu.c:1361, on both arm64 and x86_64. This appears to require
>>> increasing RLIMIT_MEMLOCK, so to the best of my knowledge this cannot be
>>> triggered by an unprivileged user.
>>>
>>> I've included example splats for both x86_64 and arm64, along with a C
>>> reproducer, inline below.
>>>
>>> It looks like dev_map_alloc() requests a percpu alloction of 32776 bytes, which
>>> is larger than the maximum supported allocation size of 32768 bytes.
>>>
>>> I wonder if it would make more sense to pr_warn() for sizes that are too
>>> large, so that callers don't have to roll their own checks against
>>> PCPU_MIN_UNIT_SIZE?
>>
>> Perhaps the pr_warn() should be ratelimited; or could there be an
>> option where we only return NULL, not triggering a warn at all (which
>> would likely be what callers might do anyway when checking against
>> PCPU_MIN_UNIT_SIZE and then bailing out)?
>
> Those both make sense to me; checking __GFP_NOWARN should be easy
> enough.
>
> Just to check, do you think that dev_map_alloc() should explicitly test
> the size against PCPU_MIN_UNIT_SIZE, prior to calling pcpu_alloc()?

Looks like there are users of __alloc_percpu_gfp() with __GFP_NOWARN
in couple of places already, but __GFP_NOWARN is ignored. Would make
sense to support that indeed to avoid throwing the warn and just let
the caller bail out when it sees the NULL as usual. In some cases (like
the current ones) this makes sense, others probably not too much and
a WARN would be preferred way, but __alloc_percpu_gfp() could provide
such option to simplify some of the code that pre checks against the
limit on PCPU_MIN_UNIT_SIZE before calling the allocator and doesn't
throw a WARN either; and most likely such check is just to prevent
the user from seeing exactly this splat.

Thanks,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
