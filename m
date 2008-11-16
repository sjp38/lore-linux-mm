Message-ID: <49208E9A.5080801@redhat.com>
Date: Sun, 16 Nov 2008 16:20:26 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: evict streaming IO cache first
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115210039.537f59f5.akpm@linux-foundation.org> <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> On Sat, 15 Nov 2008, Andrew Morton wrote:
>> Really, I think that the old approach of observing the scanner
>> behaviour (rather than trying to predict it) was better.
> 
> That's generally true. Self-adjusting behaviour rather than a-priori rules 
> would be much nicer. However, we apparently need to fix this some way. 
> Anybody willing to re-introduce some of the old logic?

The old behaviour has big problems, especially on large memory
systems.  If the old behaviour worked right, we would not have
been working on the split LRU code for the last year and a half.

Due to programs manipulating memory many pages at a time, the
LRU ends up getting mapped and cache pages on the list in bunches.

On large memory systems, after the scanner runs into a bunch
of mapped pages, it will switch to evicting mapped pages, even
if the next bunch of pages turns out to be cache pages.

I am not convinced that "reacting to what happened in the last
1/4096th of the LRU" is any better than "look at the list stats
and decide what to do".

Andrew's objection to how things behave on small memory systems
(the patch does not change anything) is valid, but going back
to the old behaviour does not seem like an option to me, either.

I will take a look at producing smoother self tuning behaviour
in get_scan_ratio(), with logic along these lines:
- the more file pages are inactive, the more eviction should
   focus on file pages, because we are not eating away at the
   working set yet
- the more file pages are active, the more there needs to be
   a balance between file and anon scanning, because we are
   starting to get to the working sets for both

I wonder if the "do not do mark_page_accessed at page fault time"
patch is triggering the current troublesome behaviour in the VM,
because actively used file pages are not moved out of the way of
the VM - which leads get_scan_ratio to believe that we are already
hitting the working set on the file side and should also start
scanning the anon LRUs.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
