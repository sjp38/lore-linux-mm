Message-ID: <4921A1AF.1070909@redhat.com>
Date: Mon, 17 Nov 2008 11:54:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: evict streaming IO cache first
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org> <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com> <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org> <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

> Another thing strikes me: it looks like the logic in "get_scan_ratio()" 
> has a tendency to get unbalanced - if we end up deciding that we should 
> scan a lot of anonymous pages, the scan numbers for anonymous pages will 
> go up, and we get even _more_ eager to scan those. Of course, "rotate" 
> events will then make us less likely again, but for streaming loads, you 
> wouldn't expect to see those at all.

True for streaming loads - if we scan the file list and find
mostly pages from streaming loads, we will become more eager
to scan the file list.

I do not expect streaming loads to ever hit the anon list in
the same way, because anonymous pages start out referenced and
on the active list, which means an anonymous deactivation will
always be counted as a rotate event.

> There seems to be another bug there wrt the "aging" - we age anon page 
> events and file page events independently, which sounds like it would make 
> the math totally nonsensical. We do that whole
> 
> 	anon / (anon + file)

That's an outdated comment.  Andrew had a patch to update that
comment, but it must have gotten lost somewhere.  I'll send you
a patch to update it.

If you look at the actual calculation, you'l see that the
scan percentages are keyed off just swappiness and the
rotated/scanned ratios for each page category.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
