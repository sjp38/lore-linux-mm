Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 410676B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 22:35:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d132so5992643oig.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 19:35:36 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t13si12764586ott.132.2016.06.27.19.35.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 19:35:35 -0700 (PDT)
Message-ID: <5771E25C.10605@huawei.com>
Date: Tue, 28 Jun 2016 10:35:08 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: A question about the patch(commit :c777e2a8b654 powerpc/mm: Fix
 Multi hit ERAT cause by recent THP update)
References: <576AA934.4090504@huawei.com> <20160623092946.GA30082@dhcp22.suse.cz> <20160623093411.GB30077@dhcp22.suse.cz>
In-Reply-To: <20160623093411.GB30077@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>

On 2016/6/23 17:34, Michal Hocko wrote:
> On Thu 23-06-16 11:29:46, Michal Hocko wrote:
>> On Wed 22-06-16 23:05:24, zhong jiang wrote:
>>> Hi  Aneesh
>>>
>>>                 CPU0                            CPU1
>>>     shrink_page_list()
>>>       add_to_swap()
>>>         split_huge_page_to_list()
>>>           __split_huge_pmd_locked()
>>>             pmdp_huge_clear_flush_notify()
>>>         // pmd_none() == true
>>>                                         exit_mmap()
>>>                                           unmap_vmas()
>>>                                             zap_pmd_range()
>>>                                               // no action on pmd since pmd_none() == true
>>>         pmd_populate()
>>>
>>>
>>> the mm should be the last user  when CPU1 process is exiting,  CPU0 must be a own mm .
>>> two different process  should not be influenced each other.  in a words , they should not
>>> have race.
>> No this is a different scenario than
>> http://lkml.kernel.org/r/1466517956-13875-1-git-send-email-zhongjiang@huawei.com
>> we were discussing recently. Note that pages are still on the LRU lists
>> while the mm which maps them is exiting. So the above race is very much
>> possible.
> And just to clarify, I haven't checked the current code after c777e2a8b654
> ("powerpc/mm: Fix Multi hit ERAT cause by recent THP update") which is
> ppc specific and I have no idea whether other arches need a similar
> treatment. I was merely trying to explain that the mm exclusive argument
> doesn't apply to reclaim vs. exit races.
  Thank for your explaintion!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
