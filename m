Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D8FCB6B0255
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:40:30 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so121709366wib.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:40:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn5si31377343wjb.37.2015.07.27.08.40.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 08:40:29 -0700 (PDT)
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz> <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz> <20150727145409.GB21664@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B650E8.9030102@suse.cz>
Date: Mon, 27 Jul 2015 17:40:24 +0200
MIME-Version: 1.0
In-Reply-To: <20150727145409.GB21664@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 07/27/2015 04:54 PM, Eric B Munson wrote:
> On Mon, 27 Jul 2015, Vlastimil Babka wrote:
>>
>>> We do actually have an MCL_LOCKED, we just call it MCL_CURRENT.  Would
>>> you prefer that I match the name in mlock2() (add MLOCK_CURRENT
>>> instead)?
>>
>> Hm it's similar but not exactly the same, because MCL_FUTURE is not
>> the same as MLOCK_ONFAULT :) So MLOCK_CURRENT would be even more
>> confusing. Especially if mlockall(MCL_CURRENT | MCL_FUTURE) is OK,
>> but mlock2(MLOCK_LOCKED | MLOCK_ONFAULT) is invalid.
>
> MLOCK_ONFAULT isn't meant to be the same as MCL_FUTURE, rather it is
> meant to be the same as MCL_ONFAULT.  MCL_FUTURE only controls if the
> locking policy will be applied to any new mappings made by this process,
> not the locking policy itself.  The better comparison is MCL_CURRENT to
> MLOCK_LOCK and MCL_ONFAULT to MLOCK_ONFAULT.  MCL_CURRENT and
> MLOCK_LOCK do the same thing, only one requires a specific range of
> addresses while the other works process wide.  This is why I suggested
> changing MLOCK_LOCK to MLOCK_CURRENT.  It is an error to call
> mlock2(MLOCK_LOCK | MLOCK_ONFAULT) just like it is an error to call
> mlockall(MCL_CURRENT | MCL_ONFAULT).  The combinations do no make sense.

How is it an error to call mlockall(MCL_CURRENT | MCL_ONFAULT)? How else 
would you apply mlock2(MCL_ONFAULT) to all current mappings? Later below 
you use the same example and I don't think it's different by removing 
MLOCK_LOCKED flag.

> This was all decided when VM_LOCKONFAULT was a separate state from
> VM_LOCKED.  Now that VM_LOCKONFAULT is a modifier to VM_LOCKED and
> cannot be specified independentally, it might make more sense to mirror
> that relationship to userspace.  Which would lead to soemthing like the
> following:
>
> To lock and populate a region:
> mlock2(start, len, 0);
>
> To lock on fault a region:
> mlock2(start, len, MLOCK_ONFAULT);
>
> If LOCKONFAULT is seen as a modifier to mlock, then having the flags
> argument as 0 mean do mlock classic makes more sense to me.

Yup that's what I was trying to suggest.

> To mlock current on fault only:
> mlockall(MCL_CURRENT | MCL_ONFAULT);
>
> To mlock future on fault only:
> mlockall(MCL_FUTURE | MCL_ONFAULT);
>
> To lock everything on fault:
> mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
>
> I think I have talked myself into rewriting the set again :/

Sorry :) You could also wait a bit for more input than just from me...

>>
>>> Finally, on the question of MAP_LOCKONFAULT, do you just dislike
>>> MAP_LOCKED and do not want to see it extended, or is this a NAK on the
>>> set if that patch is included.  I ask because I have to spin a V6 to get
>>> the MLOCK flag declarations right, but I would prefer not to do a V7+.
>>> If this is a NAK with, I can drop that patch and rework the tests to
>>> cover without the mmap flag.  Otherwise I want to keep it, I have an
>>> internal user that would like to see it added.
>>
>> I don't want to NAK that patch if you think it's useful.
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
