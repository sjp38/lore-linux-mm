Date: Tue, 7 Aug 2001 14:40:57 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <3B7030B3.9F2E8E67@zip.com.au>
Message-ID: <Pine.LNX.4.33.0108071426380.30280-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Andrew Morton wrote:

> Ben, are you using software RAID?
>
> The throughput problems which Mike Black has been seeing with
> ext3 seem to be specific to an interaction with software RAID5
> and possibly highmem.  I've never been able to reproduce them.

Yes, but I'm using raid 0.  The ratio of highmem to normal memory is
~3.25:1, and it would seem that this is breaking write throttling somehow.
The interaction between vm and io throttling is not at all predictable.
Certainly, pulling highmem out of the equation results in writes
proceeding at the speed of the disk, which makes me wonder if the bounce
buffer allocation is triggering the vm code to attempt to free more
memory.... Ah, and that would explain why shorter io queues makes things
smoother: less memory pressure is occuring on the normal memory zone from
bounce buffers.  The original state of things was allowing several hundred
MB of ram to be allocated for bounce buffers, which lead to a continuous
shortage, causing kswapd et al to spin in a loop making no progress.

Hmmm, how to make kswapd/bdflush/kreclaimd all back off until progress is
made in cleaning the io queue?

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
