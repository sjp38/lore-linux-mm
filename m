Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB7EC6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:57:49 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id j12so111229669ywb.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:57:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z185si12930897qkc.32.2016.07.29.10.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:57:49 -0700 (PDT)
Date: Fri, 29 Jul 2016 20:57:44 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160729205620-mutt-send-email-mst@kernel.org>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729133529.GE8031@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, Jul 29, 2016 at 03:35:29PM +0200, Michal Hocko wrote:
> On Fri 29-07-16 16:14:10, Michael S. Tsirkin wrote:
> > On Fri, Jul 29, 2016 at 08:04:22AM +0200, Michal Hocko wrote:
> > > On Thu 28-07-16 23:41:53, Michael S. Tsirkin wrote:
> > > > On Thu, Jul 28, 2016 at 09:42:33PM +0200, Michal Hocko wrote:
> [...]
> > > > > and the reader would hit a page fault
> > > > > +	 * if it stumbled over a reaped memory.
> > > > 
> > > > This last point I don't get. flag read could bypass data read
> > > > if that happens data read could happen after unmap
> > > > yes it might get a PF but you handle that, correct?
> > > 
> > > The point I've tried to make is that if the reader really page faults
> > > then get_user will imply the full barrier already. If get_user didn't
> > > page fault then the state of the flag is not really important because
> > > the reaper shouldn't have touched it. Does it make more sense now or
> > > I've missed your question?
> > 
> > Can task flag read happen before the get_user pagefault?
> 
> Do you mean?
> 
> get_user_mm()
>   temp = false <- test_bit(MMF_UNSTABLE, &mm->flags)
>   ret = __get_user(x, ptr)
>   #PF
>   if (!ret && temp) # misses the flag
> 
> The code is basically doing
> 
>   if (!__get_user() && test_bit(MMF_UNSTABLE, &mm->flags))
> 
> so test_bit part of the conditional cannot be evaluated before
> __get_user() part is done. Compiler cannot reorder two depending
> subconditions AFAIK.

But maybe the CPU can.

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
