Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5A4096B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:41:14 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 13:41:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ED05B6E8044
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:41:04 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6THf9An163914
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:41:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6THf9vO008446
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:41:09 -0300
Message-ID: <51F6A933.4050301@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2013 10:41:07 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] rbtree: add rbtree_postorder_for_each_entry_safe()
 helper
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com> <1374873223-25557-3-git-send-email-cody@linux.vnet.ibm.com> <20130729150624.GB4381@variantweb.net>
In-Reply-To: <20130729150624.GB4381@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On 07/29/2013 08:06 AM, Seth Jennings wrote:
> On Fri, Jul 26, 2013 at 02:13:40PM -0700, Cody P Schafer wrote:
>> Because deletion (of the entire tree) is a relatively common use of the
>> rbtree_postorder iteration, and because doing it safely means fiddling
>> with temporary storage, provide a helper to simplify postorder rbtree
>> iteration.
>>
>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>> ---
>>   include/linux/rbtree.h | 17 +++++++++++++++++
>>   1 file changed, 17 insertions(+)
>>
>> diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
>> index 2879e96..64ab98b 100644
>> --- a/include/linux/rbtree.h
>> +++ b/include/linux/rbtree.h
>> @@ -85,4 +85,21 @@ static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
>>   	*rb_link = node;
>>   }
>>
>> +/**
>> + * rbtree_postorder_for_each_entry_safe - iterate over rb_root in post order of
>> + * given type safe against removal of rb_node entry
>> + *
>> + * @pos:	the 'type *' to use as a loop cursor.
>> + * @n:		another 'type *' to use as temporary storage
>> + * @root:	'rb_root *' of the rbtree.
>> + * @field:	the name of the rb_node field within 'type'.
>> + */
>> +#define rbtree_postorder_for_each_entry_safe(pos, n, root, field) \
>> +	for (pos = rb_entry(rb_first_postorder(root), typeof(*pos), field),\
>> +	      n = rb_entry(rb_next_postorder(&pos->field), \
>> +		      typeof(*pos), field); \
>> +	     &pos->field; \
>> +	     pos = n, \
>> +	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field))
>
> One too many spaces.  Also mix of tabs and spaces is weird, but
> checkpatch doesn't complain so...
>
> Seth

The extra space is to set off ';' vs ',' in the macro. And I did that 
instead of a tab to avoid wrapping. I've adjusted them (in the next 
version) to use the same style as list.h's list_for_each*() macros. 
Which results in more wrapping :( .

>
>> +
>>   #endif	/* _LINUX_RBTREE_H */
>> --
>> 1.8.3.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
