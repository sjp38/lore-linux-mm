Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9OCtjSI013456
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Oct 2008 21:55:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 841692AC026
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:55:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B6E012C047
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:55:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 393C81DB8037
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:55:45 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E72FD1DB803E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 21:55:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
In-Reply-To: <87zlkuj10z.fsf@saeurebad.de>
References: <878wsigp2e.fsf_-_@saeurebad.de> <87zlkuj10z.fsf@saeurebad.de>
Message-Id: <20081024213527.492B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Oct 2008 21:55:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> mmotm:
>     normal  user: 1.775000s [0.053307] system: 9.620000s [0.135339] total: 98.875000s [0.613956]
>    madvise  user: 2.552500s [0.041307] system: 9.442500s [0.075980] total: 73.937500s [0.734170]
> mmotm+patch:
>     normal  user: 1.850000s [0.013540] system: 9.760000s [0.047081] total: 99.250000s [0.569386]
>    madvise  user: 2.547500s [0.014930] system: 8.865000s [0.055000] total: 71.897500s [0.144763]
> 
> Well, time-wise not sooo much of an improvement.  But given the
> massively decreased LRU-rotation [ http://hannes.saeurebad.de/madvseq/ ]

My first impression, this result mean the patch is not so useful.
But anyway, I mesured it again because I think Nick's opinion is very
reasonable and I don't know your mesurement condition so detail.



> I'm still looking forward to Kosaki-san's throughput measurements :)

I'm sorry for late responce.
but I'd like to you know this mesurement need spent long time in my time.


1. copybench (http://code.google.com/p/copybench/)

   my machine mem:   8GB
   target file size: 10GB (filesize > system mem)


                         mmotm-1022  + the patch
   ==============================================================
   rw_cp                 6:32        6:34
   rw_fadv_cp            6:34        6:35
   mm_sync_cp            6:15        6:16
   mm_sync_madv_cp       6:19        6:14
   mw_cp                 6:11        6:12
   mw_madv_cp            6:13        6:12


MADV_SEQUENTIAL decrease performance a bit on mmotm.
but the patch fix it.



2. MADV_SEQUENTIAL vs dbench

                         mmotm1022   + the patch
   ==============================================================
   mm_sync_madv_cp       6:29        6:19           (min:sec)
   dbench throughput     11.633      14.4045        (MB/s)
   dbench latency        65628       18565          (ms)


mmotm's copy decrease performance largely. but the patch decrease it a bit. 
dbench throuput improve about 25%, latency improve about 3.5 times.


So, I think the patch better than v1 and we should appreciate for Nick's
good suggestion.

Hanns, Actually I recomend to spent a bit more time for proper benchmark design and settings.


	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
