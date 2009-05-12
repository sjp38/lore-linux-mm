Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ED6346B0099
	for <linux-mm@kvack.org>; Tue, 12 May 2009 13:06:40 -0400 (EDT)
Message-ID: <4A09AC91.4060506@redhat.com>
Date: Tue, 12 May 2009 13:06:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905121650090.14226@qirst.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> All these expiration modifications do not take into account that a desktop
> may sit idle for hours while some other things run in the background (like
> backups at night or updatedb and other maintenance things). This still
> means that the desktop will be usuable in the morning.

New file pages start on the inactive list and will get reclaimed
after one access. Only file pages that get accessed multiple times
get promoted to the active file LRU.

The patch that only allows active file pages to be deactivated
if the active file LRU is larger than the inactive file LRU should
protect the working set from being evicted due to streaming IO.

Even if the working set is currently idle.

> I have had some success with a patch that protects a pages in the file
> cache from being unmapped if the mapped pages are below a certain
> percentage of the file cache. Its another VM knob to define the percentage
> though.

That is another way of protecting mapped file pages, but it does
not have the side effect of protecting the page cache working set
on eg. file servers or mysql or postgresql installs with default
tunables (which rely heavily on the page cache to cache the right
things).

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
