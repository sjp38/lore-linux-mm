Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8BECB6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 03:27:41 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 17:18:50 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C78022CE804D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:27:34 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B7E6Ps7078270
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:14:06 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B7RW1V009499
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:27:34 +1000
Date: Thu, 11 Apr 2013 15:27:30 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130411072729.GA3605@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
 <20130409012931.GE17758@dastard>
 <20130409020505.GA4218@lge.com>
 <20130409123008.GM17758@dastard>
 <20130410025115.GA5872@lge.com>
 <20130410100752.GA10481@dastard>
 <CAAmzW4OMyZ=nVbHK_AiifPK5LVxvhOQUXmsD5NGfo33CBjf=eA@mail.gmail.com>
 <20130411004114.GC10481@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411004114.GC10481@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Apr 11, 2013 at 10:41:14AM +1000, Dave Chinner wrote:
>On Wed, Apr 10, 2013 at 11:03:39PM +0900, JoonSoo Kim wrote:
>> Another one what I found is that they don't account "nr_reclaimed" precisely.
>> There is no code which check whether "current->reclaim_state" exist or not,
>> except prune_inode().
>
>That's because prune_inode() can free page cache pages when the
>inode mapping is invalidated. Hence it accounts this in addition
>to the slab objects being freed.
>
>IOWs, if you have a shrinker that frees pages from the page cache,
>you need to do this. Last time I checked, only inode cache reclaim
>caused extra page cache reclaim to occur, so most (all?) other
>shrinkers do not need to do this.
>

If we should account "nr_reclaimed" against huge zero page? There are 
large number(512) of pages reclaimed which can throttle direct or 
kswapd relcaim to avoid reclaim excess pages. I can do this work if 
you think the idea is needed.

Regards,
Wanpeng Li 

>It's just another wart that we need to clean up....
>
>Cheers,
>
>Dave.
>-- 
>Dave Chinner
>david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
