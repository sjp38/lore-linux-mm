Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10C7E6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 03:15:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so10105825wmz.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 00:15:21 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id fo18si1246203wjc.226.2016.09.16.00.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 00:15:19 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id l132so21226485wmf.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 00:15:19 -0700 (PDT)
Date: Fri, 16 Sep 2016 09:15:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/4] mm, oom: get rid of TIF_MEMDIE
Message-ID: <20160916071517.GA29534@dhcp22.suse.cz>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <20160915144118.GB25519@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915144118.GB25519@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>

On Thu 15-09-16 10:41:18, Johannes Weiner wrote:
> Hi Michal,
> 
> On Thu, Sep 01, 2016 at 11:51:00AM +0200, Michal Hocko wrote:
> > Hi,
> > this is an early RFC to see whether the approach I've taken is acceptable.
> > The series is on top of the current mmotm tree (2016-08-31-16-06). I didn't
> > get to test it so it might be completely broken.
> > 
> > The primary point of this series is to get rid of TIF_MEMDIE finally.
> > Recent changes in the oom proper allows for that finally, I believe. Now
> > that all the oom victims are reapable we are no longer depending on
> > ALLOC_NO_WATERMARKS because the memory held by the victim is reclaimed
> > asynchronously. A partial access to memory reserves should be sufficient
> > just to guarantee that the oom victim is not starved due to other
> > memory consumers. This also means that we do not have to pretend to be
> > conservative and give access to memory reserves only to one thread from
> > the process at the time. This is patch 1.
> >
> > Patch 2 is a simple cleanup which turns TIF_MEMDIE users to tsk_is_oom_victim
> > which is process rather than thread centric. None of those callers really
> > requires to be thread aware AFAICS.
> > 
> > The tricky part then is exit_oom_victim vs. oom_killer_disable because
> > TIF_MEMDIE acted as a token there so we had a way to count threads from
> > the process. It didn't work 100% reliably and had it own issues but we
> > have to replace it with something which doesn't rely on counting threads
> > but rather find a moment when all threads have reached steady state in
> > do_exit. This is what patch 3 does and I would really appreciate if Oleg
> > could double check my thinking there. I am also CCing Al on that one
> > because I am moving exit_io_context up in do_exit right before exit_notify.
> 
> You're explaining the mechanical thing you are doing, but I'm having
> trouble understanding why you want to get rid of TIF_MEMDIE. For one,
> it's more code. And apparently, it's also more complicated than what
> we have right now.
> 
> Can you please explain in the cover letter what's broken/undesirable?

Sure, I will extend the cover when submitting the series again. This RFC
was mostly aimed at correctness so I focused more on technical details.
Patch 1 should contain some reasoning. Do you find it sufficient or I
should extend on top of that?

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
