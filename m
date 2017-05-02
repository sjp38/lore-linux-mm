Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C470D6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:59:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s62so27959878pgc.2
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:59:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v21si5102757pgb.116.2017.05.02.07.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:59:38 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42Eri37037628
	for <linux-mm@kvack.org>; Tue, 2 May 2017 10:59:38 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a68vwy74s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 10:59:38 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 2 May 2017 15:59:35 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170427143721.GK4706@dhcp22.suse.cz> <87pofxk20k.fsf@firstfloor.org>
 <20170428060755.GA8143@dhcp22.suse.cz> <20170428073136.GE8143@dhcp22.suse.cz>
 <3eb86373-dafc-6db9-82cd-84eb9e8b0d37@linux.vnet.ibm.com>
 <20170428134831.GB26705@dhcp22.suse.cz>
Date: Tue, 2 May 2017 16:59:30 +0200
MIME-Version: 1.0
In-Reply-To: <20170428134831.GB26705@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c8ce6056-e89b-7470-c37a-85ab5bc7a5b2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 28/04/2017 15:48, Michal Hocko wrote:
> On Fri 28-04-17 11:17:34, Laurent Dufour wrote:
>> On 28/04/2017 09:31, Michal Hocko wrote:
>>> [CC Johannes and Vladimir - the patch is
>>> http://lkml.kernel.org/r/1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com]
>>>
>>> On Fri 28-04-17 08:07:55, Michal Hocko wrote:
>>>> On Thu 27-04-17 13:51:23, Andi Kleen wrote:
>>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>>
>>>>>> On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
>>>>>>> When page are poisoned, they should be uncharged from the root memory
>>>>>>> cgroup.
>>>>>>>
>>>>>>> This is required to avoid a BUG raised when the page is onlined back:
>>>>>>> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
>>>>>>> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
>>>>>>> index:0x1
>>>>>>> flags: 0x3ffff800200000(hwpoison)
>>>>>>
>>>>>> My knowledge of memory poisoning is very rudimentary but aren't those
>>>>>> pages supposed to leak and never come back? In other words isn't the
>>>>>> hoplug code broken because it should leave them alone?
>>>>>
>>>>> Yes that would be the right interpretation. If it was really offlined
>>>>> due to a hardware error the memory will be poisoned and any access
>>>>> could cause a machine check.
>>>>
>>>> OK, thanks for the clarification. Then I am not sure the patch is
>>>> correct. Why do we need to uncharge that page at all?
>>>
>>> Now, I have realized that we actually want to uncharge that page because
>>> it will pin the memcg and we do not want to have that memcg and its
>>> whole hierarchy pinned as well. This used to work before the charge
>>> rework 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") I guess
>>> because we used to uncharge on page cache removal.
>>>
>>> I do not think the patch is correct, though. memcg_kmem_enabled() will
>>> check whether kmem accounting is enabled and we are talking about page
>>> cache pages here. You should be using mem_cgroup_uncharge instead.
>>
>> Thanks for the review Michal.
>>
>> I was not comfortable either with this patch.
>>
>> I did some tests calling mem_cgroup_uncharge() when isolate_lru_page()
>> succeeds only, so not calling it if isolate_lru_page() failed.
> 
> Wait a moment. This cannot possibly work. isolate_lru_page asumes page
> count > 0 and increments the counter so the resulting page count is > 1
> I have only now realized that we have VM_BUG_ON_PAGE(page_count(page), page)
> in uncharge_list().

My mistake, my kernel was not build with CONFIG_DEBUG_VM set.
You're right this cannot work this way.

> This is getting quite hairy. What is the expected page count of the
> hwpoison page? I guess we would need to update the VM_BUG_ON in the
> memcg uncharge code to ignore the page count of hwpoison pages if it can
> be arbitrary.

Based on the experiment I did, page count == 2 when isolate_lru_page()
succeeds, even in the case of a poisoned page. In my case I think this
is because the page is still used by the process which is calling madvise().

I'm wondering if I'm looking at the right place. May be the poisoned
page should remain attach to the memory_cgroup until no one is using it.
In that case this means that something should be done when the page is
off-lined... I've to dig further here.

> 
> Before we go any further, is there any documentation about the expected
> behavior and the state of the hwpoison pages? I have a very bad feeling
> that the current behavior is quite arbitrary and "testing driven"
> holes plugging will make it only more messy. So let's start with the
> clear description of what should happen with the hwpoison pages.

I didn't find any documentation about that. The root cause is that a bug
message is displayed when a poisoned page is off-lined, may be this is
in that path that something is missing.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
