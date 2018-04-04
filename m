Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62AE16B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 03:18:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r141so7571866ior.15
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 00:18:10 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h186-v6si1914492ite.21.2018.04.04.00.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 00:18:09 -0700 (PDT)
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
References: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
 <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
 <20180403205822.GB30145@bombadil.infradead.org>
 <d434c58c-082b-9a17-8d15-9c66e0c1941a@oracle.com>
 <20180404022347.GA17512@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <954a9ea2-5202-4ee3-1fa2-21acf8d07cdb@oracle.com>
Date: Wed, 4 Apr 2018 00:16:06 -0700
MIME-Version: 1.0
In-Reply-To: <20180404022347.GA17512@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, brouer@redhat.com, linux-mm@kvack.org



On 04/03/2018 07:23 PM, Matthew Wilcox wrote:
> On Tue, Apr 03, 2018 at 05:55:55PM -0700, Rao Shoaib wrote:
>> On 04/03/2018 01:58 PM, Matthew Wilcox wrote:
>>> I think you might be better off with an IDR.  The IDR can always
>>> contain one entry, so there's no need for this 'rbf_list_head' or
>>> __rcu_bulk_schedule_list.  The IDR contains its first 64 entries in
>>> an array (if that array can be allocated), so it's compatible with the
>>> kfree_bulk() interface.
>>>
>> I have just familiarized myself with what IDR is by reading your article. If
>> I am incorrect please correct me.
>>
>> The list and head you have pointed are only usedA  if the container can not
>> be allocated. That could happen with IDR as well. Note that the containers
>> are allocated at boot time and are re-used.
> No, it can't happen with the IDR.  The IDR can always contain one entry
> without allocating anything.  If you fail to allocate the second entry,
> just free the first entry.
>
>> IDR seems to have some overhead, such as I have to specifically add the
>> pointer and free the ID, plus radix tree maintenance.
> ... what?  Adding a pointer is simply idr_alloc(), and you get back an
> integer telling you which index it has.  Your data structure has its
> own set of overhead.
The only overhead is a pointer that points to the head and an int to 
keep count. If I use idr, I would have to allocate an struct idr which 
is much larger. idr_alloc()/idr_destroy() operations are much more 
costly than updating two pointers. As the pointers are stored in 
slots/nodes corresponding to the id, I wouldA  have to retrieve the 
pointers by calling idr_remove() to pass them to be freed, the 
slots/nodes would constantly be allocated and freed.

IDR is a very useful interface for allocating/managing ID's but I really 
do not see the justification for using it over here, perhaps you can 
elaborate more on the benefits and also on how I can just pass the array 
to be freed.

Shoaib
