Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BF174900138
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 20:08:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 364953EE0C2
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:08:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6D345DF44
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:08:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD35845DF49
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:08:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C75F21DB8037
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:08:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8674C1DB803F
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:08:51 +0900 (JST)
Date: Mon, 29 Aug 2011 09:01:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 40262] New: PROBLEM: I/O storm from hell on
 kernel 3.0.0 when touch swap (swapfile or partition)
Message-Id: <20110829090124.7d773ced.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E5A22DF.1080100@openvz.org>
References: <bug-40262-10286@https.bugzilla.kernel.org/>
	<20110826163247.6ed99365.akpm@linux-foundation.org>
	<4E5A22DF.1080100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "g0re@null.net" <g0re@null.net>, "StMichalke@web.de" <StMichalke@web.de>, Mel Gorman <mel@csn.ul.ie>

On Sun, 28 Aug 2011 15:13:35 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Andrew Morton wrote:
>  >
>  > (switched to email.  Please respond via emailed reply-to-all, not via the
>  > bugzilla web interface).
>  >
>  > On Thu, 28 Jul 2011 12:41:03 GMT
>  > bugzilla-daemon@bugzilla.kernel.org wrote:
>  >
>  >> https://bugzilla.kernel.org/show_bug.cgi?id=40262
>  >
>  > Two people are reporting this - there are some additional details in
>  > bugzilla.
>  >
>  > We seem to be going around in circles here.
>  >
>  > I'll ask Rafael and Maciej to track this as a regression :(
>  >
> 
> >>
> >> issue occurs in new kernel 3.0.
> >> does not occurs in 2.6.39.3/2.6.38.8
> >>
> 
> I guess this can be caused by commit v2.6.39-6846-g246e87a "memcg: fix vmscan count in small memcgs"
> (it also tweaked kswapd besides of memcg reclaimer)
> it was fixed in v3.0-5361-g4508378 "memcg: fix get_scan_count() for small targets"
> 
> commit 4508378b9523e22a2a0175d8bf64d932fb10a67d
> Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date:   Tue Jul 26 16:08:24 2011 -0700
> 
>      memcg: fix vmscan count in small memcgs
> 
>      Commit 246e87a93934 ("memcg: fix get_scan_count() for small targets")
>      fixes the memcg/kswapd behavior against small targets and prevent vmscan
>      priority too high.
> 
>      But the implementation is too naive and adds another problem to small
>      memcg.  It always force scan to 32 pages of file/anon and doesn't handle
>      swappiness and other rotate_info.  It makes vmscan to scan anon LRU
>      regardless of swappiness and make reclaim bad.  This patch fixes it by
>      adjusting scanning count with regard to swappiness at el.
> 
>      At a test "cat 1G file under 300M limit." (swappiness=20)
>       before patch
>              scanned_pages_by_limit 360919
>              scanned_anon_pages_by_limit 180469
>              scanned_file_pages_by_limit 180450
>              rotated_pages_by_limit 31
>              rotated_anon_pages_by_limit 25
>              rotated_file_pages_by_limit 6
>              freed_pages_by_limit 180458
>              freed_anon_pages_by_limit 19
>              freed_file_pages_by_limit 180439
>              elapsed_ns_by_limit 429758872
>       after patch
>              scanned_pages_by_limit 180674
>              scanned_anon_pages_by_limit 24
>              scanned_file_pages_by_limit 180650
>              rotated_pages_by_limit 35
>              rotated_anon_pages_by_limit 24
>              rotated_file_pages_by_limit 11
>              freed_pages_by_limit 180634
>              freed_anon_pages_by_limit 0
>              freed_file_pages_by_limit 180634
>              elapsed_ns_by_limit 367119089
>              scanned_pages_by_system 0
> 
>      the numbers of scanning anon are decreased(as expected), and elapsed time
>      reduced. By this patch, small memcgs will work better.
>      (*) Because the amount of file-cache is much bigger than anon,
>          recalaim_stat's rotate-scan counter make scanning files more.
> 

Ah, yes. this patch may be able to fix the probelm...could you try ? 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
