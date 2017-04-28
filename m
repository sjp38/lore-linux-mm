Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED3506B02EE
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:17:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44so1787903wry.5
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:17:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n188si5874663wmg.3.2017.04.28.02.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 02:17:43 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3S9Dppx131450
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:17:42 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a3hj06ch0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:17:42 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 28 Apr 2017 10:17:40 +0100
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz> <20170428073136.GE8143@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 28 Apr 2017 11:17:34 +0200
MIME-Version: 1.0
In-Reply-To: <20170428073136.GE8143@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 28/04/2017 09:31, Michal Hocko wrote:
> [CC Johannes and Vladimir - the patch is
> http://lkml.kernel.org/r/1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com]
> 
> On Fri 28-04-17 08:07:55, Michal Hocko wrote:
>> On Thu 27-04-17 13:51:23, Andi Kleen wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>>
>>>> On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
>>>>> When page are poisoned, they should be uncharged from the root memory
>>>>> cgroup.
>>>>>
>>>>> This is required to avoid a BUG raised when the page is onlined back:
>>>>> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
>>>>> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
>>>>> index:0x1
>>>>> flags: 0x3ffff800200000(hwpoison)
>>>>
>>>> My knowledge of memory poisoning is very rudimentary but aren't those
>>>> pages supposed to leak and never come back? In other words isn't the
>>>> hoplug code broken because it should leave them alone?
>>>
>>> Yes that would be the right interpretation. If it was really offlined
>>> due to a hardware error the memory will be poisoned and any access
>>> could cause a machine check.
>>
>> OK, thanks for the clarification. Then I am not sure the patch is
>> correct. Why do we need to uncharge that page at all?
> 
> Now, I have realized that we actually want to uncharge that page because
> it will pin the memcg and we do not want to have that memcg and its
> whole hierarchy pinned as well. This used to work before the charge
> rework 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") I guess
> because we used to uncharge on page cache removal.
> 
> I do not think the patch is correct, though. memcg_kmem_enabled() will
> check whether kmem accounting is enabled and we are talking about page
> cache pages here. You should be using mem_cgroup_uncharge instead.

Thanks for the review Michal.

I was not comfortable either with this patch.

I did some tests calling mem_cgroup_uncharge() when isolate_lru_page()
succeeds only, so not calling it if isolate_lru_page() failed.

This seems to work as well, so if everyone agree on that, I'll send a
new version soon.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
