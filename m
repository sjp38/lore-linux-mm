Received: from localhost (localhost [127.0.0.1])
	by mail2.syneticon.net (Postfix) with ESMTP id A58894FE20
	for <linux-mm@kvack.org>; Fri,  9 Feb 2007 18:08:34 +0100 (CET)
Received: from mail2.syneticon.net ([127.0.0.1])
 by localhost (linux [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 18533-13 for <linux-mm@kvack.org>; Fri,  9 Feb 2007 18:08:20 +0100 (CET)
Received: from postfix1.syneticon.net (postfix1.syneticon.net [192.168.112.6])
	by mail2.syneticon.net (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  9 Feb 2007 18:08:19 +0100 (CET)
Received: from localhost (filter1.syneticon.net [192.168.113.3])
	by postfix1.syneticon.net (Postfix) with ESMTP id 2920D95EF
	for <linux-mm@kvack.org>; Fri,  9 Feb 2007 18:08:21 +0100 (CET)
Received: from postfix1.syneticon.net ([192.168.113.4])
	by localhost (192.168.113.3 [192.168.113.3]) (amavisd-new, port 10025)
	with ESMTP id iTLvjevCJE3G for <linux-mm@kvack.org>;
	Fri,  9 Feb 2007 18:08:14 +0100 (CET)
Received: from [84.44.195.93] (xdsl-84-44-195-93.netcologne.de [84.44.195.93])
	by postfix1.syneticon.net (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  9 Feb 2007 18:08:14 +0100 (CET)
Message-ID: <45CCAA7B.5070805@wpkg.org>
Date: Fri, 09 Feb 2007 18:08:11 +0100
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
Subject: does SCSI eat my PC's memory?
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does SCSI eat my PC's memory? Probably not, but I can't find an 
explanation of what uses so much RAM when I use SCSI disks.

A little background first.

Overall, the system has 1 GB memory. When it boots and everything has
started, about 60 MB of memory is used (excluding buffers).

One partition is on a iscsi target (I access it using open-iscsi):

/dev/sda              570G  402G  139G  75% /mnt/iscsi_backup

It contains lots of data, many files, hardlinked multiple times
(in total, almost 100 000 000 files).


When I run "find /mnt/iscsi_backup" for some time, and run
"free" to see memory usage, I can see almost 500 MB is used (excluding
buffers/cache):

# free
               total       used       free     shared    buffers     cached
Mem:       1048576    1029360      19216          0     530972      17628
-/+ buffers/cache:     480760     567816
Swap:      1048568         68    1048500


Also, stopping all deamons and dropping cache doesn't help (sum of the
memory used by all processes, displayed by "ps", is about 60 MB):

# echo 1 > /proc/sys/vm/drop_caches
# free
               total       used       free     shared    buffers     cached
Mem:       1048576     453932     594644          0        352       6408
-/+ buffers/cache:     447172     601404
Swap:      1048568         68    1048500


A single "umount" command releases almost 400 MB of memory:

# umount /mnt/iscsi_backup/
# free
               total       used       free     shared    buffers     cached
Mem:       1048576      64188     984388          0        232       6528
-/+ buffers/cache:      57428     991148
Swap:      1048568         64    1048504



What used almost 400 MB? SCSI buffers?

I noticed that when I add RAM to the system, more "unexplained" RAM will 
be used.
When I remove some RAM, "unexplained" RAM usage will drop - as a rule of 
thumb, I observed that about 50% of RAM is used by something I can't 
identify.


-- 
Tomasz Chmielewski
http://wpkg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
