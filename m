Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B46328025D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 13:43:55 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 94so2612333uat.10
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 10:43:55 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id u81si2130679vkb.329.2018.01.05.10.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 10:43:54 -0800 (PST)
Date: Fri, 5 Jan 2018 12:41:22 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
In-Reply-To: <20180105180905.GR2801@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1801051237300.26065@nuc-kabylake>
References: <20180103082555.14592-1-mhocko@kernel.org> <20180103082555.14592-2-mhocko@kernel.org> <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com> <20180105091443.GJ2801@dhcp22.suse.cz> <ebef70ed-1eff-8406-f26b-3ed260c0db22@linux.vnet.ibm.com>
 <20180105093301.GK2801@dhcp22.suse.cz> <alpine.DEB.2.20.1801051113170.25466@nuc-kabylake> <20180105180905.GR2801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 5 Jan 2018, Michal Hocko wrote:

> I believe there should be some cap on the number of pages. We shouldn't
> keep it held for million of pages if all of them are moved to the same
> node. I would really like to postpone that to later unless it causes
> some noticeable regressions because this would complicate the code
> further and I am not sure this is all worth it.

Attached a patch to make the code more readable.

Also why are you migrating the pages on pagelist if a
add_page_for_migration() fails? One could simply update
the status in user space and continue.


Index: linux/mm/migrate.c
===================================================================
--- linux.orig/mm/migrate.c
+++ linux/mm/migrate.c
@@ -1584,16 +1584,20 @@ static int do_pages_move(struct mm_struc
 		if (!node_isset(node, task_nodes))
 			goto out_flush;

-		if (current_node == NUMA_NO_NODE) {
-			current_node = node;
-			start = i;
-		} else if (node != current_node) {
-			err = do_move_pages_to_node(mm, &pagelist, current_node);
-			if (err)
-				goto out;
-			err = store_status(status, start, current_node, i - start);
-			if (err)
-				goto out;
+		if (node != current_node) {
+
+			if (current_node != NUMA_NO_NODE) {
+
+				/* Move the pages to current_node */
+				err = do_move_pages_to_node(mm, &pagelist, current_node);
+				if (err)
+					goto out;
+
+				err = store_status(status, start, current_node, i - start);
+				if (err)
+					goto out;
+			}
+
 			start = i;
 			current_node = node;
 		}
@@ -1607,6 +1611,10 @@ static int do_pages_move(struct mm_struc
 		if (!err)
 			continue;

+		/*
+		 * Failure to isolate a page so flush the pages on
+		 * pagelist after storing status and continue.
+		 */
 		err = store_status(status, i, err, 1);
 		if (err)
 			goto out_flush;
@@ -1614,6 +1622,7 @@ static int do_pages_move(struct mm_struc
 		err = do_move_pages_to_node(mm, &pagelist, current_node);
 		if (err)
 			goto out;
+
 		if (i > start) {
 			err = store_status(status, start, current_node, i - start);
 			if (err)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
