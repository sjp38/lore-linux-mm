Date: Mon, 9 Sep 2002 16:40:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] modified segq for 2.5
Message-ID: <20020909234044.GJ18800@holomorphy.com>
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <E17oXIx-0006vb-00@starship> <3D7D277E.7E179FA0@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D7D277E.7E179FA0@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Daniel Phillips <phillips@arcor.de>, Rik van Riel <riel@conectiva.com.br>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2002 at 03:58:06PM -0700, Andrew Morton wrote:
> This logic is too global at present.  It really needs to be per-zone,
> to fix an oom problem which you-know-who managed to trigger.  All
> ZONE_NORMAL is dirty, we keep on getting woken up by IO completion in
> ZONE_HIGHMEM, we end up scanning enough ZONE_NORMAL pages to conclude
> that we're oom.  (Plus I reduced the maximum-scan-before-oom by 2.5x)
> Then again, Bill had twiddled the dirty memory thresholds
> to permit 12G of dirty ZONE_HIGHMEM.

This seemed to work fine when I just tweaked problem areas to use
__GFP_NOKILL. mempool was fixed by the __GFP_FS checks, but
generic_file_read(), generic_file_write(), the rest of filemap.c,
slab allocations, and allocating file descriptor tables for poll() and
select() appeared to generate OOM when it appeared to me that failing
system calls with -ENOMEM was a better alternative than shooting tasks.

After doing that, the system was able to do just fine until the disk
driver oopsed. Given the lack of forward progress on the driver front
due to basically nobody we know knowing or caring about that device
and the mempool issue triggered by bounce buffering already being fixed
I've obtained a replacement and am just chucking the isp1020 out the
window. I'm also hunting for a (non-Emulex!) FC adapter so I can get
more interesting dbench results from non-clockwork disks. =)


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
