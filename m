Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72B366B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:35:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r6so7137765itr.1
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:35:19 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g19si3412562iob.125.2017.11.30.11.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 11:35:18 -0800 (PST)
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
 <425a8947-d32a-d6bb-3a0a-2e30275c64c9@oracle.com>
 <20171130075742.3exagxg6y4j427ut@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e23f971e-cd62-afea-6567-0873a3e48db7@oracle.com>
Date: Thu, 30 Nov 2017 11:35:11 -0800
MIME-Version: 1.0
In-Reply-To: <20171130075742.3exagxg6y4j427ut@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On 11/29/2017 11:57 PM, Michal Hocko wrote:
> On Wed 29-11-17 11:52:53, Mike Kravetz wrote:
>> On 11/29/2017 01:22 AM, Michal Hocko wrote:
>>> What about this on top. I haven't tested this yet though.
>>
>> Yes, this would work.
>>
>> However, I think a simple modification to your previous free_huge_page
>> changes would make this unnecessary.  I was confused in your previous
>> patch because you decremented the per-node surplus page count, but not
>> the global count.  I think it would have been correct (and made this
>> patch unnecessary) if you decremented the global counter there as well.
> 
> We cannot really increment the global counter because the over number of
> surplus pages during migration doesn't increase.

I was not suggesting we increment the global surplus count.  Rather,
your previous patch should have decremented the global surplus count in
free_huge_page.  Something like:

@@ -1283,7 +1283,13 @@ void free_huge_page(struct page *page)
 	if (restore_reserve)
 		h->resv_huge_pages++;
 
-	if (h->surplus_huge_pages_node[nid]) {
+	if (PageHugeTemporary(page)) {
+		list_del(&page->lru);
+		ClearPageHugeTemporary(page);
+		update_and_free_page(h, page);
+		if (h->surplus_huge_pages_node[nid])
+			h->surplus_huge_pages--;
+			h->surplus_huge_pages_node[nid]--;
+		}
+	} else if (h->surplus_huge_pages_node[nid]) {
 		/* remove the page from active list */
 		list_del(&page->lru);
 		update_and_free_page(h, page);

When we allocate one of these 'PageHugeTemporary' pages, we only increment
the global and node specific nr_huge_pages counters.  To me, this makes all
the huge page counters be the same as if there were simply one additional
pre-allocated huge page.  This 'extra' (PageHugeTemporary) page will go
away when free_huge_page is called.  So, my thought is that it is not
necessary to transfer per-node counts from the original to target node.
Of course, I may be missing something.

When thinking about transfering per-node counts as is done in your latest
patch, I took another look at all the per-node counts.  This may show my
ignorance of huge page migration, but do we need to handle the case where
the page being migrated is 'free'?  Is that possible?  If so, there will
be a count for free_huge_pages_node and the page will be on the per node
hugepage_freelists that must be handled

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
