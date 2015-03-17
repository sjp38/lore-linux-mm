Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0C86B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 05:07:42 -0400 (EDT)
Received: by weop45 with SMTP id p45so2583525weo.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 02:07:42 -0700 (PDT)
Received: from mail-we0-x229.google.com (mail-we0-x229.google.com. [2a00:1450:400c:c03::229])
        by mx.google.com with ESMTPS id ll20si2044524wic.111.2015.03.17.02.07.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 02:07:41 -0700 (PDT)
Received: by webcq43 with SMTP id cq43so2542818web.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 02:07:40 -0700 (PDT)
Date: Tue, 17 Mar 2015 10:07:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/2] Move away from non-failing small allocations
Message-ID: <20150317090738.GB28112@dhcp22.suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <20150316153843.af945a9e452404c22c4db999@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150316153843.af945a9e452404c22c4db999@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon 16-03-15 15:38:43, Andrew Morton wrote:
> On Wed, 11 Mar 2015 16:54:52 -0400 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > as per discussion at LSF/MM summit few days back it seems there is a
> > general agreement on moving away from "small allocations do not fail"
> > concept.
> 
> Such a change affects basically every part of the kernel and every
> kernel developer.  I expect most developers will say "it works well
> enough and I'm not getting any bug reports so why should I spend time
> on this?".  It would help if we were to explain the justification very
> clearly.  https://lwn.net/Articles/636017/ is Jon's writeup of the
> conference discussion.

OK, I thought that the description in the patch 1/2 was clear about the
motivation. I can try harder of course. Which part do you miss there? Or
was it the cover that wasn't specific enough?
 
> Realistically, I don't think this overall effort will be successful -
> we'll add the knob, it won't get enough testing and any attempt to
> alter the default will be us deliberately destabilizing the kernel
> without knowing how badly :(

Without the knob we do not allow users to test this at all though and
the transition will _never_ happen. Which is IMHO bad.
 
> I wonder if we can alter the behaviour only for filesystem code, so we
> constrain the new behaviour just to that code where we're having
> problems.  Most/all fs code goes via vfs methods so there's a reasonably
> small set of places where we can call

We are seeing issues with the fs code now because the test cases which
led to the current discussion exercise FS code. The code which does
lock(); kmalloc(GFP_KERNEL) is not reduced there though. I am pretty sure
we can find other subsystems if we try hard enough.

> static inline void enter_fs_code(struct super_block *sb)
> {
> 	if (sb->my_small_allocations_can_fail)
> 		current->small_allocations_can_fail++;
> }
> 
> that way (or something similar) we can select the behaviour on a per-fs
> basis and the rest of the kernel remains unaffected.  Other subsystems
> can opt in as well.

This is basically leading to GFP_MAYFAIL which is completely backwards
(the hard requirement should be an exception not a default rule).
I really do not want to end up with stuffing random may_fail annotations
all over the kernel.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
