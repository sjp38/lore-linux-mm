Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 190326B02FF
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 22:52:36 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id x129so2433649qkb.17
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 19:52:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z124si1998964qkd.293.2018.01.04.19.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 19:52:35 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w053nTgr159138
	for <linux-mm@kvack.org>; Thu, 4 Jan 2018 22:52:34 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2f9wf9r0ak-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Jan 2018 22:52:34 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 5 Jan 2018 03:52:32 -0000
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 5 Jan 2018 09:22:22 +0530
MIME-Version: 1.0
In-Reply-To: <20180103082555.14592-2-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/03/2018 01:55 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_pages_move is supposed to move user defined memory (an array of
> addresses) to the user defined numa nodes (an array of nodes one for
> each address). The user provided status array then contains resulting
> numa node for each address or an error. The semantic of this function is
> little bit confusing because only some errors are reported back. Notably
> migrate_pages error is only reported via the return value. This patch
> doesn't try to address these semantic nuances but rather change the
> underlying implementation.
> 
> Currently we are processing user input (which can be really large)
> in batches which are stored to a temporarily allocated page. Each
> address is resolved to its struct page and stored to page_to_node
> structure along with the requested target numa node. The array of these
> structures is then conveyed down the page migration path via private
> argument. new_page_node then finds the corresponding structure and
> allocates the proper target page.
> 
> What is the problem with the current implementation and why to change
> it? Apart from being quite ugly it also doesn't cope with unexpected
> pages showing up on the migration list inside migrate_pages path.
> That doesn't happen currently but the follow up patch would like to
> make the thp migration code more clear and that would need to split a
> THP into the list for some cases.
> 
> How does the new implementation work? Well, instead of batching into a
> fixed size array we simply batch all pages that should be migrated to
> the same node and isolate all of them into a linked list which doesn't
> require any additional storage. This should work reasonably well because
> page migration usually migrates larger ranges of memory to a specific
> node. So the common case should work equally well as the current
> implementation. Even if somebody constructs an input where the target
> numa nodes would be interleaved we shouldn't see a large performance
> impact because page migration alone doesn't really benefit from
> batching. mmap_sem batching for the lookup is quite questionable and
> isolate_lru_page which would benefit from batching is not using it even
> in the current implementation.

Hi Michal,

After slightly modifying your test case (like fixing the page size for
powerpc and just doing simple migration from node 0 to 8 instead of the
interleaving), I tried to measure the migration speed with and without
the patches on mainline. Its interesting....

					10000 pages | 100000 pages
					--------------------------
Mainline				165 ms		1674 ms
Mainline + first patch (move_pages)	191 ms		1952 ms
Mainline + all three patches		146 ms		1469 ms

Though overall it gives performance improvement, some how it slows
down migration after the first patch. Will look into this further.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
