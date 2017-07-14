Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E60A9440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 13:29:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n42so40128642qtn.10
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 10:29:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q5si8106963qkd.61.2017.07.14.10.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 10:29:09 -0700 (PDT)
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
 <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
 <20170714082629.GA2618@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <146116f3-c318-efc0-de40-f67655cbbf94@oracle.com>
Date: Fri, 14 Jul 2017 10:29:01 -0700
MIME-Version: 1.0
In-Reply-To: <20170714082629.GA2618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On 07/14/2017 01:26 AM, Michal Hocko wrote:
> On Thu 13-07-17 15:33:47, Mike Kravetz wrote:
>> On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
>>> [+CC linux-api]
>>>
>>> On 07/13/2017 05:58 PM, Mike Kravetz wrote:
>>>> mremap will create a 'duplicate' mapping if old_size == 0 is
>>>> specified.  Such duplicate mappings make no sense for private
>>>> mappings.  If duplication is attempted for a private mapping,
>>>> mremap creates a separate private mapping unrelated to the
>>>> original mapping and makes no modifications to the original.
>>>> This is contrary to the purpose of mremap which should return
>>>> a mapping which is in some way related to the original.
>>>>
>>>> Therefore, return EINVAL in the case where if an attempt is
>>>> made to duplicate a private mapping.
>>>>
>>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>>
>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>
>> In another e-mail thread, Andrea makes the case that mremap(old_size == 0)
>> of private file backed mappings could possibly be used for something useful.
>> For example to create a private COW mapping.
> 
> What does this mean exactly? I do not see it would force CoW so again
> the new mapping could fail with the basic invariant that the content
> of the new mapping should match the old one (e.g. old mapping already
> CoWed some pages the new mapping would still contain the origin content
> unless I am missing something).

I do not think you are missing anything.  You are correct in saying that
the new mapping would be COW of the original file contents.  It is NOT
based on any private pages of the old private mapping.  Sorry, my wording
above was not quite clear.

As previously discussed, the more straight forward to way to accomplish
the same thing would be a simple call to mmap with the fd.

After thinking about this some more, perhaps the original patch to return
EINVAL for all private mappings makes more sense.  Even in the case of a
file backed private mapping, the new mapping will be based on the file and
not the old mapping.  The purpose of mremap is to create a new mapping
based on the old mapping.  So, this is not strictly in line with the purpose
of mremap.

Actually, the more I think about this, the more I wish there was some way
to deprecate and eventually eliminate the old_size == 0 behavior.

> [...]
>> +	/*
>> +	 * !old_len  is a special case where a mapping is 'duplicated'.
>> +	 * Do not allow this for private anon mappings.
>> +	 */
>> +	if (!old_len && vma_is_anonymous(vma) &&
>> +	    !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
>> +		return ERR_PTR(-EINVAL);
> 
> Why is vma_is_anonymous() without VM_*SHARE* check insufficient?

Are you asking,
why is if (!old_len && vma_is_anonymous(vma)) insufficient?

If so, you are correct that the additional check for VM_*SHARE* is not
necessary.  Shared mappings are technically not anonymous as they must
contain a common backing object.

The !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE) check was there in the first
patch to catch all private mappings.  When adding vma_is_anonymous(vma), I
missed the fact that it was redundant.  But, based on your comments above
I think the first patch is more correct.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
