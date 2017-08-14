Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F57F6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:59:22 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k71so14167601wrc.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:59:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z89si3613342wrb.443.2017.08.14.06.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 06:59:21 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:59:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170814135919.GO19063@dhcp22.suse.cz>
References: <20170807113839.16695-3-mhocko@kernel.org>
 <201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
 <20170811070938.GA30811@dhcp22.suse.cz>
 <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
 <20170811120825.GG30811@dhcp22.suse.cz>
 <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 12-08-17 00:46:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 11-08-17 16:54:36, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > > > Will you explain the mechanism why random values are written instead of zeros
> > > > > so that this patch can actually fix the race problem?
> > > > 
> > > > I am not sure what you mean here. Were you able to see a write with an
> > > > unexpected content?
> > > 
> > > Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .
> > 
> > Ahh, I've missed that random part of your output. That is really strange
> > because AFAICS the oom reaper shouldn't really interact here. We are
> > only unmapping anonymous memory and even if a refault slips through we
> > should always get zeros.
> > 
> > Your test case doesn't mmap MAP_PRIVATE of a file so we shouldn't even
> > get any uninitialized data from a file by missing CoWed content. The
> > only possible explanations would be that a page fault returned a
> > non-zero data which would be a bug on its own or that a file write
> > extend the file without actually writing to it which smells like a fs
> > bug to me.
> 
> As I wrote at http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp ,
> I don't think it is a fs bug.

Were you able to reproduce with other filesystems? I wonder what is
different in my testing because I cannot reproduce this at all. Well, I
had to reduce the number of competing writer threads to 128 because I
quickly hit the trashing behavior with more of them (and 4 CPUs). I will
try on a larger machine.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
