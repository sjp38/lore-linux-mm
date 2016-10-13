Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C85E06B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:10:53 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v138so42588100qka.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:10:53 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r63si5067096qkb.170.2016.10.12.17.10.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 17:10:50 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
References: <57FCF07C.2020103@zoho.com>
 <20161012144112.0494082cf4cbd07609d2405d@linux-foundation.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57FED0B1.3010506@zoho.com>
Date: Thu, 13 Oct 2016 08:09:21 +0800
MIME-Version: 1.0
In-Reply-To: <20161012144112.0494082cf4cbd07609d2405d@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, cl@linux.com

On 10/13/2016 05:41 AM, Andrew Morton wrote:
> On Tue, 11 Oct 2016 22:00:28 +0800 zijun_hu <zijun_hu@zoho.com> wrote:
> 
>> as shown by pcpu_build_alloc_info(), the number of units within a percpu
>> group is educed by rounding up the number of CPUs within the group to
>> @upa boundary, therefore, the number of CPUs isn't equal to the units's
>> if it isn't aligned to @upa normally. however, pcpu_page_first_chunk()
>> uses BUG_ON() to assert one number is equal the other roughly, so a panic
>> is maybe triggered by the BUG_ON() falsely.
>>
>> in order to fix this issue, the number of CPUs is rounded up then compared
>> with units's, the BUG_ON() is replaced by warning and returning error code
>> as well to keep system alive as much as possible.
> 
> Under what circumstances is the triggered?  In other words, what are
> the end-user visible effects of the fix?
> 

the BUG_ON() takes effect when the number of CPUs isn't aligned @upa,
the BUG_ON() should not be triggered under this normal circumstances.
the aim of this fixing is prevent the BUG_ON() which is triggered under
the case.

see below original code segments for reason.
pcpu_build_alloc_info(){
...

	for_each_possible_cpu(cpu)
		if (group_map[cpu] == group)
			gi->cpu_map[gi->nr_units++] = cpu;
	gi->nr_units = roundup(gi->nr_units, upa);

calculate the number of CPUs belonging to a group into relevant @gi->nr_units
then roundup @gi->nr_units up to @upa for itself

	unit += gi->nr_units;
...
}

pcpu_page_first_chunk() {
...
	ai = pcpu_build_alloc_info(reserved_size, 0, PAGE_SIZE, NULL);
	if (IS_ERR(ai))
		return PTR_ERR(ai);
	BUG_ON(ai->nr_groups != 1);
	BUG_ON(ai->groups[0].nr_units != num_possible_cpus());

it seems there is only one group and all CPUs belong to the group
but compare the number of CPUs with the number of units directly.
...
}

as shown by comments in above function. ai->groups[0].nr_units
should equal to roundup(num_possible_cpus(), @upa) other than
num_possible_cpus() directly.


> I mean, this is pretty old code (isn't it?) so what are you doing that
> triggers this?
> 
> 
i am learning memory management source and find the inconsistency and think
the BUG_ON() maybe be triggered under this special normal but possible case
it maybe a logic error 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
