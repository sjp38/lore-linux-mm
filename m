Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0404A440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:02:04 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id j1so21853854uah.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:02:03 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 21si22732vkg.6.2017.07.13.09.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 09:02:03 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170712114655.GG28912@dhcp22.suse.cz>
 <3a2cfeae-520c-b6e5-2808-cf1bcf62b067@oracle.com>
 <20170713061651.GA14492@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <21b264e7-b879-f072-03d2-f6f4aec5c957@oracle.com>
Date: Thu, 13 Jul 2017 09:01:54 -0700
MIME-Version: 1.0
In-Reply-To: <20170713061651.GA14492@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 07/12/2017 11:16 PM, Michal Hocko wrote:
> On Wed 12-07-17 09:55:48, Mike Kravetz wrote:
>> On 07/12/2017 04:46 AM, Michal Hocko wrote:
>>> On Tue 11-07-17 11:23:19, Mike Kravetz wrote:
>>>> On 07/11/2017 05:36 AM, Michal Hocko wrote:
>>> [...]
>>>>> Anyway the patch should fail with -EINVAL on private mappings as Kirill
>>>>> already pointed out
>>>>
>>>> Yes.  I think this should be a separate patch.  As mentioned earlier,
>>>> mremap today creates a new/additional private mapping if called in this
>>>> way with old_size == 0.  To me, this is a bug.
>>>
>>> Not only that. It clears existing ptes in the old mapping so the content
>>> is lost. That is quite unexpected behavior. Now it is hard to assume
>>> whether somebody relies on the behavior (I can easily imagine somebody
>>> doing backup&clear in atomic way) so failing with EINVAL might break
>>> userspace so I am not longer sure. Anyway this really needs to be
>>> documented.
>>
>> I am pretty sure it does not clear ptes in the old mapping, or modify it
>> in any way.  Are you thinking they are cleared as part of the call to
>> move_page_tables?  Since old_size == 0 (len as passed to move_page_tables),
>> the for loop in move_page_tables is not run and it doesn't do much of
>> anything in this case.
> 
> Dang. I have completely missed that we give old_len as the len
> parameter. Then it is clear that this old_len == 0 trick never really
> worked for MAP_PRIVATE because it simply fails the main invariant that
> the content at the new location matches the old one. Care to send a
> patch to clarify that and sent EINVAL or should I do it?

Sent a patch (in separate e-mail thread) to return EINVAL for private
mappings.

>> If adding hugetlbfs support to memfd_create works out, I would like to
>> see mremap(old_size == 0) support dropped.  Nobody here (kernel mm
>> development) seems to like it.  However, as you note there may be somebody
>> depending on this behavior.  What would be the process for removing
>> such support?  AFAIK, it is not documented anywhere.  If we do document
>> the behavior, then we will certainly be stuck with it for a long time.
> 
> I would rather document it than remove it. From the past we know that
> there are users and my experience tells me that once something is used
> it lives its life for ever basically. And moreover it is not like this
> costs us any maintenance burden to support the hack. Just make it more
> obvious so that we do not have to rediscover it each time.

I will put together a patch to add a description of (old_size == 0)
behavior to the man page.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
