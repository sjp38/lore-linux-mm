Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l3NNWhjw002599
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:46 -0700
Received: from smtp.corp.google.com (spacemonkey2.corp.google.com [192.168.120.114])
	by zps37.corp.google.com with ESMTP id l3NNW1ve025044
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:04 -0700
Received: from [10.253.168.165] (m682a36d0.tmodns.net [208.54.42.104])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id l3NNVxAx032576
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:32:00 -0700
Message-ID: <462D41EE.5020604@google.com>
Date: Mon, 23 Apr 2007 16:31:58 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 4/7] cpuset write vmscan
References: <462D3F4C.2040007@google.com>
In-Reply-To: <462D3F4C.2040007@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Direct reclaim: cpuset aware writeout

During direct reclaim we traverse down a zonelist and are carefully
checking each zone if its a member of the active cpuset. But then we call
pdflush without enforcing the same restrictions. In a larger system this
may have the effect of a massive amount of pages being dirtied and then
either

A. No writeout occurs because global dirty limits have not been reached

or

B. Writeout starts randomly for some dirty inode in the system. Pdflush
   may just write out data for nodes in another cpuset and miss doing
   proper dirty handling for the current cpuset.

In both cases dirty pages in the zones of interest may not be affected
and writeout may not occur as necessary.

Fix that by restricting pdflush to the active cpuset. Writeout will occur
from direct reclaim the same way as without a cpuset.

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 3/mm/vmscan.c
4/mm/vmscan.c
--- 3/mm/vmscan.c	2007-04-23 14:37:28.000000000 -0700
+++ 4/mm/vmscan.c	2007-04-23 14:37:32.000000000 -0700
@@ -1174,7 +1174,8 @@ unsigned long try_to_free_pages(struct z
 		 */
 		if (total_scanned > sc.swap_cluster_max +
 					sc.swap_cluster_max / 2) {
-			wakeup_pdflush(laptop_mode ? 0 : total_scanned, NULL);
+			wakeup_pdflush(laptop_mode ? 0 : total_scanned,
+				&cpuset_current_mems_allowed);
 			sc.may_writepage = 1;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
