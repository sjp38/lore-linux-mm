Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7881D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:23:56 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so74074940wgd.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:23:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t4si2061wix.72.2015.03.26.11.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 11:23:55 -0700 (PDT)
Date: Thu, 26 Mar 2015 14:23:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress
 before retrying
Message-ID: <20150326182352.GB16898@phnom.home.cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-9-git-send-email-hannes@cmpxchg.org>
 <20150326155846.GQ15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326155846.GQ15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu, Mar 26, 2015 at 04:58:46PM +0100, Michal Hocko wrote:
> On Wed 25-03-15 02:17:12, Johannes Weiner wrote:
> > There is not much point in rushing back to the freelists and burning
> > CPU cycles in direct reclaim when somebody else is in the process of
> > OOM killing, or right after issuing a kill ourselves, because it could
> > take some time for the OOM victim to release memory.
> 
> Yes this makes sense and it is better than what we have now. The
> question is how long we should wait. I can see you have gone with HZ.
> What is the value based on? Have your testing shown that the OOM victim
> manages to die within a second most of the time?
> 
> I do not want to get into which value is the best discussion but I would
> expect a larger value. Most OOM victims are not blocked so they would
> wake up soon. This is a safety net for those who are blocked and I do
> not think we have to expedite those rare cases and rather optimize for
> "regular" OOM situations. How about 10-30s?

Yup, I agree with that reasoning.  We can certainly go higher than HZ.

However, we should probably try to stay within the thresholds of any
lock/hang detection watchdogs, which on a higher level includes the
user itself, who might get confused if the machine hangs for 30s.

As I replied to Vlastimil, once the OOM victim hangs for several
seconds without a deadlock, failing the allocation wouldn't seem
entirely unreasonable, either.

But yes, something like 5-10s would still sound good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
