Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97C0A6B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 20:56:20 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e9so17820234ioj.18
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 17:56:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z7-v6si3069329ita.108.2018.04.03.17.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 17:56:19 -0700 (PDT)
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
References: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
 <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
 <20180403205822.GB30145@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <d434c58c-082b-9a17-8d15-9c66e0c1941a@oracle.com>
Date: Tue, 3 Apr 2018 17:55:55 -0700
MIME-Version: 1.0
In-Reply-To: <20180403205822.GB30145@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, brouer@redhat.com, linux-mm@kvack.org


On 04/03/2018 01:58 PM, Matthew Wilcox wrote:
> On Tue, Apr 03, 2018 at 10:22:53AM -0700, rao.shoaib@oracle.com wrote:
>> +++ b/mm/slab.h
>> @@ -80,6 +80,29 @@ extern const struct kmalloc_info_struct {
>>   	unsigned long size;
>>   } kmalloc_info[];
>>   
>> +#define	RCU_MAX_ACCUMULATE_SIZE	25
>> +
>> +struct rcu_bulk_free_container {
>> +	struct	rcu_head rbfc_rcu;
>> +	int	rbfc_entries;
>> +	void	*rbfc_data[RCU_MAX_ACCUMULATE_SIZE];
>> +	struct	rcu_bulk_free *rbfc_rbf;
>> +};
>> +
>> +struct rcu_bulk_free {
>> +	struct	rcu_head rbf_rcu; /* used to schedule monitor process */
>> +	spinlock_t	rbf_lock;
>> +	struct		rcu_bulk_free_container *rbf_container;
>> +	struct		rcu_bulk_free_container *rbf_cached_container;
>> +	struct		rcu_head *rbf_list_head;
>> +	int		rbf_list_size;
>> +	int		rbf_cpu;
>> +	int		rbf_empty;
>> +	int		rbf_polled;
>> +	bool		rbf_init;
>> +	bool		rbf_monitor;
>> +};
> I think you might be better off with an IDR.  The IDR can always
> contain one entry, so there's no need for this 'rbf_list_head' or
> __rcu_bulk_schedule_list.  The IDR contains its first 64 entries in
> an array (if that array can be allocated), so it's compatible with the
> kfree_bulk() interface.
>
I have just familiarized myself with what IDR is by reading your 
article. If I am incorrect please correct me.

The list and head you have pointed are only usedA  if the container can 
not be allocated. That could happen with IDR as well. Note that the 
containers are allocated at boot time and are re-used.

IDR seems to have some overhead, such as I have to specifically add the 
pointer and free the ID, plus radix tree maintenance.

The change would also require retesting. So I would like to keep the 
current design.

Regards,

Shoaib
