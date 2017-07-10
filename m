Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C268444084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:22:18 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id o19so41324135vkd.7
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:22:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 143si1555965vkn.160.2017.07.10.10.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 10:22:17 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170707102324.kfihkf72sjcrtn5b@node.shutemov.name>
 <e328ff6a-2c4b-ec26-cc28-e24b7b35a463@oracle.com>
 <20170707174534.wdfbciyfpovi52dy@node.shutemov.name>
 <79eca23d-9f1a-9713-3f6b-8f7598d53190@oracle.com>
 <662d372a-5737-5f0b-8ac1-c997f3a935eb@linux.vnet.ibm.com>
 <223c0ede-1203-4ea6-0157-a4500fea8050@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bfdeb8ea-0d8c-a652-39b5-e92e196e6c97@oracle.com>
Date: Mon, 10 Jul 2017 10:22:09 -0700
MIME-Version: 1.0
In-Reply-To: <223c0ede-1203-4ea6-0157-a4500fea8050@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/10/2017 09:22 AM, Vlastimil Babka wrote:
> On 07/09/2017 09:32 AM, Anshuman Khandual wrote:
>> On 07/07/2017 11:39 PM, Mike Kravetz wrote:
>>> On 07/07/2017 10:45 AM, Kirill A. Shutemov wrote:
>>>> On Fri, Jul 07, 2017 at 10:29:52AM -0700, Mike Kravetz wrote:
>>>>> On 07/07/2017 03:23 AM, Kirill A. Shutemov wrote:
>>>>>> What is going to happen to mirrored after CoW for instance?
>>>>>>
>>>>>> In my opinion, it shouldn't be allowed for anon/private mappings at least.
>>>>>> And with this limitation, I don't see much sense in the new interface --
>>>>>> just create mirror by mmap()ing the file again.
>>>>>
>>>>> The code today works for anon shared mappings.  See simple program below.
>>>>>
>>>>> You are correct in that it makes little or no sense for private mappings.
>>>>> When looking closer at existing code, mremap() creates a new private
>>>>> mapping in this case.  This is most likely a bug.
>>>>
>>>> IIRC, existing code doesn't create mirrors of private pages as it requires
>>>> old_len to be zero. There's no way to get private pages mapped twice this
>>>> way.
>>>
>>> Correct.
>>> As mentioned above, mremap does 'something' for private anon pages when
>>> old_len == 0.  However, this may be considered a bug.  In this case, mremap
>>> creates a new private anon mapping of length new_size.  Since old_len == 0,
>>> it does not unmap any of the old mapping.  So, in this case mremap basically
>>> creates a new private mapping (unrealted to the original) and does not
>>> modify the old mapping.
>>>
>>
>> Yeah, in my experiment, after the mremap() exists we have two different VMAs
>> which can contain two different set of data. No page sharing is happening.
> 
> So how does this actually work for the JVM garbage collector use case?
> Aren't the garbage collected objects private anon?

Good point.
The sample program the JVM team gave me uses a shared anon mapping.  As you
mention one would expect these mappings to be private.  I have asked them
for more details on their use case.

> Anyway this should be documented.

Yes, their prototype work seems to take advantage of this existing undocumented
behavior.  It seems we have been carrying this functionality for at least 13
years.  It may be time to document.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
