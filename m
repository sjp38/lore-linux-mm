Date: Thu, 4 May 2000 19:59:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005041234490.23740-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0005041952280.3416-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Rik van Riel wrote:

>On Thu, 4 May 2000, Andrea Arcangeli wrote:
>
>> --- 2.2.15/mm/filemap.c	Thu May  4 13:00:40 2000
       ^^^^^^
>> +++ /tmp/filemap.c	Thu May  4 17:11:18 2000
>> @@ -68,7 +68,7 @@
>>  
>>  	p = &inode->i_pages;
>>  	while ((page = *p) != NULL) {
>> -		if (PageLocked(page)) {
>> +		if (PageLocked(page) || atomic_read(&page->count) > 1) {
>>  			p = &page->next;
>>  			continue;
>>  		}
		XXXXXXXXXXXXXXXX
>
>Fun, fun, fun ...
>
>So the other CPU takes a lock on the page while we're testing
>for the page->count and increments the pagecount after the lock,
>while we try to do something (call __free_page(page)?) with the
>page ...

You're obviously wrong:

1) the other cpu on 2.2.15 were spinning on the big kernel lock
   and had no way to try to lock down the page we're processing.
2) if what you described above would be true, then virgin 2.2.15 and
   all the 2.2.x official/unofficial kernels out there would
   have a major SMP race anyway (not thanks to my above fix) because it
   would mean that in point XXXXXXXXXXXXXXXXX the page could become locked
   from under us.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
