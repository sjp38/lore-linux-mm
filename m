Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F14326B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 03:17:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so42407422wmw.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:17:38 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 124si38716570wma.104.2016.05.19.00.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 00:17:38 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id s63so3960174wme.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:17:37 -0700 (PDT)
Date: Thu, 19 May 2016 09:17:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160519071736.GD26110@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
 <20160519065329.GA26110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519065329.GA26110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Thu 19-05-16 08:53:29, Michal Hocko wrote:
> On Wed 18-05-16 14:09:32, Andrew Morton wrote:
> > On Wed, 18 May 2016 16:15:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > > This patch adds a counter to signal_struct for tracking how many
> > > > TIF_MEMDIE threads are in a given thread group, and check it at
> > > > oom_scan_process_thread() so that select_bad_process() can use
> > > > for_each_process() rather than for_each_process_thread().
> > > 
> > > OK, this looks correct. Strictly speaking the patch is missing any note
> > > on _why_ this is needed or an improvement. I would add something like
> > > the following:
> > > "
> > > Although the original code was correct it was quite inefficient because
> > > each thread group was scanned num_threads times which can be a lot
> > > especially with processes with many threads. Even though the OOM is
> > > extremely cold path it is always good to be as effective as possible
> > > when we are inside rcu_read_lock() - aka unpreemptible context.
> > > "
> > 
> > This sounds quite rubbery to me.  Lots of code calls
> > for_each_process_thread() and presumably that isn't causing problems. 
> 
> Yeah, many paths call for_each_process_thread but they are
> O(num_threads) while this is O(num_threads^2).

And just to clarify the regular num_threads^2 is the absolute worst case
which doesn't happen normally. We would be closer to O(num_threads) but
there is no reason to risk pathological cases when we can simply use
for_each_process to achieve the same.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
