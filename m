Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEBBA6B0007
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 09:42:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e143so4354798wma.2
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 06:42:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si5589020wra.67.2018.02.19.06.42.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 06:42:19 -0800 (PST)
Date: Mon, 19 Feb 2018 15:42:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Message-ID: <20180219144216.GP21134@dhcp22.suse.cz>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon 19-02-18 10:19:35, Mel Gorman wrote:
[...]
> Access to the pool is unprotected so you might create a reserve for jumbo
> frames only to have them consumed by something else entirely. It's not
> clear if that is even fixable as GFP flags are too coarse.
> 
> It is not covered in the changelog why MIGRATE_HIGHATOMIC was not
> sufficient for jumbo frames which are generally expected to be allocated
> from atomic context. If there is a problem there then maybe
> MIGRATE_HIGHATOMIC should be made more strict instead of a hack like
> this. It'll be very difficult, if not impossible, for this to be tuned
> properly.
> 
> Finally, while I accept that fragmentation over time is a problem for
> unmovable allocations (fragmentation protection was originally designed
> for THP/hugetlbfs), this is papering over the problem. If greater
> protections are needed then the right approach is to be more strict about
> fallbacks. Specifically, unmovable allocations should migrate all movable
> pages out of migrate_unmovable pageblocks before falling back and that
> can be controlled by policy due to the overhead of migration. For atomic
> allocations, allow fallback but use kcompact or a workqueue to migrate
> movable pages out of migrate_unmovable pageblocks to limit fallbacks in
> the future.

Completely agreed!

> I'm not a fan of this patch.

Yes, I think the approach is just wrong. It will just hit all sorts of
weird corner cases and won't work reliable for those who care.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
