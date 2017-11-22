Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86C0B6B0280
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:49:37 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id e142so7537435oih.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:49:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o84si5952520oib.331.2017.11.22.04.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 04:49:36 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
 <f0495f01-9821-ec36-56b4-333f109eb761@suse.cz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <6299ccb2-ca6b-b49e-fca0-6baa0d6581a9@redhat.com>
Date: Wed, 22 Nov 2017 13:49:33 +0100
MIME-Version: 1.0
In-Reply-To: <f0495f01-9821-ec36-56b4-333f109eb761@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/22/2017 01:46 PM, Vlastimil Babka wrote:
> On 11/22/2017 01:15 PM, Florian Weimer wrote:
>> On 11/22/2017 09:18 AM, Vlastimil Babka wrote:
>>> And, was the pkey == -1 internal wiring supposed to be exposed to the
>>> pkey_mprotect() signal, or should there have been a pre-check returning
>>> EINVAL in SYSCALL_DEFINE4(pkey_mprotect), before calling
>>> do_mprotect_pkey())? I assume it's too late to change it now anyway (or
>>> not?), so should we also document it?
>>
>> I think the -1 case to the set the default key is useful because it
>> allows you to use a key value of -1 to mean a??MPK is not supporteda??, and
>> still call pkey_mprotect.
> 
> Hmm the current manpage says then when MPK is not supported, pkey has to
> be specified 0. Which is a value that doesn't work when MPK *is*
> supported. So -1 is more universal indeed.

-1 also chosen a different key if key 0 does not support the requested 
protection flags.

>> I plan to document this behavior on the glibc side, and glibc will call
>> mprotect (not pkey_mprotect) for key -1, so that you won't get ENOSYS
>> with kernels which do not support pkey_mprotect.
> 
> Fair enough. What will you do about pkey_alloc() in that case, emulate
> ENOSPC? Oh, the manpage already suggests so. And the return value in
> that case is... -1. Makes sense :)

The manual page is incorrect, the kernel actually returns EINVAL. 
Applications should check for EINVAL (and also ENOSYS) and activate 
fallback code.  Using -1 directly would be a bit reckless IMHO.

Thanks
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
