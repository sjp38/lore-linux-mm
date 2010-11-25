Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 584726B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 20:10:54 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAP1Amr7006710
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Nov 2010 10:10:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D7D345DE56
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:10:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E29E845DE4D
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:10:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CBD51DB803C
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:10:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DD221DB8037
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:10:46 +0900 (JST)
Date: Thu, 25 Nov 2010 10:04:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-Id: <20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks.

On Wed, 24 Nov 2010 15:17:38 +0300
Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
> > What kinds of error ? Do you have swap ? What is the kerenel version ?
> 
> Kernel is 2.6.31-5 from SLES-SP1 (my build, but without extra patches).
> I have 2 Gb swap and just 40 Mb used. Machine has 3 Gb RAM and no load
> (neither mem or CPU).
> 
Hmm, maybe I should see 2.6.32.

> Error is "-bash: echo: write error: Device or resource busy", when I
> write to memory.limit_in_bytes.
> 
Ok.

> > It's designed to allow "shrink at once" but that means release memory
> > and do forced-writeback. To release memory, it may have to write back
> > to swap. If tasks in "A" and "B" are too busy and tocuhes tons of memory
> > while shrinking, it may fail.
> 
> Well, in test I have a process which uses 30M of memory and in loop
> dirties all pages (just single byte) then sleeps 5 seconds before next
> iteration.
> 
> > It may be a regression. Kernel version is important.
> >
> > Could you show memory.stat file when you shrink "A" and "B" ?
> > And what happnes
> > # sync
> > # sync
> > # sync
> > # reduce memory A
> > # reduce memory B
> 
> Sync doesn't help. Here is log just for memory.stat for group I tried to shrink:
> 
> ivanoe:/cgroups/root# cat C/memory.stat
> cache 0
> rss 90222592

Hmm, memcg is filled with 86MB of anon pages....So, all "pageout" in this
will go swap.

> mapped_file 0
> pgpgin 1212770
> pgpgout 1190743
> inactive_anon 45338624
> active_anon 44883968

(Off topic) IIUC, this active/inactive ratio has been modified in recent kernel.
            So, new swapout may do different behavior.

> inactive_file 0
> active_file 0
> unevictable 0
> hierarchical_memory_limit 94371840
> hierarchical_memsw_limit 9223372036854775807
> total_cache 0
> total_rss 90222592
> total_mapped_file 0
> total_pgpgin 1212770
> total_pgpgout 1190743
> total_inactive_anon 45338624
> total_active_anon 44883968
> total_inactive_file 0
> total_active_file 0
> total_unevictable 0
> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
> -bash: echo: write error: Device or resource busy
> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
> -bash: echo: write error: Device or resource busy
> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
> -bash: echo: write error: Device or resource busy
> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes


So, this means reducing limit from 90M->30M and
failure of 50MB swapout.

> ivanoe:/cgroups/root# cat memory.limit_in_bytes
> 125829120
> ivanoe:/cgroups/root# cat B/memory.limit_in_bytes
> 62914560
> ivanoe:/cgroups/root# cat A/memory.limit_in_bytes
> 20971520
> 

Ah....I have to explain this.

  (root) limited to 120MB
  (A)    limited to 60MB and this is children of (root)
  (B)    limited to 20MB and this is children of (root)
  (C)    limited to 90MB(now) and this is children of (root)

And now, you want to set limit of (C) to 30MB.

At first, memory cgroup has 2 mode. Do you know memory.use_hierarchy file ?

If memory.use_hierarchy == 0, all cgroups under the cgroup are flat.
In above, if root/memory.use_hierarhy == 0, A and B and C and (root) are
all independent from each other.

If memory.use_hierarchy == 1, all cgroups under the cgroup are in tree.
In above, if root/memory.use_hierarchy == 1, A and B and C works as children
of (root) and usage of A+B+C is limited by (root). 

If you use root/memory.use_hierarchy==0, changing limit of C doesn't affect to
(root) and (root/A) and (root/B). All works will be done in C and you can set
arbitrary limit.

Even if you use root/memory.use_hierarchy==1, changing limit of C will not
affect to (root) and (root/A) and (root/B). All pageout will be done in C
but you can't set limit larger than (root).

(Off topic)If you use root/memory.use_hierarchy==1, changing limit of (root)
will affect (A) and (B) and (C). Then memory are reclaimed from (A) and (B)
and (C) because (root) is parent of (A) and (B) and (C).



So, in this case, only "C" is the problem.
And, at swapout, it may be problem how swap is slow.

The logic of pageout(swapout) at shrinking is:

0. retry_count=5
1. usage = current_usage
2. limit = new limit.
3. if (usage < limit) => goto end(success)
4. try to reclaim memory.
5. new_usage = current_usage
6. if (new_usage >= usage) retry_count--
7. if (retry_count < 0) goto end(-EBUSY)

So, It depends on workload(swapin) and speed of swapout whether it will success.
It seems pagein in "C" is faster than swapout of shrinking itelation.

So, why you succeed to reduce limit by 1MB is maybe because pagein is blocked
by hitting memory limit. So, shrink usage can success.

To make success rate higher, it seems 
 1) memory cgroup should do harder retry
    Difficulty with this is that we have no guarantee. 
or
 2) memory cgroup should block pagein.
    Difficulty with this is tasks may stop too long. (if new limit is bad.)

I may not be able to give you good advise about SLES.
I'll think about some and write a patch. Thank you for reporting.
I hope my patch may be able to be backported.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
