Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3598E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:18:59 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s70so11007584qks.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:18:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c23sor76393464qte.40.2019.01.11.16.18.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 16:18:58 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <20190111231652.GN6310@bombadil.infradead.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <463fa1f6-4ee6-ef4d-431c-3c392c827792@lca.pw>
Date: Fri, 11 Jan 2019 19:18:55 -0500
MIME-Version: 1.0
In-Reply-To: <20190111231652.GN6310@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, walken@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/11/19 6:16 PM, Matthew Wilcox wrote:
> On Fri, Jan 11, 2019 at 03:58:43PM -0500, Qian Cai wrote:
>> diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
>> index b7055b2a07d3..afad0213a117 100644
>> --- a/lib/rbtree_test.c
>> +++ b/lib/rbtree_test.c
>> @@ -345,6 +345,17 @@ static int __init rbtree_test_init(void)
>>  		check(0);
>>  	}
>>  
>> +	/*
>> +	 * a little regression test to catch a bug may be introduced by
>> +	 * 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
>> +	 * necessary)
>> +	 */
>> +	insert(nodes, &root);
>> +	nodes->rb.__rb_parent_color = RB_RED;
>> +	insert(nodes + 1, &root);
>> +	erase(nodes + 1, &root);
>> +	erase(nodes, &root);
> 
> That's not a fair test!  You're poking around in the data structure to
> create the situation.  This test would have failed before 6d58452dc06 too.
> How do we create a tree that has a red parent at root, only using insert()
> and erase()?
> 

If only I knew how to reproduce this myself, I might be able to figure out how
it ends up with the red root in the first place.
