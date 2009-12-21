Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 115D46B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 08:48:32 -0500 (EST)
Received: by yxe10 with SMTP id 10so721083yxe.12
        for <linux-mm@kvack.org>; Mon, 21 Dec 2009 05:48:31 -0800 (PST)
Message-ID: <4B2F7C41.9020106@vflare.org>
Date: Mon, 21 Dec 2009 19:16:41 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Dan,

(I'm not sure if gmane.org interface sends mail to everyone in CC list, so
sending again. Sorry if you are getting duplicate mail).


Dan Magenheimer <dan.magenheimer <at> oracle.com> writes:

> 
> Tmem [PATCH 0/5] (Take 3): Transcendent memory
> Transcendent memory
<snip>
> 
> Normal memory is directly addressable by the kernel, of a known
> normally-fixed size, synchronously accessible, and persistent (though
> not across a reboot).
> 
> What if there was a class of memory that is of unknown and dynamically
> variable size, is addressable only indirectly by the kernel, can be
> configured either as persistent or as "ephemeral" (meaning it will be
> around for awhile, but might disappear without warning), and is still
> fast enough to be synchronously accessible?
> 

I really like the idea of allocating cache memory from hypervisor directly. This
is much more flexible than assigning fixed size memory to guests.

> 
> "Frontswap" is so named because it can be thought of as the opposite of
> a "backing store". Frontswap IS persistent, but for various reasons may not
> always be available for use, again due to factors that may not be visible to
> the kernel. (But, briefly, if the kernel is being "good" and has shared its
> resources nicely, then it will be able to use frontswap, else it will not.)
> Once a page is put, a get on the page will always succeed.  So when the
> kernel finds itself in a situation where it needs to swap out a page, it
> first attempts to use frontswap.  If the put works, a disk write and
> (usually) a disk read are avoided.  If it doesn't, the page is written
> to swap as usual.  Unlike cleancache, whether a page is stored in frontswap
> vs swap is recorded in kernel data structures, so when a page needs to
> be fetched, the kernel does a get if it is in frontswap and reads from
> swap if it is not in frontswap.
> 

I think 'frontswap' part seriously overlaps the functionality provided by
'ramzswap' which is a virtual block device driver recently added to
drivers/staging/ramzswap/. This device acts as a swap disk which compresses and
stores pages in memory itself.

To provide frontswap functionality, ramzswap needs few changes only:
instead of:
  compress --> alloc and store within guest.
do:
  compress --> send out to hypervisor (tmem_put_page).

Also, ramzswap driver supports multiple /dev/ramzswap{0,1,2...} devices. Each of
these devices can have separate backing partition/file which is used to flush
out incompressible pages or when (per-device) memory limit is exceeded.
When used on native systems, it uses custom xvmalloc allocator which is
specially designed to handle these compressed pages.

We can use all this by just a minor change in ramzswap as mentioned above.

> "Cleancache" can be thought of as a page-granularity victim cache for clean
> pages that the kernel's pageframe replacement algorithm (PFRA) would like
> to keep around, but can't since there isn't enough memory.   So when the
> PFRA "evicts" a page, it first puts it into the cleancache via a call to
> tmem.  And any time a filesystem reads a page from disk, it first attempts
> to get the page from cleancache.  If it's there, a disk access is eliminated.
> If not, the filesystem just goes to the disk like normal.  Cleancache is
> "ephemeral" so whether a page is kept in cleancache (between the "put" and
> the "get") is dependent on a number of factors that are invisible to
> the kernel.

Just an idea: as an alternate approach, we can create an 'in-memory compressed
storage' backend for FS-Cache. This way, all filesystems modified to use
fs-cache can benefit from this backend. To make it virtualization friendly like
tmem, we can again provide (per-cache?) option to allocate from hypervisor  i.e.
tmem_{put,get}_page() or use [compress]+alloc natively.

For guest<-->hypervisor interface, maybe we can use virtio so that all
hypervisors can benefit? Not quite sure about this one.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
