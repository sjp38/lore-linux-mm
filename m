Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id AE73B6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:57:58 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id w7so1546336lbi.2
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:57:57 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id on7si19436822lbb.95.2014.04.18.10.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 10:57:56 -0700 (PDT)
Message-ID: <5351679F.5040908@parallels.com>
Date: Fri, 18 Apr 2014 21:57:51 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg with kmem limit doesn't recover after disk i/o causes limit
 to be hit
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz>
In-Reply-To: <20140418155939.GE4523@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi Richard,

18.04.2014 19:59, Michal Hocko:
> [CC Vladimir]
> 
> On Wed 16-04-14 16:46:50, Richard Davies wrote:
>> Hi all,
>>
>> I have a simple reproducible test case in which untar in a memcg with a kmem
>> limit gets into trouble during heavy disk i/o (on ext3) and never properly
>> recovers. This is simplified from real world problems with heavy disk i/o
>> inside containers.
>>
>> I feel there are probably two bugs here
>> - the disk i/o is not successfully managed within the kmem limit
>> - the cgroup never recovers, despite the untar i/o process exiting

Unfortunately, work on per cgroup kmem limits is not completed yet.
Currently it lacks kmem reclaim on per cgroup memory pressure, which is
vital for using kmem limits in real life. Basically that means that if a
process inside a memory cgroup reaches its kmem limit, it will be
returned ENOMEM on any allocation attempt, and no attempt will be made
to reclaim old cached data.

In your case untar consumes all kmem available to the cgroup by
allocating memory for storing fs metadata (inodes, dentries). Those
metadata are left cached in memory after untar dies, because they can be
potentially used by other processes. As a result, any further attempt to
allocate kmem (e.g. to create a process) will fail. It should try to
reclaim the cached metadata instead, but this functionality is not
implemented yet.

In short, kmem limiting for memory cgroups is currently broken. Do not
use it. We are working on making it usable though.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
