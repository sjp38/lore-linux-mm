Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA15214
	for <linux-mm@kvack.org>; Thu, 12 Nov 1998 18:20:04 -0500
Subject: Re: unexpected paging during large file reads in 2.1.127
References: <Pine.LNX.3.96.981112143712.20473B-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 13 Nov 1998 00:18:44 +0100
In-Reply-To: Rik van Riel's message of "Thu, 12 Nov 1998 14:39:53 +0100 (CET)"
Message-ID: <87k910biuj.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, benchmarking done (never faster :))

Methodology: compile kernel, reboot, fire up X, XEmacs, Netscape, few
xterms to (almost) fill memory, copy 1.5GB of files to /dev/null.

I have 64MB of memory, and interesting thing, in both cases I tried,
system decided to swap out cca 16MB, which is fine. Without patching,
kernel would start thrashing very early, during file copy, which
considerably slows down whole operation (and make machine painfully
sloooow).


*** Case 1)

shrink_mmap():
        count_max = (limit<<4) >> (priority>>1);
        count_min = (limit<<4) >> (priority);

Result after copying is finished:
    3 root       7   7     0    0     0 SWN     0  0.0  0.0   0:13 kswapd
                                                              ^^^^


*** Case 2)

shrink_one_page():
        age_page(page);
        age_page(page);
        age_page(page);

Result after copying is finished:
    3 root       7   7     0    0     0 SWN     0  0.0  0.0   0:07 kswapd
                                                              ^^^^


Tested on pre-2.1.128-1.

Q.E.D. :)
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		    Bus error (Passengers dumped)
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
