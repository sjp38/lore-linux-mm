Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6060800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:55:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v14so559388wmd.3
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 06:55:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g59si380497wrd.443.2018.01.23.06.55.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 06:55:35 -0800 (PST)
Date: Tue, 23 Jan 2018 15:55:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
Message-ID: <20180123145530.GO1526@dhcp22.suse.cz>
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123145506.GN1526@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz, linux-api@vger.kernel.org

On Tue 23-01-18 15:55:06, Michal Hocko wrote:
> [Please cc linux-api when proposing user interface]

now for real...

> On Mon 22-01-18 11:10:14, Vinayak Menon wrote:
> > Based on Kirill's patch [1].
> > 
> > Currently, faultaround code produces young pte.  This can screw up
> > vmscan behaviour[2], as it makes vmscan think that these pages are hot
> > and not push them out on first round.
> > 
> > During sparse file access faultaround gets more pages mapped and all of
> > them are young. Under memory pressure, this makes vmscan swap out anon
> > pages instead, or to drop other page cache pages which otherwise stay
> > resident.
> > 
> > Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
> > is set, so they can easily be reclaimed under memory pressure.
> > 
> > This can to some extend defeat the purpose of faultaround on machines
> > without hardware accessed bit as it will not help us with reducing the
> > number of minor page faults.
> 
> So we just want to add a knob to cripple the feature? Isn't it better to
> simply disable it than to have two distinct implementation which is
> rather non-intuitive and I would bet that most users will be clueless
> about how to set it or when to touch it at all. So we will end up with
> random cargo cult hints all over internet giving you your performance
> back...
> 
> I really dislike this new interface. If the fault around doesn't work
> for you then disable it.
> 
> > Making the faultaround ptes old results in a unixbench regression for some
> > architectures [3][4]. But on some architectures like arm64 it is not found
> > to cause any regression.
> > 
> > unixbench shell8 scores on arm64 v8.2 hardware with CONFIG_ARM64_HW_AFDBM
> > enabled  (5 runs min, max, avg):
> > Base: (741,748,744)
> > With this patch: (739,748,743)
> > 
> > So by default produce young ptes and provide a sysctl option to make the
> > ptes old.
> >
> > [1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
> > [2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
> > [3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
> > [4] https://marc.info/?l=linux-mm&m=146589376909424&w=2
> > 
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
