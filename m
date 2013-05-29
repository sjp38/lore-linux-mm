Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id EDA056B0068
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:53:58 -0400 (EDT)
Date: Wed, 29 May 2013 12:53:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: vmscan: Take page buffers dirty and locked
 state into account
Message-Id: <20130529125356.5018cb1ba28959664be67791@linux-foundation.org>
In-Reply-To: <1369659778-6772-5-git-send-email-mgorman@suse.de>
References: <1369659778-6772-1-git-send-email-mgorman@suse.de>
	<1369659778-6772-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 27 May 2013 14:02:58 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Page reclaim keeps track of dirty and under writeback pages and uses it to
> determine if wait_iff_congested() should stall or if kswapd should begin
> writing back pages. This fails to account for buffer pages that can be under
> writeback but not PageWriteback which is the case for filesystems like ext3
> ordered mode. Furthermore, PageDirty buffer pages can have all the buffers
> clean and writepage does no IO so it should not be accounted as congested.

iirc, the PageDirty-all-buffers-clean state is pretty rare.  It might
not be worth bothering about?

> This patch adds an address_space operation that filesystems may
> optionally use to check if a page is really dirty or really under
> writeback.

address_space_operations methods are Documented in
Documentation/filesystems/vfs.txt ;)

> An implementation is provided for for buffer_heads is added
> and used for block operations and ext3 in ordered mode. By default the
> page flags are obeyed.
> 
> Credit goes to Jan Kara for identifying that the page flags alone are
> not sufficient for ext3 and sanity checking a number of ideas on how
> the problem could be addressed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
