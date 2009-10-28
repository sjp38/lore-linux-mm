Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E47186B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 01:13:55 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n9S5Dpis028247
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 05:13:52 GMT
Received: from pwj11 (pwj11.prod.google.com [10.241.219.75])
	by spaceape13.eur.corp.google.com with ESMTP id n9S5DeAQ001667
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 22:13:49 -0700
Received: by pwj11 with SMTP id 11so625941pwj.20
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 22:13:49 -0700 (PDT)
Date: Tue, 27 Oct 2009 22:13:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, KAMEZAWA Hiroyuki wrote:

> not related to child-parent problem.
> 
> Seeing this number more.
> ==
> [97137.709272] Active_anon:671487 active_file:82 inactive_anon:132316
> [97137.709273]  inactive_file:82 unevictable:50 dirty:0 writeback:0 unstable:0
> [97137.709273]  free:6122 slab:17179 mapped:30661 pagetables:8052 bounce:0
> ==
> 
> acitve_file + inactive_file is very low. Almost all pages are for anon.
> But "mapped(NR_FILE_MAPPED)" is a little high. This implies remaining file caches
> are mapped by many processes OR some mega bytes of shmem is used.
> 
> # of pagetables is 8052, this means
>   8052x4096/8*4k bytes = 16Gbytes of mapped area.
> 
> Total available memory is near to be active/inactive + slab 
> 671487+82+132316+82+50+6122+17179+8052=835370x4k= 3.2Gbytes ?
> (this system is swapless)
> 

Yep:

[97137.724965] 917504 pages RAM
[97137.724967] 69721 pages reserved

(917504 - 69721) * 4K = ~3.23G

> Then, considering the pmap kosaki shows,
> I guess killed ones had big total_vm but has not much real rss,
> and no helps for oom.
> 

echo 1 > /proc/sys/vm/oom_dump_tasks can confirm that.

The bigger issue is making the distinction between killing a rogue task 
that is using much more memory than expected (the supposed current 
behavior, influenced from userspace by /proc/pid/oom_adj), and killing the 
task with the highest rss.  The latter is definitely desired if we are 
allocating tons of memory but reduces the ability of the user to influence 
the badness score.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
