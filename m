Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id C99546B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:53:53 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so8271748wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:53:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa6si11182638wid.57.2015.08.20.00.53.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 00:53:52 -0700 (PDT)
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz> <20150819213345.GB4536@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D5878E.5030206@suse.cz>
Date: Thu, 20 Aug 2015 09:53:50 +0200
MIME-Version: 1.0
In-Reply-To: <20150819213345.GB4536@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 08/19/2015 11:33 PM, Eric B Munson wrote:
> On Wed, 12 Aug 2015, Michal Hocko wrote:
>
>> On Sun 09-08-15 01:22:53, Eric B Munson wrote:
>>
>> I do not like this very much to be honest. We have only few bits
>> left there and it seems this is not really necessary. I thought that
>> LOCKONFAULT acts as a modifier to the mlock call to tell whether to
>> poppulate or not. The only place we have to persist it is
>> mlockall(MCL_FUTURE) AFAICS. And this can be handled by an additional
>> field in the mm_struct. This could be handled at __mm_populate level.
>> So unless I am missing something this would be much more easier
>> in the end we no new bit in VM flags would be necessary.
>>
>> This would obviously mean that the LOCKONFAULT couldn't be exported to
>> the userspace but is this really necessary?
>
> Sorry for the latency here, I was on vacation and am now at plumbers.
>
> I am not sure that growing the mm_struct by another flags field instead
> of using available bits in the vm_flags is the right choice.

I was making the same objection on one of the earlier versions and since 
you sticked with a new vm flag, I thought it doesn't matter, as we could 
change it later if we run out of bits. But now I realize that since you 
export this difference to userspace (and below you say that it's by 
request), we won't be able to change it later. So it's a more difficult 
choice.

> After this
> patch, we still have 3 free bits on 32 bit architectures (2 after the
> userfaultfd set IIRC).  The group which asked for this feature here
> wants the ability to distinguish between LOCKED and LOCKONFAULT regions
> and without the VMA flag there isn't a way to do that.
>
> Do we know that these last two open flags are needed right now or is
> this speculation that they will be and that none of the other VMA flags
> can be reclaimed?

I think it's the latter, we can expect that flags will be added rather 
than removed, as removal is hard or impossible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
