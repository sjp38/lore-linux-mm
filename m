Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.codito.com (Postfix) with ESMTP id 35E1E3EC65
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 19:29:44 +0530 (IST)
Received: from mail.codito.com ([127.0.0.1])
	by localhost (vera.celunite.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ywxO04nD+Cat for <linux-mm@kvack.org>;
	Thu, 28 Sep 2006 19:29:44 +0530 (IST)
Received: from [192.168.100.251] (unknown [220.225.33.101])
	by mail.codito.com (Postfix) with ESMTP id 039323EC62
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 19:29:44 +0530 (IST)
Message-ID: <451BD632.7050300@celunite.com>
Date: Thu, 28 Sep 2006 19:33:30 +0530
From: Ashwin Chaugule <ashwin.chaugule@celunite.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/2] Swap token re-tuned
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
 Here's a brief up on the next two mails.

PATCH 1:

In the current implementation of swap token tuning, grab swap token is 
made from :
1) after page_cache_read (filemap.c) and
2) after the readahead logic in do_swap_page (memory.c)

IMO, the contention for the swap token should happen _before_ the 
aforementioned calls, because in the event of low system memory, calls 
to freeup space will be made later from page_cache_read and 
read_swap_cache_async , so we want to avoid "false LRU" pages by 
grabbing the token before the VM starts searching for replacement 
candidates.

PATCH 2:

Instead of using TIMEOUT as a parameter to transfer the token, I think a 
better solution is to hand it over to a process that proves its eligibilty.

What my scheme does, is to find out how frequently a process is calling 
these functions. The processes that call these more frequently get a 
higher priority.
The idea is to guarantee that a high priority process gets the token. 
The priority of a process is determined by the number of consecutive 
calls to swap-in and no-page. I mean "consecutive" not from the 
scheduler point of view, but from the process point of view. In other 
words, if the task called these functions every time it was scheduled, 
it means it is not getting any further with its execution.

This way, its a matter of simple comparison of task priorities, to 
decide whether to transfer the token or not.

I did some testing with the two patches combined and the results are as 
follows:

Current Upstream implementation:
===============================

root@ashbert:~/crap# time ./qsbench -n 9000000 -p 3 -s 1420300
seed = 1420300
seed = 1420300
seed = 1420300

real    3m40.124s
user    0m12.060s
sys     0m0.940s


-------------reboot-----------------

With my implementation :
========================

root@ashbert:~/crap# time ./qsbench -n 9000000 -p 3 -s 1420300
seed = 1420300
seed = 1420300
seed = 1420300

real    2m58.708s
user    0m11.880s
sys     0m1.070s



My test machine:

1.69Ghz CPU
64M RAM
7200rpm hdd
2MB L2 cache
vanilla kernel 2.6.18
Ubuntu dapper with gnome.


Any comments, suggestions, ideas ?

Cheers,
Ashwin




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
