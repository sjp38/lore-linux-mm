Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47A106B0253
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:10:06 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id c13so99413606lfg.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:10:06 -0800 (PST)
Received: from mail.setcomm.ru (mail.setcomm.ru. [2a00:1248:5004:5::3])
        by mx.google.com with ESMTP id t11si591845lfi.50.2016.12.01.10.10.04
        for <linux-mm@kvack.org>;
        Thu, 01 Dec 2016 10:10:04 -0800 (PST)
Reply-To: bb@kernelpanic.ru
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
 <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
 <20161130182552.GN18432@dhcp22.suse.cz>
From: Boris Zhmurov <bb@kernelpanic.ru>
Message-ID: <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
Date: Thu, 1 Dec 2016 21:10:01 +0300
MIME-Version: 1.0
In-Reply-To: <20161130182552.GN18432@dhcp22.suse.cz>
Content-Type: multipart/mixed;
 boundary="------------541DA7624281D19B58B355C0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------541DA7624281D19B58B355C0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Michal Hocko 30/11/16 21:25:

>>> Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
>>
>> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
>> I can try another portion of patches, no problem :)
> 
> Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
> be really helpful to tell whether we are missing a real scheduling point
> or whether something more serious is going on here.

Well, I can confirm, that replacing cond_resched_rcu_qs in
shrink_node_memcg by cond_resched also makes dmesg clean from RCU CPU
stall warnings.

I've attached patch (just modification of Paul's patch), that fixes RCU
stall messages in situations, when all memory is used by
couchbase/memcached + fs cache and linux starts to use swap.


-- 
Boris Zhmurov
System/Network Administrator
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

--------------541DA7624281D19B58B355C0
Content-Type: text/x-patch;
 name="linux-4.8-mm-prevent-shrink_node_memcg-RCU-CPU-stall-warnings.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="linux-4.8-mm-prevent-shrink_node_memcg-RCU-CPU-stall-warning";
 filename*1="s.patch"

--- a/mm/vmscan.c.orig	2016-11-30 21:52:58.314895320 +0300
+++ b/mm/vmscan.c	2016-11-30 21:53:29.502895320 +0300
@@ -2352,6 +2352,7 @@
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
 							    lruvec, sc);
 			}
+			cond_resched();
 		}
 
 		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)

--------------541DA7624281D19B58B355C0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
