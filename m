Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A36B6B02E5
	for <linux-mm@kvack.org>; Tue,  8 May 2018 18:49:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f11-v6so2584500plj.23
        for <linux-mm@kvack.org>; Tue, 08 May 2018 15:49:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d11si13256284pfh.131.2018.05.08.15.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 15:49:43 -0700 (PDT)
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
References: <20180427174527.0031016C@viggo.jf.intel.com>
 <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0bb50502-02f3-0eeb-b126-0345ec029145@intel.com>
Date: Tue, 8 May 2018 15:49:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

> 1)
> 
> Minor patch series organization requests:
> 
>  - please include the shortlog and diffstat in the cover letter in the future, as 
>    it makes it easier to see the overall structure and makes it easier to reply to 
>    certain commits as a group.

Will do.

>  - please capitalize commit titles as is usually done in arch/x86/ and change the 
>    change the subsystem tags to the usual ones:
> 
> d76eeb1914c8: x86/pkeys: Override pkey when moving away from PROT_EXEC
> f30f10248200: x86/pkeys/selftests: Add PROT_EXEC test
> 0530ebfefcdc: x86/pkeys/selftests: Add allow faults on unknown keys
> e81c40e33818: x86/pkeys/selftests: Factor out "instruction page"
> 57042882631c: x86/pkeys/selftests: Fix pkey exhaustion test off-by-one
> 6b833e9d3171: x86/pkeys/selftests: Fix pointer math
> d16f12e3c4ca: x86/pkeys: Do not special case protection key 0
> 1cb7691d0ee4: x86/pkeys/selftests: Add a test for pkey 0
> 273ae5cde423: x86/pkeys/selftests: Save off 'prot' for allocations
>
>  - please re-order the series to first introduce a unit test which specifically 
>    tests for the failure, ascertain that it indeed fails, and then apply the 
>    kernel fix. I.e. please use the order I used above for future versions of this 
>    patch-set.

I can't _quite_ use this order, but I get your point and I'll do as you
suggest, conceptually.


> 2)
> 
> The new self-test you added does not fail overly nicely, it does the following on 
> older kernels:
...
> I.e. x86 unit tests should never 'crash' in a way that suggests that the testing 
> itself might be buggy - the crashes/failures should always be well controlled.

I've tried to make this nicer.  I never abort() any more, for instance.

> 3)
> 
> When the first kernel bug fix is applied but not the second, then I don't see the 
> new PROT_EXEC test catching the bug:

Thanks for catching this.  I forgot to add the test function to the
pkey_tests[] array.  It's fixed up now.

> 4)
> 
> In the above kernel that was missing the PROT_EXEC fix I was repeatedly running 
> the 64-bit and 32-bit testcases as non-root and as root as well, until I got a 
> hang in the middle of a 32-bit test running as root:

I believe this is all my stupidity from not being careful about using
signal-safe functions in the signal handlers.  There's no pretty
solution for this, but I've at least made it stop hanging.  The fixes
for that will be in the beginning of the next series.
