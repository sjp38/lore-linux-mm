Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 809366B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:25:47 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so9934128wjb.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:25:47 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b125si3323878wmd.55.2016.11.22.08.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:25:46 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so4897874wma.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:25:46 -0800 (PST)
Date: Tue, 22 Nov 2016 17:25:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161122162544.GG6831@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marc MERLIN <marc@merlins.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue 22-11-16 17:14:02, Vlastimil Babka wrote:
> On 11/22/2016 05:06 PM, Marc MERLIN wrote:
> > On Mon, Nov 21, 2016 at 01:56:39PM -0800, Marc MERLIN wrote:
> >> On Mon, Nov 21, 2016 at 10:50:20PM +0100, Vlastimil Babka wrote:
> >>>> 4.9rc5 however seems to be doing better, and is still running after 18
> >>>> hours. However, I got a few page allocation failures as per below, but the
> >>>> system seems to recover.
> >>>> Vlastimil, do you want me to continue the copy on 4.9 (may take 3-5 days) 
> >>>> or is that good enough, and i should go back to 4.8.8 with that patch applied?
> >>>> https://marc.info/?l=linux-mm&m=147423605024993
> >>>
> >>> Hi, I think it's enough for 4.9 for now and I would appreciate trying
> >>> 4.8 with that patch, yeah.
> >>
> >> So the good news is that it's been running for almost 5H and so far so good.
> > 
> > And the better news is that the copy is still going strong, 4.4TB and
> > going. So 4.8.8 is fixed with that one single patch as far as I'm
> > concerned.
> > 
> > So thanks for that, looks good to me to merge.
> 
> Thanks a lot for the testing. So what do we do now about 4.8? (4.7 is
> already EOL AFAICS).
> 
> - send the patch [1] as 4.8-only stable. Greg won't like that, I expect.
>   - alternatively a simpler (againm 4.8-only) patch that just outright
> prevents OOM for 0 < order < costly, as Michal already suggested.
> - backport 10+ compaction patches to 4.8 stable
> - something else?
> 
> Michal? Linus?

Dunno. To be honest I do not like [1] because it seriously tweaks the
retry logic. 10+ compaction patches to 4.8 seems too much for a stable
tree and quite risky as well. Considering that 4.9 works just much
better, is there any strong reason to do 4.8 specific fix at all? Most
users reporting OOM regressions seemed to be ok with what 4.8 does
currently AFAIR. I hate that Marc is not falling into that category but
is it really problem for you to run with 4.9? If we have more users
seeing this regression then I would rather go with a simpler 4.8-only
"never trigger OOM for order > 0 && order < costly because that would at
least have deterministic behavior.

> 
> [1] https://marc.info/?l=linux-mm&m=147423605024993

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
