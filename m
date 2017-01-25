Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AADC06B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:00:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so37901559wme.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:00:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si25997281wrp.137.2017.01.25.05.00.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 05:00:16 -0800 (PST)
Date: Wed, 25 Jan 2017 14:00:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170125130014.GO32377@dhcp22.suse.cz>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
 <20170125101517.GG32377@dhcp22.suse.cz>
 <20170125101957.GA17632@lst.de>
 <20170125104605.GI32377@dhcp22.suse.cz>
 <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 20:09:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 25-01-17 11:19:57, Christoph Hellwig wrote:
> > > On Wed, Jan 25, 2017 at 11:15:17AM +0100, Michal Hocko wrote:
> > > > I think we are missing a check for fatal_signal_pending in
> > > > iomap_file_buffered_write. This means that an oom victim can consume the
> > > > full memory reserves. What do you think about the following? I haven't
> > > > tested this but it mimics generic_perform_write so I guess it should
> > > > work.
> > > 
> > > Hi Michal,
> > > 
> > > this looks reasonable to me.  But we have a few more such loops,
> > > maybe it makes sense to move the check into iomap_apply?
> > 
> > I wasn't sure about the expected semantic of iomap_apply but now that
> > I've actually checked all the callers I believe all of them should be
> > able to handle EINTR just fine. Well iomap_file_dirty, iomap_zero_range,
> > iomap_fiemap and iomap_page_mkwriteseem do not follow the standard
> > pattern to return the number of written pages or an error but it rather
> > propagates the error out. From my limited understanding of those code
> > paths that should just be ok. I was not all that sure about iomap_dio_rw
> > that is just too convoluted for me. If that one is OK as well then
> > the following patch should be indeed better.
> 
> Is "length" in
> 
>    written = actor(inode, pos, length, data, &iomap);
> 
> call guaranteed to be small enough? If not guaranteed,
> don't we need to check SIGKILL inside "actor" functions?

You are right! Checking for signals inside iomap_apply doesn't really
solve anything because basically all users do iov_iter_count(). Blee. So
we have loops around iomap_apply which itself loops inside the actor.
iomap_write_begin seems to be used by most of them which is also where we
get the pagecache page so I guess this should be the "right" place to
put the check in. Things like dax_iomap_actor will need an explicit check.
This is quite unfortunate but I do not see any better solution.
What do you think Christoph?
---
