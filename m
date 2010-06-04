Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2B8DF6B01AF
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:45:36 -0400 (EDT)
Received: by pwi6 with SMTP id 6so155701pwi.14
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 06:45:34 -0700 (PDT)
Date: Fri, 4 Jun 2010 22:45:24 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
Message-ID: <20100604134524.GD1879@barrios-desktop>
References: <20100528173510.GA12166%ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com>
 <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default>
 <4C07179F.5080106@vflare.org>
 <3721BEE2-DF2D-452A-8F01-E690E32C6B33@oracle.com4C074ACE.9020704@vflare.org>
 <6e97a82a-c754-493e-bbf5-58f0bb6a18b5@default>
 <4C08C931.3080306@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C08C931.3080306@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, andreas.dilger@oracle.com, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Hi, Nitin. 

I am happy to hear you started this work. 

On Fri, Jun 04, 2010 at 03:06:49PM +0530, Nitin Gupta wrote:
> On 06/03/2010 09:13 PM, Dan Magenheimer wrote:
> >> On 06/03/2010 10:23 AM, Andreas Dilger wrote:
> >>> On 2010-06-02, at 20:46, Nitin Gupta wrote:
> >>
> >>> I was thinking it would be quite clever to do compression in, say,
> >>> 64kB or 128kB chunks in a mapping (to get decent compression) and
> >>> then write these compressed chunks directly from the page cache
> >>> to disk in btrfs and/or a revived compressed ext4.
> >>
> >> Batching of pages to get good compression ratio seems doable.
> > 
> > Is there evidence that batching a set of random individual 4K
> > pages will have a significantly better compression ratio than
> > compressing the pages separately?  I certainly understand that
> > if the pages are from the same file, compression is likely to
> > be better, but pages evicted from the page cache (which is
> > the source for all cleancache_puts) are likely to be quite a
> > bit more random than that, aren't they?
> > 
> 
> 
> Batching of pages from random files may not be so effective but
> it would be interesting to collect some data for this. Still,
> per-inode batching of pages seems doable and this should help
> us get over this problem.

1)
Please, consider system memory pressure case. 
In such case, we have to release compressed cache pages. 
Or it would be better to discard not-good-compression pages 
when you compress it. 

2)
This work is related to page reclaiming.
Page reclaiming is to make free memory. 
But this work might free memory little than old. 
I admit your concept is good in terms of I/O cost. 
But we might discard more clean pages than old if you want to 
do batching of pages for good compression.

3)
testcase. 

As I mentioned, it could be good in terms of I/O cost. 
But it could change system's behavior due to page consumption of backend. 
so many page scanning/reclaiming could be happen. 
It means hot pages can be discarded with this patch.
But it's a just guessing. 
So we need number with testcase we can measure I/O and system 
responsivness. 

> 
> Thanks,
> Nitin

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
