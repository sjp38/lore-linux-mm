Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8206B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 18:31:02 -0500 (EST)
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id o1ONUwkX004819
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:30:58 -0800 (PST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; CHARSET=US-ASCII; delsp=yes; format=flowed
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KYD00J00D3YGT00@fe-sfbay-09.sun.com> for linux-mm@kvack.org; Wed,
 24 Feb 2010 15:30:58 -0800 (PST)
Date: Wed, 24 Feb 2010 16:30:57 -0700
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
In-reply-to: <alpine.DEB.2.00.1002241007220.27592@router.home>
Message-id: <CF019FFE-BB28-409F-A0B2-C9DEEAC801B6@sun.com>
References: <20100224143442.GF3687@quack.suse.cz>
 <alpine.DEB.2.00.1002241007220.27592@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, lsf10-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2010-02-24, at 09:10, Christoph Lameter wrote:
> On Wed, 24 Feb 2010, Jan Kara wrote:
> fine (and you probably don't want much more because the memory is  
> better
>> used for something else), when a machine does random rewrites,  
>> going to 40%
>> might be well worth it. So I'd like to discuss how we could measure  
>> that
>> increasing amount of dirtiable memory helps so that we could  
>> implement
>> dynamic sizing of it.
>
> Another issue around dirty limits is that they are global. If you are
> running multiple jobs on the same box (memcg or cpusets or you set
> affinities to separate the box) then every job may need different  
> dirty
> limits. One idea that I had in the past was to set dirty limits  
> based on
> nodes or cpusets. But that will not cover the other cases that I have
> listed above.
>
> The best solution would be an algorithm that can accomodate multiple  
> loads
> and manage the amount of dirty memory automatically.


Why not dirty limits per file and/or a function of the IO randomness  
vs the file size?  Doing streaming on a large file can easily be  
detected and limited appropriately (either the filesystem can keep up  
and the "smaller" limit will not be hit, or it can't keep up and the  
application needs to be throttled nearly regardless of what the limit  
is).  Doing streaming or random IO on small files is almost  
indistinguishable anyway and should pretty much be treated as random  
IO subject to a "larger" global limit.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
