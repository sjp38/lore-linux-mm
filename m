Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B9A936B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:33:14 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 13:33:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BD7306E8054
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:33:05 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6THX8Jl103990
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:33:09 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6THX4Wf018419
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:33:05 -0600
Message-ID: <51F6A74B.1060008@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2013 10:32:59 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] rbtree: add postorder iteration functions
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com> <1374873223-25557-2-git-send-email-cody@linux.vnet.ibm.com> <20130729150147.GA4381@variantweb.net>
In-Reply-To: <20130729150147.GA4381@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On 07/29/2013 08:01 AM, Seth Jennings wrote:
> On Fri, Jul 26, 2013 at 02:13:39PM -0700, Cody P Schafer wrote:
>> diff --git a/lib/rbtree.c b/lib/rbtree.c
>> index c0e31fe..65f4eff 100644
>> --- a/lib/rbtree.c
>> +++ b/lib/rbtree.c
>> @@ -518,3 +518,43 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
>>   	*new = *victim;
>>   }
>>   EXPORT_SYMBOL(rb_replace_node);
>> +
>> +static struct rb_node *rb_left_deepest_node(const struct rb_node *node)
>> +{
>> +	for (;;) {
>> +		if (node->rb_left)
>> +			node = node->rb_left;
>
> Assigning to an argument passed as const seems weird to me.  I would
> think it shouldn't compile but it does.  I guess my understanding of
> const is incomplete.
>

Ya, that is due to const's binding:
	const struct rb_node *node1; // the thing pointed to is const
	const struct rb_node node2;  // node is const
	struct rb_node *const node3; // node is const
	const struct rb_node *const node4; // both node and the thing
					   // pointed too are const

And so ends up being perfectly legal (I use the first case listed here).

>> +		else if (node->rb_right)
>> +			node = node->rb_right;
>> +		else
>> +			return (struct rb_node *)node;
>> +	}
>> +}
>> +
>> +struct rb_node *rb_next_postorder(const struct rb_node *node)
>> +{
>> +	const struct rb_node *parent;
>> +	if (!node)
>> +		return NULL;
>> +	parent = rb_parent(node);
>
> Again here.
>
> Seth
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
