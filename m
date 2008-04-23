Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NIhchT007225
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:43:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NIhcuN250200
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:43:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NIhSBq026515
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:43:28 -0400
Date: Wed, 23 Apr 2008 11:43:17 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB
	hugetlb for x86
Message-ID: <20080423184317.GC10548@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480EEDD9.2010601@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [10:05:45 +0200], Andi Kleen wrote:
> 
> > Testing-wise, I've changed the registration mechanism so that if you
> > specify hugepagesz=1G on the command line, then you do not get the
> > 2M pages by default (you have to also specify hugepagesz=2M). Also,
> > when only one hstate is registered, all the proc outputs appear
> > unchanged, so this makes it very easy to test with.
> 
> Are you sure that's a good idea? Just replacing the 2M count in
> meminfo with 1G pages is not fully compatible proc ABI wise I think.

If this is the case, then providing hugepagesz at all seems absurd on
x86_64?

That is, hugepagesz = 1G implies hugepagesz = 2M must also be specified?
If you're going to require that, then why not just have hugepages= with
a strict ordering? e.g., hugepages=10, is 10 2M pages; hugepages=10,2 is
10 2M pages and 2 1G pages. Well, I guess you're future-proofing against
adding another hugepage size in-between. If we're going to require this,
I hope the patchset has huge printk()s that functionality is being
disabled because the command-line was not spat out the right way.

And I'm not sure I buy the ABI argument? That implies that you can't
have differing hugepage sizes period, between boots, which we clearly
can on IA64, power, etc. Applications should be examining meminfo as is
for the underlying hugepagesize. Any app that hard-coded the size was
going to break eventually and was completely non-portable.

> I think rather that applications who only know about 2M pages should
> see "0" in this case and not be confused by larger pages. And only
> applications who are multi page size aware should see the new page
> sizes.

Applications could be using libhugetlbfs and not need to know about the
pages in particular (we also export a gethugepagesize() call, which will
need adjustment for multiple fields in /proc/meminfo -- something like
gethugepagesizes(), I guess, where gethugepagesize() returns the default
hugepages size, which should always be the first listed in
/proc/meminfo).

> If you prefer it you could move all the new page sizes to sysfs
> and only ever display the "legacy page size" in meminfo,
> but frankly I personally prefer the quite simple and comparatively
> efficient /proc/meminfo with multiple numbers interface.

Well, some things should be moved to sysfs, I'd say. I'm working on it
as we speak.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
