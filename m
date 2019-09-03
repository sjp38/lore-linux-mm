Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 076A2C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:41:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9A7322DBF
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:41:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9A7322DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77D956B0003; Tue,  3 Sep 2019 03:41:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72EA16B0005; Tue,  3 Sep 2019 03:41:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61D526B0006; Tue,  3 Sep 2019 03:41:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 413386B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 03:41:35 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D24B4181AC9BA
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:41:34 +0000 (UTC)
X-FDA: 75892814508.26.crime52_47f4a2780c827
X-HE-Tag: crime52_47f4a2780c827
X-Filterd-Recvd-Size: 3919
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:41:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95018B649;
	Tue,  3 Sep 2019 07:41:32 +0000 (UTC)
Date: Tue, 3 Sep 2019 09:41:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: linux-mm@kvack.org, stable@vger.kernel.org
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
Message-ID: <20190903074132.GM14028@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190902071617.GC14028@dhcp22.suse.cz>
 <a07da432-1fc1-67de-ae35-93f157bf9a7d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a07da432-1fc1-67de-ae35-93f157bf9a7d@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 02-09-19 21:34:29, Thomas Lindroth wrote:
> On 9/2/19 9:16 AM, Michal Hocko wrote:
> > On Sun 01-09-19 22:43:05, Thomas Lindroth wrote:
> > > After upgrading to the 4.19 series I've started getting problems with
> > > early OOM.
> > 
> > What is the kenrel you have updated from? Would it be possible to try
> > the current Linus' tree?
> 
> I did some more testing and it turns out this is not a regression after all.
> 
> I followed up on my hunch and monitored memory.kmem.max_usage_in_bytes while
> running cgexec -g memory:12G bash -c 'find / -xdev -type f -print0 | \
>         xargs -0 -n 1 -P 8 stat > /dev/null'
> 
> Just as memory.kmem.max_usage_in_bytes = memory.kmem.limit_in_bytes the OOM
> killer kicked in and killed my X server.
> 
> Using the find|stat approach it was easy to test the problem in a testing VM.
> I was able to reproduce the problem in all these kernels:
>   4.9.0
>   4.14.0
>   4.14.115
>   4.19.0
>   5.2.11
> 
> 5.3-rc6 didn't build in the VM. The build environment is too old probably.
> 
> I was curious why I initially couldn't reproduce the problem in 4.14 by
> building chromium. I was again able to successfully build chromium using
> 4.14.115. Turns out memory.kmem.max_usage_in_bytes was 1015689216 after
> building and my limit is set to 1073741824. I guess some unrelated change in
> memory management raised that slightly for 4.19 triggering the problem.
> 
> If you want to reproduce for yourself here are the steps:
> 1. build any kernel above 4.9 using something like my .config
> 2. setup a v1 memory cgroup with memory.kmem.limit_in_bytes lower than
>    memory.limit_in_bytes. I used 100M in my testing VM.
> 3. Run "find / -xdev -type f -print0 | xargs -0 -n 1 -P 8 stat > /dev/null"
>    in the cgroup.
> 4. Assuming there is enough inodes on the rootfs the global OOM killer
>    should kick in when memory.kmem.max_usage_in_bytes =
>    memory.kmem.limit_in_bytes and kill something outside the cgroup.

This is certainly a bug. Is this still an OOM triggered from
pagefault_out_of_memory? Since 4.19 (29ef680ae7c21) the memcg charge
path should invoke the memcg oom killer directly from the charge path.
If that doesn't happen then the failing charge is either GFP_NOFS or a
large allocation.

The former has been fixed just recently by http://lkml.kernel.org/r/cbe54ed1-b6ba-a056-8899-2dc42526371d@i-love.sakura.ne.jp
and I suspect this is a fix you are looking for. Although it is curious
that you can see a global oom even before because the charge path would
mark an oom situation even for NOFS context and it should trigger the
memcg oom killer on the way out from the page fault path. So essentially
the same call trace except the oom killer should be constrained to the
memcg context.

Could you try the above patch please?

-- 
Michal Hocko
SUSE Labs

