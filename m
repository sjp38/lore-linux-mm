Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 40125900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 12:58:28 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id pn19so3032063lab.2
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 09:58:27 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id r14si2013130lal.15.2015.02.04.09.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 09:58:26 -0800 (PST)
Message-ID: <54D25DBD.5080009@yandex-team.ru>
Date: Wed, 04 Feb 2015 20:58:21 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
References: <20150130044324.GA25699@htj.dyndns.org> <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com> <20150130062737.GB25699@htj.dyndns.org> <20150130160722.GA26111@htj.dyndns.org> <54CFCF74.6090400@yandex-team.ru> <20150202194608.GA8169@htj.dyndns.org> <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com> <54D1F924.5000001@yandex-team.ru> <20150204171512.GB18858@htj.dyndns.org>
In-Reply-To: <20150204171512.GB18858@htj.dyndns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>

On 04.02.2015 20:15, Tejun Heo wrote:
> Hello,
>
> On Wed, Feb 04, 2015 at 01:49:08PM +0300, Konstantin Khlebnikov wrote:
>> I think important shared data must be handled and protected explicitly.
>> That 'catch-all' shared container could be separated into several
>
> I kinda disagree.  That'd be a major pain in the ass to use and you
> wouldn't know when you got something wrong unless it actually goes
> wrong and you know enough about the innerworkings to look for that.
> Doesn't sound like a sound design to me.
>
>> memory cgroups depending on importance of files: glibc protected
>> with soft guarantee, less important stuff is placed into another
>> cgroup and cannot push top-priority libraries out of ram.
>
> That sounds extremely painful.

I mean this thing _could_ be controlled more precisely. Even if default
policy works for 99% users manual override is still required for 1% or
if something goes wrong.

>
>> If shared files are free for use then that 'shared' container must be
>> ready to keep them in memory. Otherwise this need to be fixed at the
>> container side: we could ignore mlock for shared inodes or amount of
>> such vmas might be limited in per-container basis.
>>
>> But sharing responsibility for shared file is vague concept: memory
>> usage and limit of container must depends only on its own behavior not
>> on neighbors at the same machine.
>>
>>
>> Generally incidental sharing could be handled as temporary sharing:
>> default policy (if inode isn't pinned to memory cgroup) after some
>> time should detect that inode is no longer shared and migrate it into
>> original cgroup. Of course task could provide hit: O_NO_MOVEMEM or
>> even while memory cgroup where it runs could be marked as "scanner"
>> which shouldn't disturb memory classification.
>
> Ditto for annotating each file individually.  Let's please try to stay
> away from things like that.  That's mostly a cop-out which is unlikely
> to actually benefit the majority of users.

Process which scans all files once isn't so rare use case.
Linux still cannot handle this pattern sometimes.

>
>> I've missed obvious solution for controlling memory cgroup for files:
>> project id. This persistent integer id stored in file system. For now
>> it's implemented only for xfs and used for quota which is orthogonal
>> to user/group quotas. We could map some of project id to memory cgroup.
>> That is more flexible than per-superblock mark, has no conflicts like
>> mark on bind-mount.
>
> Again, hell, no.
>
> Thanks.
>

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
