Date: Fri, 22 Sep 2000 06:08:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive
 workload
In-Reply-To: <Pine.LNX.4.21.0009221046300.12532-100000@debella.aszi.sztaki.hu>
Message-ID: <Pine.LNX.4.21.0009220603370.27435-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Molnar Ingo <mingo@debella.ikk.sztaki.hu>
Cc: "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2000, Molnar Ingo wrote:

> i'm still getting VM related lockups during heavy write load, in
> test9-pre5 + your 2.4.0-t9p2-vmpatch (which i understand as being your
> last VM related fix-patch, correct?). Here is a histogram of such a
> lockup:

> this lockup happens both during vanilla test9-pre5 and with
> 2.4.0-t9p2-vmpatch. Your patch makes the lockup happen a bit
> later than previous, but it still happens. During the lockup all
> dirty buffers are written out to disk until it reaches such a
> state:

It seems that conference life has taken its toll,
I seem to have reversed the logic in the test if
we can reschedule in refill_inactive()   ;(

On mm/vmscan.c, please remove the `!' in the
following fragment of code:

 894          if (current->need_resched && !(gfp_mask & __GFP_IO)) {
 895                  __set_current_state(TASK_RUNNING);
 896                  schedule();
 897          }

The idea was to not allow processes which have IO locks
to schedule away, but as you can see, the check is 
reversed ...

With the above fix, can you still lock it up?
And if you can, does it lock up in the same way or in
a new and exciting way? ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
