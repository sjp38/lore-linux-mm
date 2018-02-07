Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 155A86B02DF
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 02:57:39 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k6so2753848pgt.15
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 23:57:39 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0136.outbound.protection.outlook.com. [104.47.1.136])
        by mx.google.com with ESMTPS id 1-v6si722577plw.164.2018.02.06.23.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 23:57:37 -0800 (PST)
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
Date: Wed, 7 Feb 2018 10:57:28 +0300
MIME-Version: 1.0
In-Reply-To: <20180207050200.GH3617@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Matthew Wilcox <willy@infradead.org>
Cc: josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On 07.02.2018 08:02, Paul E. McKenney wrote:
> On Tue, Feb 06, 2018 at 08:23:34PM -0800, Matthew Wilcox wrote:
>> On Tue, Feb 06, 2018 at 06:17:03PM -0800, Paul E. McKenney wrote:
>>> So it is OK to kvmalloc() something and pass it to either kfree() or
>>> kvfree(), and it had better be OK to kvmalloc() something and pass it
>>> to kvfree().
>>>
>>> Is it OK to kmalloc() something and pass it to kvfree()?
>>
>> Yes, it absolutely is.
>>
>> void kvfree(const void *addr)
>> {
>>         if (is_vmalloc_addr(addr))
>>                 vfree(addr);
>>         else
>>                 kfree(addr);
>> }
>>
>>> If so, is it really useful to have two different names here, that is,
>>> both kfree_rcu() and kvfree_rcu()?
>>
>> I think it's handy to have all three of kvfree_rcu(), kfree_rcu() and
>> vfree_rcu() available in the API for the symmetry of calling kmalloc()
>> / kfree_rcu().
>>
>> Personally, I would like us to rename kvfree() to just free(), and have
>> malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
>> fight yet.
> 
> But why not just have the existing kfree_rcu() API cover both kmalloc()
> and kvmalloc()?  Perhaps I am not in the right forums, but I am not hearing
> anyone arguing that the RCU API has too few members.  ;-)

People, far from RCU internals, consider kfree_rcu() like an extension
of kfree(). And it's not clear it's need to dive into kfree_rcu() comments,
when someone is looking a primitive to free vmalloc'ed memory.

Also, construction like

obj = kvmalloc();
kfree_rcu(obj);

makes me think it's legitimately to use plain kfree() as pair bracket to kvmalloc().

So the significant change of kfree_rcu() behavior will complicate stable backporters
life, because they will need to keep in mind such differences between different
kernel versions.

It seems if we are going to use the single primitive for both kmalloc()
and kvmalloc() memory, it has to have another name. But I don't see problems
with having both kfree_rcu() and kvfree_rcu().

Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
