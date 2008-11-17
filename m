Message-ID: <49219B61.2080800@redhat.com>
Date: Mon, 17 Nov 2008 11:27:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: evict streaming IO cache first
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org> <49208E9A.5080801@redhat.com> <20081116204720.1b8cbe18.akpm@linux-foundation.org> <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com> <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 17 Nov 2008, KAMEZAWA Hiroyuki wrote:
>> How about resetting zone->recent_scanned/rotated to be some value calculated from
>> INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?
> 
> .. or how about just considering the act of adding a new page to the LRU 
> to be a "scan" event? IOW, "scanning" is not necessarily just an act of 
> the VM looking for pages to free, but would be a more general "activity" 
> meter.

That might work.

Adding a new page to the inactive file list would increment
zone->recent_scanned[file].

Adding a new anonymous page to the active anon list could
increment both zone->recent_scanned[anon] and
zone->recent_rotated[anon].

That way adding anonymous memory would move some pressure
to the file side, while doing lots of streaming IO would
result in the same.

> That would seem to be the right kind of thing to do: if we literally have 
> a load that only does streaming and pages never get moved to the active 
> LRU, it should basically keep the page cache close to constant size - 
> which is just another way of saying that we should only be scanning page 
> cache pages.

The only thing left at that point is the fact that the
streaming IO puts pressure on the working set in the
page cache, by always decreasing the active file list
too.  But that's a different thing entirely and can be
looked at later :)

Your idea looks like it should work.  I'll whip up a patch
for Gene Heskett.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
