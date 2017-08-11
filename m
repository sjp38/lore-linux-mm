Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 663C66B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:46:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id z19so4162351oia.13
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:46:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l144si845731oig.201.2017.08.11.08.46.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 08:46:28 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when oom_reaper races with writer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170807113839.16695-3-mhocko@kernel.org>
	<201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
	<20170811070938.GA30811@dhcp22.suse.cz>
	<201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
	<20170811120825.GG30811@dhcp22.suse.cz>
In-Reply-To: <20170811120825.GG30811@dhcp22.suse.cz>
Message-Id: <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp>
Date: Sat, 12 Aug 2017 00:46:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 11-08-17 16:54:36, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > > Will you explain the mechanism why random values are written instead of zeros
> > > > so that this patch can actually fix the race problem?
> > > 
> > > I am not sure what you mean here. Were you able to see a write with an
> > > unexpected content?
> > 
> > Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .
> 
> Ahh, I've missed that random part of your output. That is really strange
> because AFAICS the oom reaper shouldn't really interact here. We are
> only unmapping anonymous memory and even if a refault slips through we
> should always get zeros.
> 
> Your test case doesn't mmap MAP_PRIVATE of a file so we shouldn't even
> get any uninitialized data from a file by missing CoWed content. The
> only possible explanations would be that a page fault returned a
> non-zero data which would be a bug on its own or that a file write
> extend the file without actually writing to it which smells like a fs
> bug to me.

As I wrote at http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp ,
I don't think it is a fs bug.

> 
> Anyway I wasn't able to reproduce this and I was running your usecase
> in the loop for quite some time (with xfs storage). How reproducible
> is this? If you can reproduce easily can you simply comment out
> unmap_page_range in __oom_reap_task_mm and see if that makes any change
> just to be sure that the oom reaper can be ruled out?

Frequency of writing not-zero values is lower than frequency of writing zero values.
But if I comment out unmap_page_range() in __oom_reap_task_mm(), I can't even
reproduce writing zero values. As far as I tested, writing not-zero values occurs
only if the OOM reaper is involved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
