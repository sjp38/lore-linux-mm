From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912142351.PAA02412@google.engr.sgi.com>
Subject: Re: 2.3 Pagedir allocation/free and update races
Date: Tue, 14 Dec 1999 15:51:00 -0800 (PST)
In-Reply-To: <199912142308.PAA01037@pizda.ninka.net> from "David S. Miller" at Dec 14, 99 03:08:02 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: jakub@redhat.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
>    From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
>    Date: Tue, 14 Dec 1999 15:00:19 -0800 (PST)
> 
>    Yes, I am sorry for the misleading logic in my note. Per-cpu caches are 
>    safe (I wonder why it was taken out for i386). For architectures that 
>    have to do set_pgdir() though, the pgdir update code might be racy, 
>    unless the arch code has locks to protect the page directory scanning.
> 
>    Btw, Linus indicated to me he ran into problems with the patch, and 
>    will be pulling it out in the next pre-release. I will take a closer look 
>    at the code.
> 
> Just handle the set_pgdir() stuff like this:
> 
>         pgcache_update_flag = 0;
> 	smp_call_func(ALL_CPUS, update_pgcaches_and_wait_on_flag);
> 	update_local_pgcache();
> 	pgcache_update_flag = 1;
> 	for_each_task(tsk)
> 		update_pgdir(tsk);

As I mentioned, there are possibly multiple ways in which this can
be fixed. Note that mmlists are not needed solely for set_pgdir().

David, unless I am mistaken (which is happening fairly frequently),
in your solution, set_pgdir() is going to miss a page directory that
a parent has allocated for a child, but the child is not yet on the 
tasklist. Yes, the arch code can keep a list of all allocated page
directories ... I am just trying to come up with a solution that
will work for most architectures, where the common case is that
the pgdir cache does not have a lock because it is percpu.

Kanoj

> 
> That should give the correct synchronization with zero cost
> for the fast normal paths which can rely solely on the cpu
> localness of the data structure.
> 
> Later,
> David S. Miller
> davem@redhat.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
