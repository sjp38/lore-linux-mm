Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAL9xCPl019469
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Nov 2008 18:59:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 96EA345DE53
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:59:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D71645DE51
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:59:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 597711DB803E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:59:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0FEA1DB803A
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:59:11 +0900 (JST)
Date: Fri, 21 Nov 2008 18:58:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg: fix oom handling
Message-Id: <20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49261F87.50209@cn.fujitsu.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
	<20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>
	<49261F87.50209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Li Zefan reported

(a) This goes dead lock:
==
   #echo 0 >  (...)/01/memory.limit_in_bytes   #set memcg's limit to 0,
   #echo $$ > (...)/01/memory.tasks            #move task
   # do something...
==

(b) seems to be dead lock
==
   #echo 40k >  (...)/01/memory.limit_in_bytes   #set memcg's limit to 0,
   #echo $$ > (...)/01/memory.tasks            #move task
   # do something...
==


I think (a) is BUG. (b) is just slow down.
(you can see pgpgin/pgpgout count is increasing in (B).)

This patch set is for handling (a). Li-san, could you check ?
This works well in my environment.(means OOM-Killer is called in proper way.)

 [1/2].... current mmotm has pagefault_out_of_memory() but this doesn't consider
           memcg. When memcg hit limits in page_fault and panic_on_oom is set,
           the kernel panics.
           This tries to fix that.
           (See patches/mm-invoke-oom-killer-from-page-fault.patch)

 [2/2].... fixes wrong logic of check_under_limit.

Anyway, it seems hierarchy support is *not* enough in OOM handler.
Balbir, could you check it ? 
I think "a bad process in hierarchy rather than memcg" should be killed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
