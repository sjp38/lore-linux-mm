Date: Tue, 14 Dec 1999 15:08:02 -0800
Message-Id: <199912142308.PAA01037@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199912142300.PAA05447@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: 2.3 Pagedir allocation/free and update races
References: <199912142300.PAA05447@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: jakub@redhat.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Yes, I am sorry for the misleading logic in my note. Per-cpu caches are 
   safe (I wonder why it was taken out for i386). For architectures that 
   have to do set_pgdir() though, the pgdir update code might be racy, 
   unless the arch code has locks to protect the page directory scanning.

   Btw, Linus indicated to me he ran into problems with the patch, and 
   will be pulling it out in the next pre-release. I will take a closer look 
   at the code.

Just handle the set_pgdir() stuff like this:

        pgcache_update_flag = 0;
	smp_call_func(ALL_CPUS, update_pgcaches_and_wait_on_flag);
	update_local_pgcache();
	pgcache_update_flag = 1;
	for_each_task(tsk)
		update_pgdir(tsk);

That should give the correct synchronization with zero cost
for the fast normal paths which can rely solely on the cpu
localness of the data structure.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
