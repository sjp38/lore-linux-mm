Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDC46B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:38:47 -0400 (EDT)
Received: by igxx6 with SMTP id x6so79351959igx.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 04:38:47 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id uw4si22846700pac.106.2015.09.14.04.38.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Sep 2015 04:38:46 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 14 Sep 2015 21:38:42 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 517083578052
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:38:40 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8EBcVZQ57409694
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:38:40 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8EBc7fg016225
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:38:07 +1000
Message-ID: <55F6B1F3.1010702@linux.vnet.ibm.com>
Date: Mon, 14 Sep 2015 17:09:31 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH  1/2] mm: Replace nr_node_ids for loop with for_each_node
 in list lru
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20150914090010.GB30743@esperanza>
In-Reply-To: <20150914090010.GB30743@esperanza>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/14/2015 02:30 PM, Vladimir Davydov wrote:
> Hi,
>
> On Wed, Sep 09, 2015 at 12:01:46AM +0530, Raghavendra K T wrote:
>> The functions used in the patch are in slowpath, which gets called
>> whenever alloc_super is called during mounts.
>>
>> Though this should not make difference for the architectures with
>> sequential numa node ids, for the powerpc which can potentially have
>> sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
>> is common), this patch saves some unnecessary allocations for
>> non existing numa nodes.
>>
>> Even without that saving, perhaps patch makes code more readable.
>
> Do I understand correctly that node 0 must always be in
> node_possible_map? I ask, because we currently test
> lru->node[0].memcg_lrus to determine if the list is memcg aware.
>

Yes, node 0 is always there. So it should not be a problem.

>>
>> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
>> ---
>>   mm/list_lru.c | 23 +++++++++++++++--------
>>   1 file changed, 15 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/list_lru.c b/mm/list_lru.c
>> index 909eca2..5a97f83 100644
>> --- a/mm/list_lru.c
>> +++ b/mm/list_lru.c
>> @@ -377,7 +377,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>>   {
>>   	int i;
>>
>> -	for (i = 0; i < nr_node_ids; i++) {
>> +	for_each_node(i) {
>>   		if (!memcg_aware)
>>   			lru->node[i].memcg_lrus = NULL;
>
> So, we don't explicitly initialize memcg_lrus for nodes that are not in
> node_possible_map. That's OK, because we allocate lru->node using
> kzalloc. However, this partial nullifying in case !memcg_aware looks
> confusing IMO. Let's drop it, I mean something like this:

Yes, you are right. and we do not have to have memcg_aware check inside
for loop too.
Will change as per your suggestion and send V2.
Thanks for the review.

>
> static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
> {
> 	int i;
>
> 	if (!memcg_aware)
> 		return 0;
>
> 	for_each_node(i) {
> 		if (memcg_init_list_lru_node(&lru->node[i]))
> 			goto fail;
> 	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
