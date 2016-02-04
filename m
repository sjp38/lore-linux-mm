Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 441006B0299
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 13:09:24 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so16630892wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 10:09:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk7si19165838wjb.34.2016.02.04.10.09.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 10:09:23 -0800 (PST)
Date: Thu, 4 Feb 2016 19:09:06 +0100
From: David Sterba <dsterba@suse.cz>
Subject: [LSF/MM ATTEND] Btrfs, GFP flags
Message-ID: <20160204180906.GF9136@twin.jikos.cz>
Reply-To: dsterba@suse.cz
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

I'd like to attend LSF/MM this year. I'm involved in btrfs development
for 5 years and one of the maintainers since early 2015.

* Filesystems

There are topics I'd like to discuss with other btrfs developers as this
would be more interactive than the mail discussions. Hopefully this will
cover things that never make it to the mails. As an example, the direction
of the development, taming the patch flow and other maintainer pleasures.

* FS/MM

I'd like to participate in the discussions about refining the GFP flags
and memory error handling in btrfs in general. It's not a secret that
the current implementation is not robust. I've started with the low-hanging
fruit for 4.5, getting rid of GFP_NOFS in the easy cases. The core work
is still left untouched as this requires identifying all the paths/contexts
that might recurse back to the filesystem.

So far I was able to narrow down a few classes based on the expected
object lifetime and possible IO involved. Namely for the short-lived
allocations (eg. btrfs_path that's used for search & modify the metadata
in the b-tree) it's crucial in many places not to fail. Here I'm thinking
about some emergency reserves that would kick in if the slab/kmalloc
allocation fails. That would be even after a GFP_HIGH fails so it's
expected to be very rare and used at limited number of call sites. This
could be potentially made a more generic part of the allocator.

* MM, debugging helpers

During the analysis I wanted to track per call-site allocation stats (count,
size), and wrote basic version, stats exported via debugfs.

Next to that is a desire for a better fault injection framework, eg. when I
want to exercise a specific call path.  Though I can implement it myself as
needed, I assume that such extension of the existing code could be useful to
others.

(This could be considered marginal and not appropriate for the conference,
but I feel I should mention it as a followup to the previous paragraph.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
