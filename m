Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 234A76B02CF
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 17:49:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g63so247138ioe.5
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 14:49:58 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y6si24244202itd.86.2018.01.02.14.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 14:49:57 -0800 (PST)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
Date: Tue, 2 Jan 2018 14:49:25 -0800
MIME-Version: 1.0
In-Reply-To: <20180102222341.GB20405@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 01/02/2018 02:23 PM, Matthew Wilcox wrote:
> On Tue, Jan 02, 2018 at 12:11:37PM -0800, rao.shoaib@oracle.com wrote:
>> -#define kfree_rcu(ptr, rcu_head)					\
>> -	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>> +#define kfree_rcu(ptr, rcu_head_name)	\
>> +	do { \
>> +		typeof(ptr) __ptr = ptr;	\
>> +		unsigned long __off = offsetof(typeof(*(__ptr)), \
>> +						      rcu_head_name); \
>> +		struct rcu_head *__rptr = (void *)__ptr + __off; \
>> +		__kfree_rcu(__rptr, __off); \
>> +	} while (0)
> I feel like you're trying to help people understand the code better,
> but using longer names can really work against that.  Reverting to
> calling the parameter 'rcu_head' lets you not split the line:
I think it is a matter of preference, what is the issue with line 
splitting ?
Coming from a background other than Linux I find it very annoying that 
Linux allows variables names that are meaning less. Linux does not even 
enforce adding a prefix for structure members, so trying to find out 
where a member is used or set is impossible using cscope.
I can not change the Linux requirements so I will go ahead and make the 
change in the next rev.

>
> +#define kfree_rcu(ptr, rcu_head)	\
> +	do { \
> +		typeof(ptr) __ptr = ptr;	\
> +		unsigned long __off = offsetof(typeof(*(__ptr)), rcu_head); \
> +		struct rcu_head *__rptr = (void *)__ptr + __off; \
> +		__kfree_rcu(__rptr, __off); \
> +	} while (0)
>
> Also, I don't understand why you're bothering to create __ptr here.
> I understand the desire to not mention the same argument more than once,
> but you have 'ptr' twice anyway.
>
> And it's good practice to enclose macro arguments in parentheses in case
> the user has done something really tricksy like pass in "p + 1".
>
> In summary, I don't see anything fundamentally better in your rewrite
> of kfree_rcu().  The previous version is more succinct, and to my
> mind, easier to understand.
I did not want to make thins change but it is required due to the new 
tests added for macro expansion where the same name as in the macro can 
not be used twice. It takes care of the 'p + 1' hazard that you refer to 
above.
>
>> +void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
>> +{
>> +	__call_rcu(head, func, &rcu_sched_state, -1, 1);
>> +}
>> -void kfree_call_rcu(struct rcu_head *head,
>> -		    rcu_callback_t func)
>> -{
>> -	__call_rcu(head, func, rcu_state_p, -1, 1);
>> -}
> You've silently changed this.  Why?  It might well be the right change,
> but it at least merits mentioning in the changelog.
This was to address a comment about me not changing the tiny 
implementation to be same as the tree implementation.

Shoaib
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
