Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id 9A8308198
	for <linux-mm@kvack.org>; Mon,  5 Jun 2000 07:30:47 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: [RFC] pre-cleaning 
Date: Sun, 4 Jun 2000 21:22:21 -0400
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060422052200.12375@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Was chating with Rik on #kernelnewbies and cameup with the following idea:

Assuming we have changes things to look a bit more like bsd and are scanning
the mm array looking for pages to free.  Once we have our quota of free pages
we save a pointer to the last scanned page (freed_to).  Then we continue
scanning for N entries writing out dirty pages (can we cluster these writes?)
we save a pointer to the last precleaned page in (cleaned_to) and record 
the number of precleaned pages in (pre_clean).  Next scan time the
idea is most of the precleaned pages will still be clean.  We check this 
by recording the number of pages we have to reclean in (re_clean).  We set
things up so N entires should free about the same number of pages as the last
called required us to free.  We can use the re_clean/pre_clean ratio to 
decide if we are doing any good, if not we reduce the number of pages we 
preclean...  If everything is ok a normal scan should compelete, having freed
enought pages, when freed_to = the old cleaned_to.  

Thoughts it might be better to create an array for a stucture with three 
counters in it

precleaned	- number of pages precleaned in this segement
recleaned	- number of pages relceaned (want this near zero)
cleaned		- number of pages we had to clean during freeing (not recleaned)

say i is the index in the mm array and j = i/2^k, 
where j indexes the above stucture 

we use the sum of [(freed_to/2^k)-x, (freed_to/2^k)-1] numbers to autotune 
the preclean logic

if recleaned*100 div precleaned > threshold1 then n =/ 2
else if cleaned*100 div precleaned > threshold2 then N =* 2

-- 

Ed Tomlinson (ontadata) <tomlins@cam.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
