Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFCE6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:09:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so270163622pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:09:46 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a85si23096587pfk.153.2017.01.25.03.09.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 03:09:45 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
	<201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
	<20170125101517.GG32377@dhcp22.suse.cz>
	<20170125101957.GA17632@lst.de>
	<20170125104605.GI32377@dhcp22.suse.cz>
In-Reply-To: <20170125104605.GI32377@dhcp22.suse.cz>
Message-Id: <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
Date: Wed, 25 Jan 2017 20:09:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hch@lst.de
Cc: mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 25-01-17 11:19:57, Christoph Hellwig wrote:
> > On Wed, Jan 25, 2017 at 11:15:17AM +0100, Michal Hocko wrote:
> > > I think we are missing a check for fatal_signal_pending in
> > > iomap_file_buffered_write. This means that an oom victim can consume the
> > > full memory reserves. What do you think about the following? I haven't
> > > tested this but it mimics generic_perform_write so I guess it should
> > > work.
> > 
> > Hi Michal,
> > 
> > this looks reasonable to me.  But we have a few more such loops,
> > maybe it makes sense to move the check into iomap_apply?
> 
> I wasn't sure about the expected semantic of iomap_apply but now that
> I've actually checked all the callers I believe all of them should be
> able to handle EINTR just fine. Well iomap_file_dirty, iomap_zero_range,
> iomap_fiemap and iomap_page_mkwriteseem do not follow the standard
> pattern to return the number of written pages or an error but it rather
> propagates the error out. From my limited understanding of those code
> paths that should just be ok. I was not all that sure about iomap_dio_rw
> that is just too convoluted for me. If that one is OK as well then
> the following patch should be indeed better.

Is "length" in

   written = actor(inode, pos, length, data, &iomap);

call guaranteed to be small enough? If not guaranteed,
don't we need to check SIGKILL inside "actor" functions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
