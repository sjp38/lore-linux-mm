Received: from ucla.edu (ts13-80.dialup.bol.ucla.edu [164.67.23.89])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id NAA10878
	for <linux-mm@kvack.org>; Mon, 17 Sep 2001 13:04:23 -0700 (PDT)
Message-ID: <3BA65763.8090900@ucla.edu>
Date: Mon, 17 Sep 2001 13:04:51 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: try_to_swap_out: to aggressive in dropping pte's?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
	I was wondering if anybody could explain why we try to drop the pte on a 
page if it is not pte_young, even if it has a high age and has the 
referenced bit set?

	Also, does anybody have any thoughts on how to decouple scanning the page 
tables for hardward referenced bits, and doing swap-out?  On one of my 
128mb boxes, linus's changes to only run swap_out when there is memory 
pressure make things MUCH more interactive and decreased unnecessary 
swapping.  However, this means that the page tables are not scanned, 
which is not good...

	On a related note, in 2.4.10-pre10, Linus makes pages get deactivated in 
try_to_swap_out if !PageReferenced(page), thus making page->age almost 
irrelevant.  I would like to make a quick hack hybrid approach that 
keeps lots of the 2.4.10-pre10 vm changes still uses age information on 
the active list.  This probably isn't adequate, but how about:

1. change "if (ptep_test_and_clear_young(page_table))" to
"if (ptep_test_and_clear_young(page_table) ||
	PageTestandClearReference(page))"

2. revert Linus's change in pre10 to deactivate pages if age==0 instead 
of if !PageReference.

thanks for any suggestions,
-BenRI
-- 
"I will begin again" - U2, 'New Year's Day'
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
