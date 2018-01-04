Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6524F280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 16:33:09 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id d17so2822138ioc.23
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 13:33:09 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id c17si3419438itc.33.2018.01.04.13.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 13:33:07 -0800 (PST)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
From: Rao Shoaib <rao.shoaib@oracle.com>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
Message-ID: <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
Date: Thu, 4 Jan 2018 13:27:49 -0800
MIME-Version: 1.0
In-Reply-To: <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 01/04/2018 12:35 PM, Rao Shoaib wrote:
> Hi Boqun,
>
> Thanks a lot for all your guidance and for catching the cut and paster 
> error. Please see inline.
>
>
> On 01/03/2018 05:38 PM, Boqun Feng wrote:
>>
>> But you introduced a bug here, you should use rcu_state_p instead of
>> &rcu_sched_state as the third parameter for __call_rcu().
>>
>> Please re-read:
>>
>>     https://marc.info/?l=linux-mm&m=151390529209639
>>
>> , and there are other comments, which you still haven't resolved in this
>> version. You may want to write a better commit log to explain the
>> reasons of each modifcation and fix bugs or typos in your previous
>> version. That's how review process works ;-)
>>
>> Regards,
>> Boqun
>>
> This is definitely a serious error. Thanks for catching this.
>
> As far as your previous comments are concerned, only the following one 
> has not been addressed. Can you please elaborate as I do not 
> understand the comment. The code was expanded because the new macro 
> expansion check fails. Based on Matthew Wilcox's comment I have 
> reverted rcu_head_name back to rcu_head.
It turns out I did not remember the real reason for the change. With the 
macro rewritten, using rcu_head as a macro argument does not work 
because it conflicts with the name of the type 'struct rcu_head' used in 
the macro. I have renamed the macro argument to rcu_name.

Shoaib
>
>> +#define kfree_rcu(ptr, rcu_head_name) \
>> +    do { \
>> +        typeof(ptr) __ptr = ptr;    \
>> +        unsigned long __off = offsetof(typeof(*(__ptr)), \
>> +                              rcu_head_name); \
>> +        struct rcu_head *__rptr = (void *)__ptr + __off; \
>> +        __kfree_rcu(__rptr, __off); \
>> +    } while (0)
>
> why do you want to open code this?
>
> Does the following text for the commit log looks better.
>
> kfree_rcu() should use the new kfree_bulk() interface for freeing rcu 
> structures
>
> The newly implemented kfree_bulk() interfaces are more efficient, 
> using the interfaces for freeing rcu structures has shown performance 
> improvements in synthetic benchmarks that allocate and free rcu 
> structures at a high rate.
>
> Shoaib
>
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
