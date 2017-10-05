Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 678E46B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:49:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y44so6986641wrd.16
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:49:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g48si10267274wra.85.2017.10.05.03.49.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 03:49:22 -0700 (PDT)
Date: Thu, 5 Oct 2017 12:49:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171005104918.zguzsw3mh2oqytx6@dhcp22.suse.cz>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
 <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
 <20171004231821.GA3610@cmpxchg.org>
 <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
 <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 05-10-17 19:36:17, Tetsuo Handa wrote:
> On 2017/10/05 16:57, Michal Hocko wrote:
> > On Wed 04-10-17 19:18:21, Johannes Weiner wrote:
> >> On Wed, Oct 04, 2017 at 03:32:45PM -0700, Andrew Morton wrote:
> > [...]
> >>> You don't think they should be backported into -stables?
> >>
> >> Good point. For this one, it makes sense to CC stable, for 4.11 and
> >> up. The second patch is more of a fortification against potential
> >> future issues, and probably shouldn't go into stable.
> > 
> > I am not against. It is true that the memory reserves depletion fix was
> > theoretical because I haven't seen any real life bug. I would argue that
> > the more robust allocation failure behavior is a stable candidate as
> > well, though, because the allocation can fail regardless of the vmalloc
> > revert. It is less likely but still possible.
> > 
> 
> I don't want this patch backported. If you want to backport,
> "s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.
> 
> On 2017/10/04 17:33, Michal Hocko wrote:
> > Now that we have cd04ae1e2dc8 ("mm, oom: do not rely on TIF_MEMDIE for
> > memory reserves access") the risk of the memory depletion is much
> > smaller so reverting the above commit should be acceptable. 
> 
> Are you aware that stable kernels do not have cd04ae1e2dc8 ?

yes

> We added fatal_signal_pending() check inside read()/write() loop
> because one read()/write() request could consume 2GB of kernel memory.

yes, because this is easily trigerable by userspace.

> What if there is a kernel module which uses vmalloc(1GB) from some
> ioctl() for legitimate reason? You are going to allow such vmalloc()
> calls to deplete memory reserves completely.

Do you have any specific example in mind? If yes we can handle it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
