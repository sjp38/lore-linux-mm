Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4FD6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 16:46:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so52220948pgd.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 13:46:11 -0800 (PST)
Received: from peace.netnation.com (peace.netnation.com. [204.174.223.2])
        by mx.google.com with ESMTPS id v18si30235027pfa.137.2016.11.22.13.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Nov 2016 13:46:10 -0800 (PST)
Date: Tue, 22 Nov 2016 13:46:07 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161122214607.GA11962@hostway.ca>
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
Cc: Marc MERLIN <marc@merlins.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 22, 2016 at 05:14:02PM +0100, Vlastimil Babka wrote:

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
> 
> [1] https://marc.info/?l=linux-mm&m=147423605024993

Sorry for my molasses rate of feedback. I found a workaround, setting
vm/watermark_scale_factor to 500, and threw that in sysctl. This was on
the MythTV box that OOMs everything after about a day on 4.8 otherwise.

I've been running [1] for 9 days on it (4.8.4 + [1]) without issue, but
just realized I forgot to remove the watermark_scale_factor workaround.
I've restored that now, so I'll see if it becomes unhappy by tomorrow.

I also threw up a few other things you had asked for (vmstat, zoneinfo
before and after the first OOM on 4.8.4): http://0x.ca/sim/ref/4.8.4/
(that was before booting into a rebuild with [1] applied)

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
