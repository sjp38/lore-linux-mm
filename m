Date: Tue, 2 May 2000 03:51:59 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <200005020113.SAA31341@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005020338110.1919-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@nl.linux.org, roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Actually I think you missed the pgdat_list is a queue and it's not null
terminated. I fixed this in my classzone patch of last week in this chunk:

@@ -507,9 +529,8 @@
 	unsigned long i, j;
 	unsigned long map_size;
 	unsigned long totalpages, offset, realtotalpages;
-	unsigned int cumulative = 0;
 
-	pgdat->node_next = pgdat_list;
+	pgdat->node_next = NULL;

however that's not enough without the thing I'm doing in the
kswapd_can_sleep() again in the classzone patch.

Note that my latest classzone patch had a few minor bugs.

Last days and today I worked on getting mapped pages out of the lru and
splitting the lru in two pieces since swap cache is less priority and it
have to be shrink first. Doing that things is giving smooth swap
behaviour. I'm incremental with the classzone patch.

My current tree works rock solid but I forgot a little design detail ;).
If a mapped page have anonymous buffers on it it have to _stay_ on the lru
otherwise the bh headers will become unfreeable and so I can basically
leak memory. Once this little bit will be fixed (and it's not a trivial
bit if you think at it) I'll post the patch where the above and other
things are fixed.

It should be fully orthogonal (at least conceptually) with your anon.c
stuff since all new code lives in the lru_cache domain.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
