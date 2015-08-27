Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A7FC26B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:28:57 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so32419500pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:28:57 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ks7si4847841pab.99.2015.08.27.10.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 10:28:56 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so14502603pac.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:28:56 -0700 (PDT)
Date: Thu, 27 Aug 2015 10:28:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
In-Reply-To: <20150827160355.GI27052@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1508271004200.2999@eggly.anvils>
References: <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org> <20150821121028.GB12016@node.dhcp.inet.fi> <55DC550D.5060501@suse.cz> <20150825183354.GC4881@node.dhcp.inet.fi> <20150825201113.GK11078@linux.vnet.ibm.com> <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com> <alpine.LSU.2.11.1508261104000.1975@eggly.anvils> <20150826212916.GG11078@linux.vnet.ibm.com> <20150827150917.GF27052@dhcp22.suse.cz> <20150827160355.GI27052@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu, 27 Aug 2015, Michal Hocko wrote:
> On Thu 27-08-15 17:09:17, Michal Hocko wrote:
> [...]
> > Btw. Do we need the same think for page::mapping and KSM?
> 
> I guess we are safe here because the address for mappings comes from
> kmalloc and that aligned properly, right?

Not quite right, in fact.  Because usually the struct address_space
is embedded within the struct inode (at i_data), and the struct inode
embedded within the fs-dependent inode, and that's what's kmalloc'ed.

What makes the mapping pointer low bits safe is include/linux/fs.h:
struct address_space {
	...
} __attribute__((aligned(sizeof(long))));

Which we first had to add in for the cris architecture, which stumbled
not on a genuine allocated address_space, but on that funny statically
declared swapper_space in mm/swap_state.c.

But struct anon_vma and KSM's struct stable_node (which depend on
the same scheme for low bits of page->mapping) have no such alignment
attribute specified: those ones are indeed relying on the kmalloc
guarantee as you suppose.

Does struct rcu_head have no __attribute__((aligned(whatever)))?
Perhaps that attribute should be added when it's needed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
