Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA21437
	for <Linux-MM@kvack.org>; Fri, 23 Apr 1999 11:52:00 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199904231548.IAA40539@google.engr.sgi.com>
Subject: Re: RFC: patch for suspected shm swap problem
Date: Fri, 23 Apr 1999 08:48:37 -0700 (PDT)
In-Reply-To: <14112.29896.111556.997365@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Apr 23, 99 02:25:28 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: torvalds@transmeta.com, number6@the-village.bc.nu, Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Thu, 22 Apr 1999 09:03:14 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > I suspect the problem is that shm_swap bumps up swap_id to more
> > than max_shmid under some circumstances, leading the next call
> > to shm_swap to trip. Note that valid values of max_shmid are 0 ..
> > SHMMNI - 1, but shm_swap can leave swap_id set to SHMMNI.
> 
> > MMU code maintainers, could you please review the patch and let 
> > me know whether it is good 
> 
> Agreed: the patch looks correct.
> 
> In particular, with the patch in place we are still protected against
> having max_shmid shrink between calls to shm_swap(): the worst that can
> happen is that we find an unused shm_seg which will get caught by the
> IPC_UNUSED test near the top of shm_swap.  Only if the shm table is
> full, and so the swap_id overflow forces the next shm_segs[swap_id] to
> point to an entry not preinitialised to IPC_UNUSED or IPC_NOID, will
> there be a danger, and the patch makes sure that we never overstep that
> bound.  (This probably explains why we haven't seen the problem before:
> were you allocating the maximum number of shm segments during the stress
> test?)

Yes ... my benchmark is so resource hungry that I had to end up also
bumping _SHM_ID_BITS to increase the number of shm segs, but that's
irrelevant.

Thanks.

Kanoj

> 
> --Stephen
> 
> ----------------------------------------------------------------
> From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
> Sender: owner-linux-kernel@vger.rutgers.edu
> To: Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
> Subject: RFC: patch for suspected shm swap problem
> Date: 	Thu, 22 Apr 1999 09:03:14 -0700 (PDT)
> 
> Hi,
>  
> While running some heavy stress on shm code, I took a panic in
> shm_swap coming out of do_try_to_free_pages in the context of
> non-kswapd processes. From the register display, I suspect the
> problem to be fixed by this patch:
>  
> --- /usr/tmp/p_rdiff_a000PE/shm.c       Tue Apr 20 16:07:02 1999
> +++ kern/ipc/shm.c	Tue Apr 20 16:05:54 1999
> @@ -716,10 +716,10 @@
>                 next_id:
>                 swap_idx = 0;
>                 if (++swap_id > max_shmid) {
> +                       swap_id = 0;
>                         if (loop)
>                                 goto failed;
>                         loop = 1;
> -                       swap_id = 0;
>                 }
>                 goto check_id;
>         }
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
> in the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
