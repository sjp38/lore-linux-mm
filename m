Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1376B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:25:58 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d6so17259258pfb.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:25:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k26si18185788pfh.110.2017.11.23.07.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 07:25:57 -0800 (PST)
Subject: Re: MPK: pkey_free and key reuse
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
 <48ac42c0-4c31-cef8-a75a-8f3beab7cc66@redhat.com>
 <633b5b03-3481-0da2-9d6c-f5298902e36a@linux.intel.com>
 <068b89c7-4303-88a7-540a-1491dc8a292d@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <04ef6b4a-6d20-d025-0b56-741fd467d445@linux.intel.com>
Date: Thu, 23 Nov 2017 07:25:53 -0800
MIME-Version: 1.0
In-Reply-To: <068b89c7-4303-88a7-540a-1491dc8a292d@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/23/2017 04:48 AM, Florian Weimer wrote:
> On 11/09/2017 05:59 PM, Dave Hansen wrote:
>> The manpage is pretty bare here.A  But the thought was that, in most
>> cases, you will want to allocate a key and start using it immediately.
>> This was in response to some feedback on one of the earlier reviews of
>> the patch set.
> 
> Okay.A  In the future, may want to use this access rights to specify the
> default for the signal handler (with a new pkey_alloc flag).A  If I can
> the default access rights, that would pretty much solve the sigsetjmp
> problem for me, too, and I can start using protection keys in low-level
> glibc code.

I haven't thought about this much in a year or so, but I think this is
doable.

One bit of advice: please look at features when they go in to the
kernel.  Your feedback has been valuable, but not very timely.  I
promise you'll get better results if you give feedback when patches are
being posted rather than when they've been in the kernel for a year.

>>> I think we should either implement revoke on pkey_alloc, with a
>>> broadcast to all threads (the pkey_set race can be closed by having a
>>> vDSO for that an the revocation code can check %rip to see if the old
>>> PKRU value needs to be fixed up).A  Or we add the two pkey_alloc flags I
>>> mentioned earlier.
>>
>> That sounds awfully complicated to put in-kernel.A  I'd be happy to
>> review the patches after you put them together once we see how it looks.
> 
> TLB flushes are complicated, too, and very costly, but we still do them
> on unmap, even in cases where they are not required for security reasons.

I'll also note that TLB flushes are transparent to software.  What you
are suggesting is not.  That makes it a *LOT* more difficult to implement.

If you have an idea how to do this, I'll happily review patches!

>> You basically want threads to broadcast their PKRU values at pkey_free()
>> time.A  That's totally doable... in userspace.A  You just need a mechanism
>> for each thread to periodically check if they need an update.
> 
> No, we want to the revocation to be immediate, so we'd have to use
> something like the setxid broadcast, and we have to make sure that we
> aren't in a pkey_set, and if we are, adjust register contents besides
> PKRU.A  Not pretty at all.A  I really don't want to implement that.
> 
> If the broadcast is lazy, I think it defeats its purpose because you
> don't know what kind of access privileges other threads in the system have.
> 
> Your solution to all MPK problems seems to be to say that it's undefined
> and applications shouldn't do that.A  But if applications only used
> well-defined memory accesses, why would we need MPK?

BTW, I never call this feature MPK because it looks too much like MPX
and they have nothing to do with each other.  I'd recommend the same to
you.  It keeps your audience less confused.

I understand there is some distaste for where the implementation
settled.  I don't, either, in a lot of ways.  If I were to re-architect
it in the CPU, I certainly wouldn't have a user-visible PKRU and and
found a way to avoid the signal PKRU issues.  But, that ship has sailed.

I don't see a way to do a broadcast PKRU update.  But, I'd love to be
proven wrong, with code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
