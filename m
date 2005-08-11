Received: from ccs-mail.lanl.gov (ccs-mail.lanl.gov [128.165.4.126])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with ESMTP id j7BM8JIt006128
	for <linux-mm@kvack.org>; Thu, 11 Aug 2005 16:08:20 -0600
Subject: Re: [PATCH/RFT 5/5] CLOCK-Pro page replacement
From: Song Jiang <sjiang@lanl.gov>
In-Reply-To: <20050810200944.197606000@jumble.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
	 <20050810200944.197606000@jumble.boston.redhat.com>
Content-Type: text/plain
Message-Id: <1123798095.4692.66.camel@moon.c3.lanl.gov>
Mime-Version: 1.0
Date: Thu, 11 Aug 2005 16:08:15 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

My current test focuses on the looping case, where I repeatedly 
scan a file whose size is larger than the memory size but less 
than two times of memory sizes. My initial results are as follows:


My machine has 2GB memory.
The size of the file to be scanned is 2.5GB.
I looped for 4 time. The times and associated disk bandwidths
for each loop are below:

loop 0 time = 34.229424s bandwith = 76.58MB
loop 1 time = 37.574041s bandwith = 69.76MB
loop 2 time = 38.181791s bandwith = 68.65MB
loop 3 time = 38.141794s bandwith = 68.72MB

This shows that the current patches cannot do a 
better job than the original kernel, which notoriously
underperforms for the case -- no matter how many times
the file is accessed, no hits at all. Meanwhile, Clock-Pro
is supposed to do a better job, because part of the
file can be protected in the active list and get a decent 
number of hits.

Here is from /proc/meminfo:

Active:          11356 kB
Inactive:      1994400 kB

So no file pages are promoted into the active list, just
as in the original kernel.

Here is from /proc/refaults:     

    Refault distance          Hits
         0 -     32768           192
    32768 -     65536           269
    65536 -     98304           447
    98304 -    131072           603
   131072 -    163840          1087
   163840 -    196608           909
   196608 -    229376           558
   229376 -    262144           404
   262144 -    294912           287
   294912 -    327680           191
   327680 -    360448            79
   360448 -    393216            68
   393216 -    425984            41
   425984 -    458752            45
   458752 -    491520            31
New/Beyond    491520          2443

In the statistic, we do see many hits at the distance of around 
150,000 pages. If we consider the inactive list size (1.9GB), 
this position corresponds to the file size. However, if everything
happens as expected, all the hits should happen at the
distance. Unfortunately, there are also many hits listed as
New/Beyond. Because "Beyond"s should not be there, are they all
"New"s? Futhermore, I didn't see where the refault_histogram 
statistics get reset, though they almost stop increasing after
the first run. Can you show me that? 


   Song Jiang
   at LANL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
