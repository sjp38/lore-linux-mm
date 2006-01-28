Message-ID: <43DAC427.70801@us.ibm.com>
Date: Fri, 27 Jan 2006 17:08:55 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <20060127002331.GH10409@kvack.org> <43D96AEC.4030200@us.ibm.com> <20060127032307.GI10409@kvack.org>
In-Reply-To: <20060127032307.GI10409@kvack.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Thu, Jan 26, 2006 at 04:35:56PM -0800, Matthew Dobson wrote:
> 
>>Ummm...  ok?  But with only a simple flag, how do you know *which* mempool
>>you're trying to use?  What if you want to use a mempool for a non-slab
>>allocation?
> 
> 
> Are there any?  A quick poke around has only found a couple of places 
> that use kzalloc(), which is still quite effectively a slab allocation.  
> There seems to be just one page user, the dm-crypt driver, which could 
> be served by a reservation scheme.

A couple.  If Andrew is willing to pick up the mempool patches I posted an
hour or so ago, there will be only 4 mempool users that aren't using a
common mempool allocator.  Regardless of whether that happens, there are
only a few users that aren't slab based:
   1) mm/highmem.c - page based allocator
   2) drivers/scsi/scsi_transport_iscsi.c - calls alloc_skb(), which does
      eventually end up making a slab allocation
   3) drivers/md/raid1.c & raid10.c - easily the biggest mempool_alloc
      functions in the kernel.  Non-trivial.
   4) drivers/md/dm-crypt.c - the driver you mentioned, also using a page
      allocator

So we could possibly get away with a reservation scheme, but a couple users
would be non-trivial to fixup.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
