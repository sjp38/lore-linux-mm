Received: from localhost (localhost.localdomain [127.0.0.1])
	by ucsns.ucs.co.za (Postfix) with ESMTP id 272BD2BEB5
	for <linux-mm@kvack.org>; Mon, 12 Jan 2004 14:07:42 +0200 (SAST)
Received: from ucsns.ucs.co.za ([127.0.0.1])
 by localhost (ucsns.ucs.co.za [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 16698-05 for <linux-mm@kvack.org>;
 Mon, 12 Jan 2004 14:07:33 +0200 (SAST)
Received: from ucspost.ucs.co.za (mailgw1.ucs.co.za [196.23.43.253])
	by ucsns.ucs.co.za (Postfix) with ESMTP id A95DA2BF33
	for <linux-mm@kvack.org>; Mon, 12 Jan 2004 13:35:03 +0200 (SAST)
Received: from jhb.ucs.co.za (jhb.ucs.co.za [172.31.1.3])
	by ucspost.ucs.co.za (Postfix) with ESMTP id 96FE2DAF57
	for <linux-mm@kvack.org>; Mon, 12 Jan 2004 13:35:03 +0200 (SAST)
Received: from bds.ucs.co.za (bds.ucs.co.za [172.31.1.36])
	by jhb.ucs.co.za (Postfix) with ESMTP id 19D40976E3
	for <linux-mm@kvack.org>; Mon, 12 Jan 2004 13:35:04 +0200 (SAST)
From: Berend De Schouwer <bds@jhb.ucs.co.za>
Subject: Memory usage doesn't add up
Date: Mon, 12 Jan 2004 13:35:02 +0200
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200401121335.03027.bds@jhb.ucs.co.za>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I have a machine that, after some uptime, constantly swaps.  It looks like an 
application eats too much memory, but running 'top' doesn't add up.  I'd like 
a crash course in ps and tops various memory columns.  Google for "linux 
memory usage" doesn't help :)

Err, first things first:

linux 2.4.20, RedHat 9 updates kernel.  512MB RAM.  600MB Swap.  Confirmed 
constant si/so with vmstat.  Runs Java (Sun) and postgresql.

As far as I know, memory-used-by-applications == 'Mem:used' + 'Swap:used' - 
buffers - cached, as reported by free and top:

So if I have:

# free
             total       used       free     shared    buffers     cached
Mem:        513832     504812       9020          0      30712     175616
-/+ buffers/cache:     298484     215348
Swap:       522104     106024     416080

I have 504812 + 106024 - 175616 - 30712 == 404508 kB used by applications.  I 
assume the numbers are kilobytes, and not pages.  However, on the -/+ line 
there is a buffers/cache of 298484 and 215348.


When I run 'top' (as in 'top b -n 1'), I see the following memory columns:
SIZE RSS SHARE %MEM.  I'll ignore '%MEM' for now.  If I add up all the numbers 
in SIZE, I get: SIZE=114996, RSS=165656, and SHARE=39884.  Nowhere close to 
404508, so this does not explain why the kernel swaps.


When I run 'ps aux' I get an additional column VSZ.  (vsize???).  If I add 
those numbers, I get VSZ=950444.  Much too large :(.  The biggest difference 
is Java, which has a VSZ of 577904, but a SIZE of 100M, RSS of 88M and SHARE 
of 3860.


If I use 'SIZE' (from top), and I subtract the buffers from the -/+ line, I 
get 136736, which is close to SIZE=114996 and RSS=165656.  I'm not expecting 
to get exact numbers because of copy-on-write, and a (small) time delay 
between typing free, top, and ps, but I'd like to get close.


So here are the questions:
 1. What is the difference between buffers and cache in the 'Mem:' line and
    the '+/- buffers/cache' line in the output of free.
 2. What is the difference between SIZE, RSS, SHARE, and VSZ?
 3. If the buffers are really 298484 instead of 30712, and the machine is
    swapping lots, isn't it better to shrink the buffers and cache, and
    get the app in RAM instead of swap?

-- 
Berend De Schouwer
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
