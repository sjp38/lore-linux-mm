Date: Sun, 20 Nov 2005 23:04:57 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
Message-ID: <20051120230456.GE2556@spitz.ucw.cz>
References: <437E2C69.4000708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri 18-11-05 11:32:57, Matthew Dobson wrote:
> We have a clustering product that needs to be able to guarantee that the
> networking system won't stop functioning in the case of OOM/low memory
> condition.  The current mempool system is inadequate because to keep the
> whole networking stack functioning, we need more than 1 or 2 slab caches to
> be guaranteed.  We need to guarantee that any request made with a specific
> flag will succeed, assuming of course that you've made your "critical page
> pool" big enough.
> 
> The following patch series implements such a critical page pool.  It
> creates 2 userspace triggers:
> 
> /proc/sys/vm/critical_pages: write the number of pages you want to reserve
> for the critical pool into this file
> 
> /proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
> the system is in an emergency state and authorize the kernel to dip into
> the critical pool to satisfy critical allocations.
> 
> We mark critical allocations with the __GFP_CRITICAL flag, and when the
> system is in an emergency state, we are allowed to delve into this pool to
> satisfy __GFP_CRITICAL allocations that cannot be satisfied through the
> normal means.

Ugh, relying on userspace to tell you that you need to dip into emergency
pool seems to be racy and unreliable. How can you guarantee that userspace
is scheduled soon enough in case of OOM?
							Pavel
-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
