Date: Mon, 17 Nov 2008 08:37:56 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm: evict streaming IO cache first
In-Reply-To: <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org>
 <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com> <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>


On Mon, 17 Nov 2008, Linus Torvalds wrote:
> On Mon, 17 Nov 2008, KAMEZAWA Hiroyuki wrote:
> > 
> > How about resetting zone->recent_scanned/rotated to be some value calculated from
> > INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?
> 
> .. or how about just considering the act of adding a new page to the LRU 
> to be a "scan" event? IOW, "scanning" is not necessarily just an act of 
> the VM looking for pages to free, but would be a more general "activity" 
> meter.

Another thing strikes me: it looks like the logic in "get_scan_ratio()" 
has a tendency to get unbalanced - if we end up deciding that we should 
scan a lot of anonymous pages, the scan numbers for anonymous pages will 
go up, and we get even _more_ eager to scan those. Of course, "rotate" 
events will then make us less likely again, but for streaming loads, you 
wouldn't expect to see those at all.

There seems to be another bug there wrt the "aging" - we age anon page 
events and file page events independently, which sounds like it would make 
the math totally nonsensical. We do that whole

	anon / (anon + file)

thing, but since anon and file counts are aged independently, that "math" 
is not math, it looks like a totally random number that has no meaning.

So instead of having two independent aging things, if we age one side, we 
should age the other. No?

But maybe I'm looking at it wrong. It doesn't seem sensible to me, but 
maybe there's some deeper truth in there somewhere that I'm missing..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
