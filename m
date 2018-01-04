Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93FFD280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 15:36:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id i67so2782767ioe.4
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 12:36:26 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u20si3218668ioi.209.2018.01.04.12.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 12:36:25 -0800 (PST)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
Date: Thu, 4 Jan 2018 12:35:55 -0800
MIME-Version: 1.0
In-Reply-To: <20180104013807.GA31392@tardis>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

Hi Boqun,

Thanks a lot for all your guidance and for catching the cut and paster 
error. Please see inline.


On 01/03/2018 05:38 PM, Boqun Feng wrote:
>
> But you introduced a bug here, you should use rcu_state_p instead of
> &rcu_sched_state as the third parameter for __call_rcu().
>
> Please re-read:
>
> 	https://marc.info/?l=linux-mm&m=151390529209639
>
> , and there are other comments, which you still haven't resolved in this
> version. You may want to write a better commit log to explain the
> reasons of each modifcation and fix bugs or typos in your previous
> version. That's how review process works ;-)
>
> Regards,
> Boqun
>
This is definitely a serious error. Thanks for catching this.

As far as your previous comments are concerned, only the following one 
has not been addressed. Can you please elaborate as I do not understand 
the comment. The code was expanded because the new macro expansion check 
fails. Based on Matthew Wilcox's comment I have reverted rcu_head_name 
back to rcu_head.

> +#define kfree_rcu(ptr, rcu_head_name)	\
> +	do { \
> +		typeof(ptr) __ptr = ptr;	\
> +		unsigned long __off = offsetof(typeof(*(__ptr)), \
> +						      rcu_head_name); \
> +		struct rcu_head *__rptr = (void *)__ptr + __off; \
> +		__kfree_rcu(__rptr, __off); \
> +	} while (0)

why do you want to open code this?

Does the following text for the commit log looks better.

kfree_rcu() should use the new kfree_bulk() interface for freeing rcu 
structures

The newly implemented kfree_bulk() interfaces are more efficient, using 
the interfaces for freeing rcu structures has shown performance 
improvements in synthetic benchmarks that allocate and free rcu 
structures at a high rate.

Shoaib

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
