Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id DD78E6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:21:49 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id v15so1531703bkz.36
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:21:49 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id pd9si4594794bkb.0.2014.01.24.14.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 14:21:48 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id cm18so4562682qab.40
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:21:47 -0800 (PST)
Date: Fri, 24 Jan 2014 17:21:44 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty
 cache
Message-ID: <20140124222144.GA3197@htj.dyndns.org>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Jan 24, 2014 at 05:03:02PM -0500, Johannes Weiner wrote:
> These two patches fix the dirtyable memory calculation to acknowledge
> the fact that the VM does not really replace anon with dirty cache.
> As such, anon memory can no longer be considered "dirtyable."
> 
> Longer term we probably want to look into reducing some of the bias
> towards cache.  The problematic workload in particular was not even
> using any of the anon pages, one swap burst could have resolved it.

For both patches,

 Tested-by: Tejun Heo <tj@kernel.org>

I don't have much idea what's going on here, but the problem was
pretty ridiculous.  It's a 8gig machine w/ one ssd and 10k rpm
harddrive and I could reliably reproduce constant stuttering every
several seconds for as long as buffered IO was going on on the hard
drive either with tmpfs occupying somewhere above 4gig or a test
program which allocates about the same amount of anon memory.
Although swap usage was zero, turning off swap also made the problem
go away too.

The trigger conditions seem quite plausible - high anon memory usage
w/ heavy buffered IO and swap configured - and it's highly likely that
this is happening in the wild too.  (this can happen with copying
large files to usb sticks too, right?)

So, if this is the right fix && can be determined not to cause
noticeable regressions, it probably is worthwhile to cc -stable.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
