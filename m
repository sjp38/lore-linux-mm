Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4B496B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 02:57:29 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 9so9243852ykp.5
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:57:29 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id h66si6218826yka.145.2015.02.20.23.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 23:57:28 -0800 (PST)
Date: Fri, 20 Feb 2015 22:20:00 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150221032000.GC7922@thunk.org>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
 <20150220231511.GH12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150220231511.GH12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

+akpm

So I'm arriving late to this discussion since I've been in conference
mode for the past week, and I'm only now catching up on this thread.

I'll note that this whole question of whether or not file systems
should use GFP_NOFAIL is one where the mm developers are not of one
mind.

In fact, search for the subject line "fs/reiserfs/journal.c: Remove
obsolete __GFP_NOFAIL" where we recapitulated many of these arguments,
Andrew Morton said that it was better to use GFP_NOFAIL over the
alternatives of (a) panic'ing the kernel because the file system has
no way to move forward other than leaving the file system corrupted,
or (b) looping in the file system to retry the memory allocation to
avoid the unfortunate effects of (a).

So based on akpm's sage advise and wisdom, I added back GFP_NOFAIL to
ext4/jbd2.

It sounds like 9879de7373fc is causing massive file system
errors, and it seems **really** unfortunate it was added so late in
the day (between -rc6 and rc7).

So at this point, it seems we have two choices.  We can either revert
9879de7373fc, or I can add a whole lot more GFP_FAIL flags to ext4's
memory allocations and submit them as stable bug fixes.

Linux MM developers, this is your call.  I will liberally be adding
GFP_NOFAIL to ext4 if you won't revert the commit, because that's the
only way I can fix things with minimal risk of adding additional,
potentially more serious regressions.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
