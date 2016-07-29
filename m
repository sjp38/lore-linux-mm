Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4F3E6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:35:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so35947810lfe.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:35:33 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x206si3530392wmg.67.2016.07.29.06.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 06:35:31 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so15770141wmg.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:35:31 -0700 (PDT)
Date: Fri, 29 Jul 2016 15:35:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160729133529.GE8031@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729161039-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri 29-07-16 16:14:10, Michael S. Tsirkin wrote:
> On Fri, Jul 29, 2016 at 08:04:22AM +0200, Michal Hocko wrote:
> > On Thu 28-07-16 23:41:53, Michael S. Tsirkin wrote:
> > > On Thu, Jul 28, 2016 at 09:42:33PM +0200, Michal Hocko wrote:
[...]
> > > > and the reader would hit a page fault
> > > > +	 * if it stumbled over a reaped memory.
> > > 
> > > This last point I don't get. flag read could bypass data read
> > > if that happens data read could happen after unmap
> > > yes it might get a PF but you handle that, correct?
> > 
> > The point I've tried to make is that if the reader really page faults
> > then get_user will imply the full barrier already. If get_user didn't
> > page fault then the state of the flag is not really important because
> > the reaper shouldn't have touched it. Does it make more sense now or
> > I've missed your question?
> 
> Can task flag read happen before the get_user pagefault?

Do you mean?

get_user_mm()
  temp = false <- test_bit(MMF_UNSTABLE, &mm->flags)
  ret = __get_user(x, ptr)
  #PF
  if (!ret && temp) # misses the flag

The code is basically doing

  if (!__get_user() && test_bit(MMF_UNSTABLE, &mm->flags))

so test_bit part of the conditional cannot be evaluated before
__get_user() part is done. Compiler cannot reorder two depending
subconditions AFAIK.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
