Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70F356B0299
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:07:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 8so14483625pfv.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:07:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si11031708pld.460.2017.12.19.05.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 05:07:04 -0800 (PST)
Date: Tue, 19 Dec 2017 05:07:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171219130703.GC13680@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
 <20171219095927.GF2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219095927.GF2787@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 10:59:27AM +0100, Michal Hocko wrote:
> On Sat 16-12-17 08:44:24, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Be really explicit about what bits / bytes are reserved for users that
> > want to store extra information about the pages they allocate.
> > 
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I think that struct page would benefit from more documentation. But this
> looks good to me already. Hugetlb pages abuse some fields in page[1],
> page_is_pfmemalloc is abusing index and there are probably more. It
> would be great to have all those described at the single place. I will
> update hugetlb part along with my recent patches which are in RFC right
> now. Maybe a good project for somebody who wants to learn a lot about MM
> and interaction with other subsystems (or maybe not ;))
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!  Completely agree that what I have written here so far reflects
my own limited understanding of the MM.  Kirill's been really patient
with teaching me some of the things I didn't know, so it seems only fair
to write down what I do know so it doesn't have to be explained to the
next eager developer who isn't steeped in the mythos of the MM system.

I'm also teaching myself more about ReStructuredText, and to that end I've
started to document all these pages side-by-side in a table.  Here's what
I have so far (and I know it's incomplete):

+---+-----------+-----------+--------------+----------+--------+--------------+
| B | slab      | pagecache | tail 1       | anon     | tail 2 | hugetlb      |
+===+===========+===========+==============+==========+========+==============+
| 0 | flags                                                                   |
+---+                                                                         |
| 4 |                                                                         |
+---+-----------+-----------+--------------+----------+--------+--------------+
| 8 | s_mem     | mapping   | cmp_mapcount | anon_vma | defer  | mapping      |
+---+           |           +--------------+          | list   |              |
|12 |           |           |              |          |        |              |
+---+-----------+-----------+--------------+----------+        +--------------+
|16 | freelist  | index                               |        | index        |
+---+           |                                     |        | (shifted)    |
|20 |           |                                     |        |              |
+---+-----------+-------------------------------------+--------+--------------+
|24 | counters  | mapcount                                                    |
+---+           +-----------+--------------+----------+--------+--------------+
|28 |           | refcount  |              |          |        | refcount     |
+---+-----------+-----------+--------------+----------+--------+--------------+
|32 | next      | lru       | cmpd_head    |                                  |
+---+           |           |              +----------------------------------+
|36 |           |           |              |                                  |
+---+-----------+           +--------------+----------------------------------+
|40 | pages     |           | dtor / order |                                  |
+---+-----------+           +--------------+----------------------------------+
|44 | pobjects  |           |              |                                  |
+---+-----------+-----------+--------------+----------------------------------+
|48 | slb_cache | private   |              |                                  |
+---+           |           +--------------+----------------------------------+
|52 |           |           |              |                                  |
+---+-----------+-----------+--------------+----------------------------------+

Obviously it's simplified -- no mention of slub's use of rcu_head; no
column for page table allocations; I left off the mem_cgroup, virtual
and last_cpupid possibilities (intentionally); I don't know much about
anonymous pages yet; no mention of KSM pages; hugetlb is still mostly
a mystery to me.

I haven't even run it through an RST parser yet to see if this is a good
table ;-)

Once it is good, then I'll duplicate it for 32-bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
