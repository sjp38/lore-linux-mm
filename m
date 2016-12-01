Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 155DE6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 14:39:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so115050457pgq.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 11:39:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s137si1308050pfs.170.2016.12.01.11.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 11:39:11 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1Jd7JW105207
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 14:39:11 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 272t278gsk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:39:11 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 12:39:08 -0700
Date: Thu, 1 Dec 2016 11:39:07 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
 <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
 <20161130182552.GN18432@dhcp22.suse.cz>
 <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
Message-Id: <20161201193907.GR3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 01, 2016 at 09:10:01PM +0300, Boris Zhmurov wrote:
> Michal Hocko 30/11/16 21:25:
> 
> >>> Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
> >>
> >> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
> >> I can try another portion of patches, no problem :)
> > 
> > Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
> > be really helpful to tell whether we are missing a real scheduling point
> > or whether something more serious is going on here.
> 
> Well, I can confirm, that replacing cond_resched_rcu_qs in
> shrink_node_memcg by cond_resched also makes dmesg clean from RCU CPU
> stall warnings.
> 
> I've attached patch (just modification of Paul's patch), that fixes RCU
> stall messages in situations, when all memory is used by
> couchbase/memcached + fs cache and linux starts to use swap.
> 
> 
> -- 
> Boris Zhmurov
> System/Network Administrator
> mailto: bb@kernelpanic.ru
> "wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

> --- a/mm/vmscan.c.orig	2016-11-30 21:52:58.314895320 +0300
> +++ b/mm/vmscan.c	2016-11-30 21:53:29.502895320 +0300
> @@ -2352,6 +2352,7 @@
>  				nr_reclaimed += shrink_list(lru, nr_to_scan,
>  							    lruvec, sc);
>  			}
> +			cond_resched();
>  		}
> 
>  		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)

Nice!

Just to double-check, could you please also test your patch above with
these two commits from -rcu?

d2db185bfee8 ("rcu: Remove short-term CPU kicking")
f8f127e738e3 ("rcu: Add long-term CPU kicking")

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
