Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFC56B0257
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:05:18 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so144432828pac.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:05:18 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id ff4si23311973pab.164.2015.09.14.06.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Sep 2015 06:05:15 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 14 Sep 2015 23:05:11 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0713C357804F
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:05:08 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8ED4xr059113668
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:05:08 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8ED4YZ6003242
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:04:35 +1000
Message-ID: <55F6C637.6080807@linux.vnet.ibm.com>
Date: Mon, 14 Sep 2015 18:35:59 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH  1/2] mm: Replace nr_node_ids for loop with for_each_node
 in list lru
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20150914090010.GB30743@esperanza> <55F6B1F3.1010702@linux.vnet.ibm.com> <20150914120455.GD30743@esperanza>
In-Reply-To: <20150914120455.GD30743@esperanza>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/14/2015 05:34 PM, Vladimir Davydov wrote:
> On Mon, Sep 14, 2015 at 05:09:31PM +0530, Raghavendra K T wrote:
>> On 09/14/2015 02:30 PM, Vladimir Davydov wrote:
>>> On Wed, Sep 09, 2015 at 12:01:46AM +0530, Raghavendra K T wrote:
>>>> The functions used in the patch are in slowpath, which gets called
>>>> whenever alloc_super is called during mounts.
>>>>
>>>> Though this should not make difference for the architectures with
>>>> sequential numa node ids, for the powerpc which can potentially have
>>>> sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
>>>> is common), this patch saves some unnecessary allocations for
>>>> non existing numa nodes.
>>>>
>>>> Even without that saving, perhaps patch makes code more readable.
>>>
>>> Do I understand correctly that node 0 must always be in
>>> node_possible_map? I ask, because we currently test
>>> lru->node[0].memcg_lrus to determine if the list is memcg aware.
>>>
>>
>> Yes, node 0 is always there. So it should not be a problem.
>
> I think it should be mentioned in the comment to list_lru_memcg_aware
> then.
>

Something like this: ?
static inline bool list_lru_memcg_aware(struct list_lru *lru)
{
         /*
          * This needs node 0 to be always present, even
          * in the systems supporting sparse numa ids.
          */
         return !!lru->node[0].memcg_lrus;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
