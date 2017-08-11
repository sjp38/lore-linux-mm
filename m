Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id F30F06B02F4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:36:46 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id h2so15496175uaf.5
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:36:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i66si554770vkb.277.2017.08.11.09.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:36:45 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <20170806140425.20937-3-riel@redhat.com>
 <20170810152352.GZ23863@dhcp22.suse.cz> <1502464992.6577.48.camel@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6a3e2dbe-6274-4402-0716-88f4fbda73dd@oracle.com>
Date: Fri, 11 Aug 2017 09:36:32 -0700
MIME-Version: 1.0
In-Reply-To: <1502464992.6577.48.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On 08/11/2017 08:23 AM, Rik van Riel wrote:
> On Thu, 2017-08-10 at 17:23 +0200, Michal Hocko wrote:
>> On Sun 06-08-17 10:04:25, Rik van Riel wrote:
>> [...]
>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>> index 17921b0390b4..db1fb2802ecc 100644
>>> --- a/kernel/fork.c
>>> +++ b/kernel/fork.c
>>> @@ -659,6 +659,13 @@ static __latent_entropy int dup_mmap(struct
>>> mm_struct *mm,
>>>  		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
>>>  		tmp->vm_next = tmp->vm_prev = NULL;
>>>  		file = tmp->vm_file;
>>> +
>>> +		/* With VM_WIPEONFORK, the child gets an empty
>>> VMA. */
>>> +		if (tmp->vm_flags & VM_WIPEONFORK) {
>>> +			tmp->vm_file = file = NULL;
>>> +			tmp->vm_ops = NULL;
>>> +		}
>>
>> What about VM_SHARED/|VM)MAYSHARE flags. Is it OK to keep the around?
>> At
>> least do_anonymous_page SIGBUS on !vm_ops && VM_SHARED. Or do I miss
>> where those flags are cleared?
> 
> Huh, good spotting.  That makes me wonder why the test case that
> Mike and I ran worked just fine on a MAP_SHARED|MAP_ANONYMOUS VMA,
> and returned zero-filled memory when read by the child process.

Well, I think I still got a BUG with a MAP_SHARED|MAP_ANONYMOUS vma on
your v2 patch.  Did not really want to start a discussion on the
implementation until the issue of exactly what VM_WIPEONFORK was supposed
to do was settled.

> 
> OK, I'll do a minimal implementation for now, which will return
> -EINVAL if MADV_WIPEONFORK is called on a VMA with MAP_SHARED
> and/or an mmapped file.
> 
> It will work the way it is supposed to with anonymous MAP_PRIVATE
> memory, which is likely the only memory it will be used on, anyway.
> 

Seems reasonable.

You should also add VM_HUGETLB to those returning -EINVAL.  IIRC, a
VM_HUGETLB vma even without VM_SHARED expects vm_file != NULL.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
