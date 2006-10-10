Subject: Re: 2.6.19-rc1-mm1
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20061010004526.c7088e79.akpm@osdl.org>
References: <20061010000928.9d2d519a.akpm@osdl.org>
	 <1160464800.3000.264.camel@laptopd505.fenrus.org>
	 <20061010004526.c7088e79.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 10:03:21 +0200
Message-Id: <1160467401.3000.276.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 00:45 -0700, Andrew Morton wrote:

> > if it's ok to ignore RSS,
> 
> We'd prefer not to.  But what's the alternative?

it's a good question; today (2.6.18) we have some defacto behavior of
RSS; 2.6.19-rc1-mm1 has a somewhat different one. Either can be entirely
valid; and we can obviously implement either. We can go even further and
remove more from RSS to help save memory and pagefaults (both help
desktop performance) by going the shared pagetable road
> 
> > can we consider the shared pagetables for
> > normal pages patch?
> 
> Has been repeatedly considered, but Hugh keeps finding bugs in it.

the latest one I tried looked relatively simple (earlier ones were very
complex) so maybe Hugh can find time to give it another lookover?

> 
> > It saves quite a bit of memory on even desktop
> > workloads as well as avoiding several (soft) pagefaults.
> > 
> > So.. what does RSS actually mean? Can we ignore it somewhat for
> > shared-readonly mappings ? 
> 
> We'd prefer to go the other way, and implement RLIMIT_RSS wouldn't we?

Well... that again depends on how we define RSS. implementing the rlimit
doesn't mean we can't NOT count certain things (like the hugetlb pages
in the patch above, or shared read only pagecache pages) to be part of
it. It's a fundamental "what does it mean" thing.
You can argue that RSS means "all memory that the application has in
it's address space", you can argue "all such memory except a few cases",
you can argue "all memory that is private/exclusive to the
application"... 
This is not a pointless piss-in-the-wind discussion; unless we define
rather specific what it really means, the RLIMIT doesn't mean anything
either.

We need to consider at least if any of the following are part of rss:
* VM_IO io mmaped device stuff 
* Non-linear mappings
* Shared hugetlb memory that shares pagetables
* Shared hugetlb memory
* Hugetlb memory in general
* Shared normal memory that shares pagetables
* Shared normal memory (file backed; eg pagecache)
* Shared normal memory (anonymous/non-file-backed)
* Sysv/ipc shared memory
* Not shared normal memory

I don't think posix or anything else helps us here so we can vote or
otherwise reason which make sense and which don't. I hope the outcome is
reasonably consistent ;)

I know the desktop guys at least consider RSS useless as measure of "how
much memory does my desktop app take"; especially since they have many
shared libraries and they consider it unfair that each app pays the full
price in terms of RSS for those. So personally I'm not unhappy with a
definition that comes down to "all memory that's private to the app";
although it is a change from what 2.6.18 does.



-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
