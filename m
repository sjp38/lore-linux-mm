Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id CC518828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 17:05:26 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id l13so8144651iga.1
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 14:05:26 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id 34si342673iop.81.2015.02.05.14.05.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 14:05:26 -0800 (PST)
Received: by mail-ig0-f173.google.com with SMTP id a13so2028918igq.0
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 14:05:26 -0800 (PST)
References: <20150130044324.GA25699@htj.dyndns.org> <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com> <20150130062737.GB25699@htj.dyndns.org> <20150130160722.GA26111@htj.dyndns.org> <54CFCF74.6090400@yandex-team.ru> <20150202194608.GA8169@htj.dyndns.org> <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com> <20150204170656.GA18858@htj.dyndns.org> <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com> <20150205131514.GD25736@htj.dyndns.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
In-reply-to: <20150205131514.GD25736@htj.dyndns.org>
Date: Thu, 05 Feb 2015 14:05:19 -0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>


On Thu, Feb 05 2015, Tejun Heo wrote:

> Hello, Greg.
>
> On Wed, Feb 04, 2015 at 03:51:01PM -0800, Greg Thelen wrote:
>> I think the linux-next low (and the TBD min) limits also have the
>> problem for more than just the root memcg.  I'm thinking of a 2M file
>> shared between C and D below.  The file will be charged to common parent
>> B.
>> 
>> 	A
>> 	+-B    (usage=2M lim=3M min=2M)
>> 	  +-C  (usage=0  lim=2M min=1M shared_usage=2M)
>> 	  +-D  (usage=0  lim=2M min=1M shared_usage=2M)
>> 	  \-E  (usage=0  lim=2M min=0)
>> 
>> The problem arises if A/B/E allocates more than 1M of private
>> reclaimable file data.  This pushes A/B into reclaim which will reclaim
>> both the shared file from A/B and private file from A/B/E.  In contrast,
>> the current per-page memcg would've protected the shared file in either
>> C or D leaving A/B reclaim to only attack A/B/E.
>> 
>> Pinning the shared file to either C or D, using TBD policy such as mount
>> option, would solve this for tightly shared files.  But for wide fanout
>> file (libc) the admin would need to assign a global bucket and this
>> would be a pain to size due to various job requirements.
>
> Shouldn't we be able to handle it the same way as I proposed for
> handling sharing?  The above would look like
>
>  	A
>  	+-B    (usage=2M lim=3M min=2M hosted_usage=2M)
>  	  +-C  (usage=0  lim=2M min=1M shared_usage=2M)
>  	  +-D  (usage=0  lim=2M min=1M shared_usage=2M)
>  	  \-E  (usage=0  lim=2M min=0)
>
> Now, we don't wanna use B's min verbatim on the hosted inodes shared
> by children but we're unconditionally charging the shared amount to
> all sharing children, which means that we're eating into the min
> settings of all participating children, so, we should be able to use
> sum of all sharing children's min-covered amount as the inode's min,
> which of course is to be contained inside the min of the parent.
>
> Above, we're charging 2M to C and D, each of which has 1M min which is
> being consumed by the shared charge (the shared part won't get
> reclaimed from the internal pressure of children, so we're really
> taking that part away from it).  Summing them up, the shared inode
> would have 2M protection which is honored as long as B as a whole is
> under its 3M limit.  This is similar to creating a dedicated child for
> each shared resource for low limits.  The downside is that we end up
> guarding the shared inodes more than non-shared ones, but, after all,
> we're charging it to everybody who's using it.
>
> Would something like this work?

Maybe, but I want to understand more about how pressure works in the
child.  As C (or D) allocates non shared memory does it perform reclaim
to ensure that its (C.usage + C.shared_usage < C.lim).  Given C's
shared_usage is linked into B.LRU it wouldn't be naturally reclaimable
by C.  Are you thinking that charge failures on cgroups with non zero
shared_usage would, as needed, induce reclaim of parent's hosted_usage?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
