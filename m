Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AF2936B007B
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 22:22:19 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so6416426pde.34
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 19:22:19 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id nu5si9066825pbc.268.2013.12.09.19.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 19:22:18 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 08:52:13 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id DA82C1258051
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:53:17 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA3M6HF37945560
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:52:06 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA3M8Li013567
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:52:09 +0530
Date: Tue, 10 Dec 2013 11:22:07 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 7/7] mm/migrate: remove result argument on page
 allocation function for migration
Message-ID: <52a688ea.c5d5440a.3a84.6e57SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-8-git-send-email-iamjoonsoo.kim@lge.com>
 <00000142d83adfc7-81b70cc9-c87b-4e7e-bd98-0a97ee21db31-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142d83adfc7-81b70cc9-c87b-4e7e-bd98-0a97ee21db31-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 04:40:06PM +0000, Christoph Lameter wrote:
>On Mon, 9 Dec 2013, Joonsoo Kim wrote:
>
>> First, we don't use error number in fail case. Call-path related to
>> new_page_node() is shown in the following.
>>
>> do_move_page_to_node_array() -> migrate_pages() -> unmap_and_move()
>> -> new_page_node()
>>
>> If unmap_and_move() failed, migrate_pages() also returns err, and then
>> do_move_page_to_node_array() skips to set page's status to user buffer.
>> So we don't need to set error number to each pages on failure case.
>
>I dont get this. new_page_node() sets the error condition in the
>page_to_node array before this patch. There is no post processing in
>do_move_page_to_node_array(). The function simply returns and relies on
>new_page_node() to have set the page status. do_move_pages() then returns
>the page status back to userspace. How does the change preserve these
>diagnostics?
>

Agreed.

>> Next, we don't need to set node id of the new page in unmap_and_move(),
>> since it cannot be different with pm->node. In new_page_node(), we always
>> try to allocate the page in exact node by referencing pm->node. So it is
>> sufficient to set node id of the new page in new_page_node(), instead of
>> unmap_and_move().
>
>Thats a good thought.

Agreed. 

>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
