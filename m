Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C8F5B6B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:09:02 -0400 (EDT)
Received: by wifj2 with SMTP id j2so44044567wif.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:09:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd5si29682085wjb.93.2015.03.18.09.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 09:09:01 -0700 (PDT)
Message-ID: <5509A31C.3070108@suse.cz>
Date: Wed, 18 Mar 2015 17:09:00 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, memcg: sync allocation and memcg charge gfp flags
 for THP
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz> <55098D0A.8090605@suse.cz> <20150318150257.GL17241@dhcp22.suse.cz> <55099C72.1080102@suse.cz> <20150318155905.GO17241@dhcp22.suse.cz>
In-Reply-To: <20150318155905.GO17241@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/18/2015 04:59 PM, Michal Hocko wrote:
> On Wed 18-03-15 16:40:34, Vlastimil Babka wrote:
>> On 03/18/2015 04:02 PM, Michal Hocko wrote:
>>> On Wed 18-03-15 15:34:50, Vlastimil Babka wrote:
>>>> On 03/16/2015 03:08 PM, Michal Hocko wrote:
>>>>> @@ -1080,6 +1080,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>>>>   	unsigned long haddr;
>>>>>   	unsigned long mmun_start;	/* For mmu_notifiers */
>>>>>   	unsigned long mmun_end;		/* For mmu_notifiers */
>>>>> +	gfp_t huge_gfp = GFP_TRANSHUGE;	/* for allocation and charge */
>>>>
>>>> This value is actually never used. Is it here because the compiler emits a
>>>> spurious non-initialized value warning otherwise? It should be easy for it
>>>> to prove that setting new_page to something non-null implies initializing
>>>> huge_gfp (in the hunk below), and NULL new_page means it doesn't reach the
>>>> mem_cgroup_try_charge() call?
>>>
>>> No, I haven't tried to workaround the compiler. It just made the code
>>> more obvious to me. I can remove the initialization if you prefer, of
>>> course.
>>
>> Yeah IMHO it would be better to remove it, if possible. Leaving it has the
>> (albeit small) chance that future patch will again use the value in the code
>> before it's determined based on defrag setting.
>
> Wouldn't an uninitialized value be used in such a case?

Yeah, but then you should get a (correct) warning :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
