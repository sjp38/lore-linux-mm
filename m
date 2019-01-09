Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94A178E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 03:27:44 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f69so4746543pff.5
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 00:27:44 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g8si1355593pli.50.2019.01.09.00.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 00:27:43 -0800 (PST)
Date: Wed, 9 Jan 2019 11:27:33 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] mm, compaction: round-robin the order while searching
 the free lists for a target
Message-ID: <20190109082733.GA5424@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net
Cc: linux-mm@kvack.org

Hello Mel Gorman,

The patch 1688e2896de4: "mm, compaction: round-robin the order while
searching the free lists for a target" from Jan 8, 2019, leads to the
following static checker warning:

	mm/compaction.c:1252 next_search_order()
	warn: impossible condition '(cc->search_order < 0) => (0-u16max < 0)'

mm/compaction.c
    1243 static int next_search_order(struct compact_control *cc, int order)
    1244 {
    1245 	order--;
    1246 	if (order < 0)
    1247 		order = cc->order - 1;
    1248 
    1249 	/* Search wrapped around? */
    1250 	if (order == cc->search_order) {
    1251 		cc->search_order--;
--> 1252 		if (cc->search_order < 0)
                            ^^^^^^^^^^^^^^^^^^^^
u16 can't be negative.

    1253 			cc->search_order = cc->order - 1;
    1254 		return -1;
    1255 	}
    1256 
    1257 	return order;
    1258 }

regards,
dan carpenter
