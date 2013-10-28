Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id E52A16B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 11:17:57 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro8so3200488pbb.41
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:17:57 -0700 (PDT)
Received: from psmtp.com ([74.125.245.189])
        by mx.google.com with SMTP id gl1si13241137pac.343.2013.10.28.08.17.55
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 08:17:56 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 29 Oct 2013 01:17:52 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 25A953578040
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:17:50 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9SFHbMC1704242
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:17:38 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9SFHmGN000668
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:17:48 +1100
Date: Mon, 28 Oct 2013 23:17:46 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131028151746.GA7548@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
 <20131028030055.GC15642@weiyang.vnet.ibm.com>
 <20131028113120.GB11541@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131028113120.GB11541@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 28, 2013 at 07:31:20AM -0400, Tejun Heo wrote:
>Hello,
>
>On Mon, Oct 28, 2013 at 11:00:55AM +0800, Wei Yang wrote:
>> >Does this actually matter?  If so, it'd probably make a lot more sense
>> >to start inner loop at @cpu + 1 so that it becomes O(N).
>> 
>> One of the worst case in my mind:
>> 
>> CPU:        0    1    2    3    4    ...
>> Group:      0    1    2    3    4    ...
>> (sounds it is impossible in the real world)
>
>I was wondering whether you had an actual case where this actually
>matters or it's just something you thought of while reading the code.

Tejun,

Thanks for your comments.

I found this just in code review. :-)

>
>> Every time, when we encounter a new CPU and try to assign it to a group, we
>> found it belongs to a new group. The original logic will iterate on all old
>> CPUs again, while the new logic could skip this and assign it to a new group.
>> 
>> Again, this is a tiny change, which doesn't matters a lot.
>
>I think it *could* matter because the current implementation is O(N^2)
>where N is the number of CPUs.  On machines, say, with 4k CPU, it's
>gonna loop 16M times but then again even that takes only a few
>millisecs on modern machines.

I am not familiar with the real cases of the CPU numbers. Thanks for leting me
know there could be 4K CPUs.

Yep, a few millisecs sounds not a big a mount.

>
>> BTW, I don't get your point for "start inner loop at @cpu+1".
>> 
>> The original logic is:
>> 	loop 1:   0 - nr_cpus
>> 	loop 2:      0 - (cpu - 1)
>> 
>> If you found one better approach to improve the logic, I believe all the users
>> will appreciate your efforts :-)
>
>Ooh, right, I forgot about the break and then I thought somehow that
>would make it O(N).  Sorry about that.  I blame jetlag. :)
>
>Yeah, I don't know.  The function is quite hairy which makes me keep
>things simpler and reluctant to make changes unless it actually makes
>non-trivial difference.  The change looks okay to me but it seems
>neither necessary or substantially beneficial and if my experience is
>anything to go by, *any* change involves some risk of brekage no
>matter how innocent it may look, so given the circumstances, I'd like
>to keep things the way they are.

Yep, I really agree with you. If no big improvement, it is really not
necessary to change the code, which will face some risk.

Here I have another one, which in my mind will improve it in one case. Looking
forward to your comments :-) If I am not correct, please let me know. :-)
