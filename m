Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CE6366B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:06:59 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x13so15103422wgg.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 06:06:59 -0800 (PST)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id hs6si2968458wjb.68.2015.01.15.06.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 06:06:58 -0800 (PST)
Received: by mail-we0-f170.google.com with SMTP id w61so14919065wes.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 06:06:58 -0800 (PST)
Date: Thu, 15 Jan 2015 15:06:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150115140654.GG7000@dhcp22.suse.cz>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
 <20150107142804.GD16553@dhcp22.suse.cz>
 <20150114212745.GQ6103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114212745.GQ6103@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Wed 14-01-15 22:27:45, Andrea Arcangeli wrote:
> Hello everyone,
> 
> On Wed, Jan 07, 2015 at 03:28:04PM +0100, Michal Hocko wrote:
> > Instead we shouldn't pretend that GFP_KERNEL is basically GFP_NOFAIL.
> > The question is how to get there without too many regressions IMHO.
> > Or maybe we should simply bite a bullet and don't be cowards and simply
> > deal with bugs as they come. If something really cannot deal with the
> > failure it should tell that by a proper flag.
> 
> Not related to memcg but related to GFP_NOFAIL behavior, a couple of
> months ago while stress testing some code I've been working on, I run
> into several OOM livelocks which may be the same you're reporting here
> and I reliably fixed those (at least for my load) so I could keep
> going with my work. I didn't try to submit these changes yet, but this
> discussion rings a bell... so I'm sharing my changes below in this
> thread in case it may help:
> 
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=00e91f97df9861454f7e0701944d7de2c382ffb9

OK, this is interesting. We do fail !GFP_FS allocations but
did_some_progress might prevent from __alloc_pages_may_oom where we
fail. This can lead to a trashing when the reclaim makes some progress
but it doesn't help to succeed allocation. This can take many retries
until no progress can be done and fail much later.

I do agree that failing earlier is slightly better, even though the result
would be more allocation failures which has hard to predict outcome.
Anyway callers should be prepared for the failure and we can hardly think
about performance under such condition. I would happily ack such a patch
if you post it.

> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=a0fcf2323b2e4cffd750c1abc1d2c138acdefcc8

I am not sure about this one because TIF_MEMDIE is there to give an
access to memory reserves. GFP_NOFAIL shouldn't mean the same because
then it would be much harder to "guarantee" that the reserves wouldn't
be depleted completely. So I do not like this much. Besides that I think
that GFP_NOFAIL allocation blocking OOM victim is a plain bug.
grow_dev_page is relying on GFP_NOFAIL but I am wondering whether ext4
can do something to pre-allocate so that it doesn't have to call it.

> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=798b7f9d549664f8c0007c6416a2568eedd75d6a

I think this should be fixed in the filesystem rather than paper over
it.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
