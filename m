Date: Tue, 07 Aug 2001 14:40:19 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Message-ID: <359550000.997209619@tiny>
In-Reply-To: <0108072013590B.02365@starship>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tuesday, August 07, 2001 08:13:59 PM +0200 Daniel Phillips
<phillips@bonn-fries.net> wrote:

> On Tuesday 07 August 2001 19:26, Chris Mason wrote:
>> On Tuesday, August 07, 2001 10:04:05 AM -0700 Linus Torvalds
>> 
>> <torvalds@transmeta.com> wrote:
>> > On Tue, 7 Aug 2001, Linus Torvalds wrote:
>> >> Sorry, I should have warned people: pre5 is a test-release that was
>> >> intended solely for Leonard Zubkoff who has been helping with
>> >> trying to debug a FS livelock condition.
>> > 
>> > So I _think_ that what happens is:
>> >  - alloc_pages() itself isn't making any progress, because it's
>> > called with GFP_NOFS and thus cannot touch a lot of the pages.
>> >  - we wake up kswapd to try to help, but kswapd doesn't do anything
>> >    because it thinks things are fine.
>> 
>> Which filesystem?  If its one of the journaled ones, other processes
>> might be waiting on the log trying to flush things out.
> 
> xfs.

Well, then my guess is this:

bunch of processes waiting on ram, doing a GFP_NOFS allocation, effectively
spinning through various lists.

bdflush acting normally, has written everything but the pinned buffers.

kswapd deadlocked somewhere in xfs, either trying to write a dirty inode or
a dirty page.

kswapd can't get out of the FS until one of the GFP_NOFS allocation
succeeds due to some FS lock. 

Linus seemed pretty sure kswapd wasn't deadlocked, but though I would
mention this anyway....

-chris





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
