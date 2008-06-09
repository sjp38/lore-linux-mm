Date: Sun, 8 Jun 2008 22:44:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-Id: <20080608224404.086b15ae.akpm@linux-foundation.org>
In-Reply-To: <20080608225800.17d2e29b@bree.surriel.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
	<20080608165434.67c87e5c.akpm@linux-foundation.org>
	<20080608225800.17d2e29b@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 22:58:00 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Sun, 8 Jun 2008 16:54:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > ho hum.  Can you remind us what problems this patchset actually
> > addresses?  Preferably in order of seriousness?
> 
> Here are some other problems that my patch series can easily fix,
> because file cache and anon/swap backed pages live on separate
> LRUs:
> 
> http://feedblog.org/2007/09/29/using-o_direct-on-linux-and-innodb-to-fix-swap-insanity/
> 
> http://blogs.smugmug.com/don/2008/05/01/mysql-and-the-linux-swap-problem/

Sorry, but sending us off to look at random bug reports (from people
who didn't report a bug) is not how we discuss or changelog kernel
patches.

It is for good reasons that we like to see an accurate and detailed
analysis of the problems which are being addressed, and a description
of the means by which they were solved.


> I do not know for sure whether the patch set does fix it yet for
> everyone, or whether it needs some more tuning first, but it is
> fairly easily fixable by tweaking the relative pressure on both
> sets of LRU lists.

I expect it will help, yes.  On 64-bit systems.  It's unclear whether
mlock or SHM_LOCK is part of the issue here - if it is then 32-bit
systems will still be exposed to these things.

I also expect that it will introduce new problems, ones which can take a
very long time to diagnose and fix.  Inevitable, but hopefully acceptable,
if the benefit is there.

> No tricks of skipping over one type of pages while scanning, or
> treating the referenced bits differently when the moon is in some
> particular phase required - one set of lists for each type of
> pages, and variable pressure between the two.

For the unevictable pages we have previously considered just taking
them off the LRU and leaving them off - reattach them at
SHM_UNLOCK-time and at munlock()-time (potentially subject to
reexamination of any other vmas which map each page).

I believe that Andrea had code which leaves the anon pages off the LRU
as well, but I forget the details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
