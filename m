Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
References: <393E8AEF.7A782FE4@reiser.to>
	<Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>
	<20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica>
	<20000607222421.H30951@redhat.com> <yttvgzlcgps.fsf@serpe.mitica>
	<20000607224908.K30951@redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 22:49:08 +0100"
Date: 08 Jun 2000 00:00:06 +0200
Message-ID: <yttk8g1cftl.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "sct" == Stephen C Tweedie <sct@redhat.com> writes:

sct> Hi,
sct> On Wed, Jun 07, 2000 at 11:40:47PM +0200, Juan J. Quintela wrote:
>> Hi
>> Fair enough, don't put pinned pages in the LRU, *why* do you want put
>> pages in the LRU if you can't freed it when the LRU told it: free that
>> page?

sct> Because even if the information about which page is least recently
sct> used doesn't help you, the information about which filesystems are
sct> least active _does_ help.

ok, I see what is your point here.

>> Ok. New example.  You have the 10 (put here any number) older
>> pages in the LRU.  That pages are pinned in memory, i.e. you can't
>> remove them.  You will call the ->flush() function in each of them
>> (put it any name for the method).  Now, the same fs has a lot of new
>> pages in the LRU that are being used actively, but are not pinned in
>> this precise instant.  Each time that we call the flush method, we
>> will free some dirty pages, not the pinned ones, evidently. We will
>> call that flush function 10 times consecutively.  Posibly we will
>> flush all the pages from the cache for that fs, and for not good
>> reason.

sct> No, Rik was explicitly allowing the per-fs flush functions to 
sct> indicate how much progress was being made, to avoid this.

That didn't avoid this, the next time that you scan that list, the
page from the same filesystem will appear, and you will flush pages
from that filesystem.  And so on.

>> I will be also very happy with only one place where doing the aging,
>> cleaning, ... of _all_ the pages, but for that place we need a policy,
>> and that policy _must_ be honored (almost) always or it doesn't make
>> sense and we will arrive to unstable/unfair situations.

sct> We _have_ to have separate mechanisms for page cleaning and for page
sct> reclaim.  Interrupt load requires that we free pages rapidly on 
sct> demand, regardless of whether the page cleaner is stalled in the 
sct> middle of a write operation or not.

I agree on that also, I have offered my help to Rik to implement
that.  That means that I also like that idea.

[Rest of the mail deleted, I also agree on that].

Thanks a lot for your comments in this topic.  I apreciate a lot the
comments of everybody.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
