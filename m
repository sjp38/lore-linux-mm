Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7236B05B3
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 05:40:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t187so41938618pfb.0
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 02:40:56 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id z72si16665868pgd.836.2017.08.02.02.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Aug 2017 02:40:54 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v6 21/62] powerpc: introduce execute-only pkey
In-Reply-To: <87d18fw9it.fsf@linux.vnet.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-22-git-send-email-linuxram@us.ibm.com> <87shhgdx5i.fsf@linux.vnet.ibm.com> <87d18fu6o1.fsf@concordia.ellerman.id.au> <87d18fw9it.fsf@linux.vnet.ibm.com>
Date: Wed, 02 Aug 2017 19:40:46 +1000
Message-ID: <871sous3xd.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>, linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:

> Michael Ellerman <mpe@ellerman.id.au> writes:
>
>> Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
>>> Ram Pai <linuxram@us.ibm.com> writes:
>> ...
>>>> +
>>>> +	/* We got one, store it and use it from here on out */
>>>> +	if (need_to_set_mm_pkey)
>>>> +		mm->context.execute_only_pkey = execute_only_pkey;
>>>> +	return execute_only_pkey;
>>>> +}
>>>
>>> If you follow the code flow in __execute_only_pkey, the AMR and UAMOR
>>> are read 3 times in total, and AMR is written twice. IAMR is read and
>>> written twice. Since they are SPRs and access to them is slow (or isn't
>>> it?),
>>
>> SPRs read/writes are slow, but they're not *that* slow in comparison to
>> a system call (which I think is where this code is being called?).
>
> Yes, this code runs on mprotect and mmap syscalls if the memory is
> requested to have execute but not read nor write permissions.

Yep. That's not in the fast path for key usage, ie. the fast path is
userspace changing the AMR itself, and the overhead of a syscall is
already hundreds of cycles.

>> So we should try to avoid too many SPR read/writes, but at the same time
>> we can accept more than the minimum if it makes the code much easier to
>> follow.
>
> Ok. Ram had asked me to suggest a way to optimize the SPR reads and
> writes and I came up with the patch below. Do you think it's worth it?

At a glance no I don't think it is. Sorry you spent that much time on it.

I think we can probably reduce the number of SPR accesses without
needing to go to that level of complexity.

But don't throw the patch away, I may eat my words once I have the full
series applied and am looking at it hard - at the moment I'm just
reviewing the patches piecemeal as I get time.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
