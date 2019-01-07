Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 536F58E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 02:31:32 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j8so31345575plb.1
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 23:31:32 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id k5si12736984plt.111.2019.01.06.23.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 06 Jan 2019 23:31:30 -0800 (PST)
Subject: Re: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU
 primitives
References: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
 <20190104183715.GC187360@arrakis.emea.arm.com>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
Date: Mon, 7 Jan 2019 15:31:18 +0800
MIME-Version: 1.0
In-Reply-To: <20190104183715.GC187360@arrakis.emea.arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, paulmck@linux.ibm.com, josh@joshtriplett.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/5/19 2:37 AM, Catalin Marinas wrote:
> On Fri, Jan 04, 2019 at 10:29:13PM +0800, zhe.he@windriver.com wrote:
>> It's not necessary to keep consistency between readers and writers of
>> kmemleak_lock. RCU is more proper for this case. And in order to gain better
>> performance, we turn the reader locks to RCU read locks and writer locks to
>> normal spin locks.
> This won't work.
>
>> @@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
>>  	struct kmemleak_object *object;
>>  
>>  	rcu_read_lock();
>> -	read_lock_irqsave(&kmemleak_lock, flags);
>>  	object = lookup_object(ptr, alias);
>> -	read_unlock_irqrestore(&kmemleak_lock, flags);
> The comment on lookup_object() states that the kmemleak_lock must be
> held. That's because we don't have an RCU-like mechanism for removing
> removing objects from the object_tree_root:
>
>>  
>>  	/* check whether the object is still available */
>>  	if (object && !get_object(object))
>> @@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
>>  	unsigned long flags;
>>  	struct kmemleak_object *object;
>>  
>> -	write_lock_irqsave(&kmemleak_lock, flags);
>> +	spin_lock_irqsave(&kmemleak_lock, flags);
>>  	object = lookup_object(ptr, alias);
>>  	if (object) {
>>  		rb_erase(&object->rb_node, &object_tree_root);
>>  		list_del_rcu(&object->object_list);
>>  	}
>> -	write_unlock_irqrestore(&kmemleak_lock, flags);
>> +	spin_unlock_irqrestore(&kmemleak_lock, flags);
> So here, while list removal is RCU-safe, rb_erase() is not.
>
> If you have time to implement an rb_erase_rcu(), than we could reduce
> the locking in kmemleak.

Thanks, I really neglected that rb_erase is not RCU-safe here.

I'm not sure if it is practically possible to implement rb_erase_rcu. Here
is my concern:
In the code paths starting from rb_erase, the tree is tweaked at many
places, in both __rb_erase_augmented and ____rb_erase_color. To my
understanding, there are many intermediate versions of the tree
during the erasion. In some of the versions, the tree is incomplete, i.e.
some nodes(not the one to be deleted) are invisible to readers. I'm not
sure if this is acceptable as an RCU implementation. Does it mean we
need to form a rb_erase_rcu from scratch?

And are there any other concerns about this attempt?

Let me add RCU supporters Paul and Josh here. Your advice would be
highly appreciated.

Thanks,
Zhe


>
