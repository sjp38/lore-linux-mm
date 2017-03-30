Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 409A06B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 20:53:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n129so26903389pga.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 17:53:58 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v5si445333pgj.302.2017.03.29.17.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 17:53:57 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 2/9] mm, memcg: Support to charge/uncharge multiple swap entries
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328053209.25876-3-ying.huang@intel.com>
	<20170329165722.GB31821@cmpxchg.org>
Date: Thu, 30 Mar 2017 08:53:50 +0800
In-Reply-To: <20170329165722.GB31821@cmpxchg.org> (Johannes Weiner's message
	of "Wed, 29 Mar 2017 12:57:22 -0400")
Message-ID: <87k277twip.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Tue, Mar 28, 2017 at 01:32:02PM +0800, Huang, Ying wrote:
>> @@ -5908,16 +5907,19 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>>  		css_put(&memcg->css);
>>  }
>>  
>> -/*
>> - * mem_cgroup_try_charge_swap - try charging a swap entry
>> +/**
>> + * mem_cgroup_try_charge_swap - try charging a set of swap entries
>>   * @page: page being added to swap
>> - * @entry: swap entry to charge
>> + * @entry: the first swap entry to charge
>> + * @nr_entries: the number of swap entries to charge
>>   *
>> - * Try to charge @entry to the memcg that @page belongs to.
>> + * Try to charge @nr_entries swap entries starting from @entry to the
>> + * memcg that @page belongs to.
>>   *
>>   * Returns 0 on success, -ENOMEM on failure.
>>   */
>> -int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
>> +int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
>> +			       unsigned int nr_entries)
>
> I've pointed this out before,

Yes.  And I have replied to your original comments too :-)

> but there doesn't seem to be a reason to
> pass @nr_entries when we have the struct page. Why can't this function
> just check PageTransHuge() by itself?

Because sometimes we need to charge one swap entry for a THP.  Please
take a look at the original add_to_swap() implementation.  For a THP,
one swap entry will be allocated and charged to the mem cgroup before
the THP is split.  And I think it is not easy to change this, because we
don't want to split THP if the mem cgroup for swap exceeds its limit.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
