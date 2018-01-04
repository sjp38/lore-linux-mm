Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30C9C6B0385
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 17:19:11 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c33so3108221itf.8
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 14:19:11 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g137si3229669ioe.172.2018.01.04.14.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 14:19:10 -0800 (PST)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
 <20180104214658.GA20740@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
Date: Thu, 4 Jan 2018 14:18:50 -0800
MIME-Version: 1.0
In-Reply-To: <20180104214658.GA20740@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 01/04/2018 01:46 PM, Matthew Wilcox wrote:
> On Thu, Jan 04, 2018 at 01:27:49PM -0800, Rao Shoaib wrote:
>> On 01/04/2018 12:35 PM, Rao Shoaib wrote:
>>> As far as your previous comments are concerned, only the following one
>>> has not been addressed. Can you please elaborate as I do not understand
>>> the comment. The code was expanded because the new macro expansion check
>>> fails. Based on Matthew Wilcox's comment I have reverted rcu_head_name
>>> back to rcu_head.
>> It turns out I did not remember the real reason for the change. With the
>> macro rewritten, using rcu_head as a macro argument does not work because it
>> conflicts with the name of the type 'struct rcu_head' used in the macro. I
>> have renamed the macro argument to rcu_name.
>>
>> Shoaib
>>>> +#define kfree_rcu(ptr, rcu_head_name) \
>>>> +A A A  do { \
>>>> +A A A A A A A  typeof(ptr) __ptr = ptr;A A A  \
>>>> +A A A A A A A  unsigned long __off = offsetof(typeof(*(__ptr)), \
>>>> +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  rcu_head_name); \
>>>> +A A A A A A A  struct rcu_head *__rptr = (void *)__ptr + __off; \
>>>> +A A A A A A A  __kfree_rcu(__rptr, __off); \
>>>> +A A A  } while (0)
>>> why do you want to open code this?
> But why are you changing this macro at all?  If it was to avoid the
> double-mention of "ptr", then you haven't done that.
I have -- I do not get the error because ptr is being assigned only one. 
If you have a better way than let me know and I will be happy to make 
the change.

Shoaib.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
