Date: Fri, 22 Sep 2000 14:16:54 +0200 (CEST)
From: Martin Diehl <mdiehlcs@compuserve.de>
Subject: Re: [patch *] VM deadlock fix
In-Reply-To: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10009221159321.8135-100000@notebook.diehl.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Sep 2000, Rik van Riel wrote:

> I've found and fixed the deadlocks in the new VM. They turned out 
> to be single-cpu only bugs, which explains why they didn't crash my
> SMP tesnt box ;)

Hi,

tried
> http://www.surriel.com/patches/2.4.0-t9p2-vmpatch
applied to 2.4.0-t9p4 on UP box booted with mem=8M.

The deadlock behaviour appears to be somehow different compared
to vanilla 2.4.0-t9p4 - however, for me it makes things even worse:

I booted into singleuser and used

dd if=/dev/urandom of=/dev/null count=1 bs=x

to trigger the issue by increasing bs-values. As soon as bs is big
enough to force swapping (about 3M in my case) the box "deadlocks".
What has become worse is, that SysRq+e (or k) doesn't help anymore
with this patch applied. So I had to SysRq+b and ended fscking (but
no fs-corruption). Without the patch this was not a problem.

Some more points I've notized:

* apparently, the deadlock happens when the box begins to swap. I never
  found any used swapspace with the new VM from 2.4.0-t9p*. If memory
  requests force the use of swapspace, the machine deadlocks.

* when, after deadlocking, I pressed SysRq+t several times I found
  - either dd or kswapd being current task in vanilla 2.4.0-t9p4
  - neither dd nor kswapd ever being current with this patch

* as an printk() in the main loop shows, kreclaimd *never* awoke

* My impression was similar to what somebody has already reported:
  seems something related to refill_inactive_scan() is recursing to
  infinity when the "deadlock" happens.

* the behaviour of kswapd without this last patch differs significantly
  before and after the first deadlock happens (and released by SysRq+e):
  only *after* pressing SysRq+e (or k) kswapd awoke once per second
  on the idle box. This is strange since it should sleep with timeout=HZ
  in its main loop.

Especially the last point suggests to me there might be a problem at
initialization. I'm not sure, whether everything called from kswapd
is properly initialized at the time when the kswapd-thread is created.
To check this, I've tentatively added an additional
interruptible_sleep_on_timeout() before kswapd's main loop to delay it
until initialization has finished. Probably it would be more "Right" to
move the sleep from the end of the main loop to its beginning - however,
I just tried a quick hack and did not check if the *_shortage() stuff is
ready to be called at init time.

The additional sleep before kswapd enters its main loop was a major
improvement for me:

* my dd-tests did not deadlock anymore - even with bs=100M and mem=8M

* swap space was really used now.

* i was able to advance beyond singleuser with 2.4.0-t9p* and mem=8M
  for the very first time (always deadlocked in the init-scripts)

* i was even able to make bzImage - but it dumped core after about 15 Min
  for unknown reason (probably out of memory) but without any deadlock.
  Box was at av. load 3 and 15M swap used at this time.

* I found kreclaimd *was* awoken several times.

* however, kswapd still not awaking every second after fresh boot. Now
  it begins to awake as soon as real swapping starts.

So, my conclusion is the "deadlock" issue might be mainly an
initialization problem. Probably some more special handling is needed
at swapon later. Currently my guess is there is a initialization problem
when kswapd starts and some kind of blocking when refill_inactive_scan()
is called before swapon.

Comments?
Will do some more tests (including your latest patch).

Regards
Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
