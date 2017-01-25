Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8051E6B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:46:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so36189921wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:46:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si26303532wrx.326.2017.01.25.02.46.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 02:46:07 -0800 (PST)
Date: Wed, 25 Jan 2017 11:46:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170125104605.GI32377@dhcp22.suse.cz>
References: <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
 <20170119112336.GN30786@dhcp22.suse.cz>
 <20170119131143.2ze5l5fwheoqdpne@suse.de>
 <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
 <20170125101517.GG32377@dhcp22.suse.cz>
 <20170125101957.GA17632@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125101957.GA17632@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 11:19:57, Christoph Hellwig wrote:
> On Wed, Jan 25, 2017 at 11:15:17AM +0100, Michal Hocko wrote:
> > I think we are missing a check for fatal_signal_pending in
> > iomap_file_buffered_write. This means that an oom victim can consume the
> > full memory reserves. What do you think about the following? I haven't
> > tested this but it mimics generic_perform_write so I guess it should
> > work.
> 
> Hi Michal,
> 
> this looks reasonable to me.  But we have a few more such loops,
> maybe it makes sense to move the check into iomap_apply?

I wasn't sure about the expected semantic of iomap_apply but now that
I've actually checked all the callers I believe all of them should be
able to handle EINTR just fine. Well iomap_file_dirty, iomap_zero_range,
iomap_fiemap and iomap_page_mkwriteseem do not follow the standard
pattern to return the number of written pages or an error but it rather
propagates the error out. From my limited understanding of those code
paths that should just be ok. I was not all that sure about iomap_dio_rw
that is just too convoluted for me. If that one is OK as well then
the following patch should be indeed better.
---
