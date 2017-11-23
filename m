Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF1BF6B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:49:01 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id r190so8762027oie.14
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:49:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l35si3599637otl.188.2017.11.23.04.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 04:49:00 -0800 (PST)
Subject: Re: MPK: pkey_free and key reuse
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
 <48ac42c0-4c31-cef8-a75a-8f3beab7cc66@redhat.com>
 <633b5b03-3481-0da2-9d6c-f5298902e36a@linux.intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <068b89c7-4303-88a7-540a-1491dc8a292d@redhat.com>
Date: Thu, 23 Nov 2017 13:48:57 +0100
MIME-Version: 1.0
In-Reply-To: <633b5b03-3481-0da2-9d6c-f5298902e36a@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/09/2017 05:59 PM, Dave Hansen wrote:
> On 11/09/2017 06:48 AM, Florian Weimer wrote:
>> On 11/08/2017 09:41 PM, Dave Hansen wrote:
>>>> (B) If a key is reused, existing threads retain their access rights,
>>>> while there is an expectation that pkey_alloc denies access for the
>>>> threads except the current one.
>>> Where does this expectation come from?
>>
>> For me, it was the access_rights argument to pkey_alloc.A  What else
>> would it do?A  For the current thread, I can already set the rights with
>> a PKRU write, so the existence of the syscall argument is puzzling.
> 
> The manpage is pretty bare here.  But the thought was that, in most
> cases, you will want to allocate a key and start using it immediately.
> This was in response to some feedback on one of the earlier reviews of
> the patch set.

Okay.  In the future, may want to use this access rights to specify the 
default for the signal handler (with a new pkey_alloc flag).  If I can 
the default access rights, that would pretty much solve the sigsetjmp 
problem for me, too, and I can start using protection keys in low-level 
glibc code.

>>> Using the malloc() analogy, we
>>> don't expect that free() in one thread actively takes away references to
>>> the memory held by other threads.
>>
>> But malloc/free isn't expected to be a partial antidote to random
>> pointer scribbling.
> 
> Nor is protection keys intended to be an antidote for use-after-free.

I'm comparing this to munmap, which is actually such an antidote 
(because it involves an IPI to flush all CPUs which could have seen the 
mapping before).

I'm surprised that pkey_free doesn't perform a similar broadcast.

>> I think we should either implement revoke on pkey_alloc, with a
>> broadcast to all threads (the pkey_set race can be closed by having a
>> vDSO for that an the revocation code can check %rip to see if the old
>> PKRU value needs to be fixed up).A  Or we add the two pkey_alloc flags I
>> mentioned earlier.
> 
> That sounds awfully complicated to put in-kernel.  I'd be happy to
> review the patches after you put them together once we see how it looks.

TLB flushes are complicated, too, and very costly, but we still do them 
on unmap, even in cases where they are not required for security reasons.

> You basically want threads to broadcast their PKRU values at pkey_free()
> time.  That's totally doable... in userspace.  You just need a mechanism
> for each thread to periodically check if they need an update.

No, we want to the revocation to be immediate, so we'd have to use 
something like the setxid broadcast, and we have to make sure that we 
aren't in a pkey_set, and if we are, adjust register contents besides 
PKRU.  Not pretty at all.  I really don't want to implement that.

If the broadcast is lazy, I think it defeats its purpose because you 
don't know what kind of access privileges other threads in the system have.

Your solution to all MPK problems seems to be to say that it's undefined 
and applications shouldn't do that.  But if applications only used 
well-defined memory accesses, why would we need MPK?

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
