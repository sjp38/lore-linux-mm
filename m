From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004080037.RAA32924@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Fri, 7 Apr 2000 17:37:30 -0700 (PDT)
In-Reply-To: <200004080011.RAA21305@google.engr.sgi.com> from "Kanoj Sarcar" at Apr 07, 2000 05:11:15 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > 
> > >Also, did you have a good reason to want to make lookup_swap_cache()
> > >invoke find_get_page(), and not find_lock_page()? I coded some of the 
> > 
> > Using find_lock_page and then unlocking the page is meaningless. If you
> > are going to unconditionally unlock the page then you shouldn't lock it in
> > first place.
> 
> I will have to think a little bit about why the code does what it does
> currently. I will let you know ...
>

Okay, I think I found at least one reason why the lockpage was being done
in lookup_swap_cache(). It was effectively to check the PageSwapCache bit,
since shrink_mmap:__delete_from_swap_cache could race with a 
lookup_swap_cache.

Yes, I did notice the recent shrink_mmap SMP race fixes that you posted,
now it _*might*_ be unneccesary to do a find_lock_page() in 
lookup_swap_cache() (just for this race). I will have to look at the 
latest prepatch to confirm that. In any case, there are still races with 
swapspace deletion and swapcache lookup, so unless you had a good reason 
to want to replace the find_lock_page with lookup_swap_cache, I would much 
rather see it the way it is currently ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
