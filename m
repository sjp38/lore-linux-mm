Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 75C7A6B0012
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 06:04:07 -0500 (EST)
Date: Fri, 15 Feb 2013 12:04:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fadvise: Drain all pagevecs if POSIX_FADV_DONTNEED
 fails to discard all pages
Message-ID: <20130215110401.GA31037@dhcp22.suse.cz>
References: <20130214120349.GD7367@suse.de>
 <20130214123926.599fcef8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130214123926.599fcef8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rob van der Heij <rvdheij@gmail.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 14-02-13 12:39:26, Andrew Morton wrote:
> On Thu, 14 Feb 2013 12:03:49 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Rob van der Heij reported the following (paraphrased) on private mail.
> > 
> > 	The scenario is that I want to avoid backups to fill up the page
> > 	cache and purge stuff that is more likely to be used again (this is
> > 	with s390x Linux on z/VM, so I don't give it as much memory that
> > 	we don't care anymore). So I have something with LD_PRELOAD that
> > 	intercepts the close() call (from tar, in this case) and issues
> > 	a posix_fadvise() just before closing the file.
> > 
> > 	This mostly works, except for small files (less than 14 pages)
> > 	that remains in page cache after the face.
> 
> Sigh.  We've had the "my backups swamp pagecache" thing for 15 years
> and it's still happening.
> 
> It should be possible nowadays to toss your backup application into a
> container to constrain its pagecache usage.  So we can type
> 
> 	run-in-a-memcg -m 200MB /my/backup/program
> 
> and voila.  Does such a script exist and work?

The script would be as simple as:
cgcreate -g memory:backups/`whoami`
cgset -r memory.limit_in_bytes=200MB backups/`whoami`
cgexec -g memory:backups/`whoami` /my/backup/program

It just expects that admin sets up backups group which allows the user
to create a subgroup (w permission on the directory) and probably set up
some reasonable cap for all backups
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
