Date: Wed, 23 Apr 2008 17:53:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Message-ID: <20080423155338.GF16769@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423154652.GB29087@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 05:46:52PM +0200, Andi Kleen wrote:
> On Wed, Apr 23, 2008 at 05:34:04PM +0200, Nick Piggin wrote:
> > On Wed, Apr 23, 2008 at 10:05:45AM +0200, Andi Kleen wrote:
> > > 
> > > > Testing-wise, I've changed the registration mechanism so that if you specify
> > > > hugepagesz=1G on the command line, then you do not get the 2M pages by default
> > > > (you have to also specify hugepagesz=2M). Also, when only one hstate is
> > > > registered, all the proc outputs appear unchanged, so this makes it very easy
> > > > to test with.
> > > 
> > > Are you sure that's a good idea? Just replacing the 2M count in meminfo
> > > with 1G pages is not fully compatible proc ABI wise I think.
> > 
> > Not sure that it is a good idea, but it did allow the test suite to pass
> > more tests ;)
> 
> Then the test suite is wrong. Really I expect programs that want
> to use 1G pages to be adapted to it.

No, it can generally determine the size of the hugepages. It would
be more wrong (but probably more common) for portable code to assume
2MB hugepages.

 
> > What the best option is for backwards compatibility, I don't know. I
> 
> The first number has to be always the "legacy" size for compatibility.   
> I don't think know why you don't know that, it really seems like an
> obvious fact to me.

Obvious? When you want your legacy userspace to use 1G pages and don't
have any 2MB pages in the machine? In that case IMO there is no question
that my way is the most likely possibility. We have a hugepagesize
field there, so the assumption would be that it gets used.

If you want your legacy userspace to have 2MB hugepages, then you would
have a 2MB hstate and see the 2MB sizes there.


> > think this approach would give things a better chance of actually
> > working with 1G hugepags and old userspace, but it probably also
> > increases the chances of funny bugs.
> 
> It's not fully compatible. And that is bad.

It is fully compatible because if you don't actually ask for any new
option then you don't get it. What you see will be exactly unchanged.
If you ask for _only_ 1G pages, then this new scheme is very likely to
work with well written applications wheras if you also print out the 2MB
legacy values first, then they have little to no chance of working.

Then if you want legacy apps to use 2MB pages, and new ones to use 1G,
then you ask for both and get the 2MB column printed in /proc/meminfo
(actually it can probably get printed 2nd if you ask for 2MB pages
after asking for 1G pages -- that is something I'll fix).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
