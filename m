Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id C766C6B0031
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 23:01:06 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so3793340pbc.9
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 20:01:06 -0700 (PDT)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id db4si2634395pbc.262.2013.10.27.20.01.04
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 20:01:05 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 28 Oct 2013 08:31:01 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3B8A0394004D
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:30:36 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9S30tMg19923186
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:30:55 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9S30uXb019603
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:30:57 +0530
Date: Mon, 28 Oct 2013 11:00:55 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131028030055.GC15642@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027123008.GJ14934@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 27, 2013 at 08:30:08AM -0400, Tejun Heo wrote:
>On Mon, Oct 21, 2013 at 04:58:11PM +0800, Wei Yang wrote:
>> When a cpu belongs to a new group, there is no cpu has the same group id. This
>> means it can be assigned a new group id without checking with every others.
>> 
>> This patch does this optimiztion.
>
>Does this actually matter?  If so, it'd probably make a lot more sense
>to start inner loop at @cpu + 1 so that it becomes O(N).

One of the worst case in my mind:

CPU:        0    1    2    3    4    ...
Group:      0    1    2    3    4    ...
(sounds it is impossible in the real world)

Every time, when we encounter a new CPU and try to assign it to a group, we
found it belongs to a new group. The original logic will iterate on all old
CPUs again, while the new logic could skip this and assign it to a new group.

Again, this is a tiny change, which doesn't matters a lot.

BTW, I don't get your point for "start inner loop at @cpu+1".

The original logic is:
	loop 1:   0 - nr_cpus
	loop 2:      0 - (cpu - 1)

If you found one better approach to improve the logic, I believe all the users
will appreciate your efforts :-)

Thanks for your review and comments again ~

>
>Thanks.
>
>-- 
>tejun

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
