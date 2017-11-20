Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C64576B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:10:38 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f27so4945163ote.16
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:10:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si3457381oig.258.2017.11.20.01.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 01:10:37 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116101900.13621-2-mhocko@kernel.org>
 <a3f7aed9-0df2-2fd6-cebb-ba569ad66781@redhat.com>
 <20171120085524.y4onsl5dpd3qbh7y@dhcp22.suse.cz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <37a6e9ba-e0df-b65f-d5ef-871c25b5cb87@redhat.com>
Date: Mon, 20 Nov 2017 10:10:32 +0100
MIME-Version: 1.0
In-Reply-To: <20171120085524.y4onsl5dpd3qbh7y@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

On 11/20/2017 09:55 AM, Michal Hocko wrote:
> On Fri 17-11-17 08:30:48, Florian Weimer wrote:
>> On 11/16/2017 11:18 AM, Michal Hocko wrote:
>>> +	if (flags & MAP_FIXED_SAFE) {
>>> +		struct vm_area_struct *vma = find_vma(mm, addr);
>>> +
>>> +		if (vma && vma->vm_start <= addr)
>>> +			return -ENOMEM;
>>> +	}
>>
>> Could you pick a different error code which cannot also be caused by a an
>> unrelated, possibly temporary condition?  Maybe EBUSY or EEXIST?
> 
> Hmm, none of those are described in the man page. I am usually very
> careful to not add new and potentially unexpected error codes but it is

I think this is a bad idea.  It leads to bizarre behavior, like open 
failing with EOVERFLOW with certain namespace configurations (which have 
nothing to do with file sizes).

Most of the manual pages are incomplete regarding error codes, and with 
seccomp filters and security modules, what error codes you actually get 
is anyone's guess.

> true that a new flag should warrant a new error code. I am not sure
> which one is more appropriate though. EBUSY suggests that retrying might
> help which is true only if some other party unmaps the range. So EEXIST
> would sound more natural.

Sure, EEXIST is completely fine.

>> This would definitely help with application-based randomization of mappings,
>> and there, actual ENOMEM and this error would have to be handled
>> differently.
> 
> I see. Could you be more specific about the usecase you have in mind? I
> would incorporate it into the patch description.

glibc ld.so currently maps DSOs without hints.  This means that the 
kernel will map right next to each other, and the offsets between them a 
completely predictable.  We would like to change that and supply a 
random address in a window of the address space.  If there is a 
conflict, we do not want the kernel to pick a non-random address. 
Instead, we would try again with a random address.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
