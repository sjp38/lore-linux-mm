Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9882E6B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 21:05:59 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y13so2342094wrb.17
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 18:05:59 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id y1si8949628wrg.509.2018.01.19.18.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 18:05:58 -0800 (PST)
Date: Sat, 20 Jan 2018 02:02:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180120020237.GM13338@ZenIV.linux.org.uk>
References: <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
 <20180119125503.GA2897@bombadil.infradead.org>
 <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
 <20180119221243.GL13338@ZenIV.linux.org.uk>
 <CA+55aFw4mw32Mu0_+cgKAzxCNvDW1VPcESv7CyajexfDfMju1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw4mw32Mu0_+cgKAzxCNvDW1VPcESv7CyajexfDfMju1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Fri, Jan 19, 2018 at 02:53:25PM -0800, Linus Torvalds wrote:

> It would probably be good to add the size too, just to explain why
> it's potentially expensive.
> 
> That said, apparently we do have hundreds of them, with just
> cpufreq_frequency_table having a ton. Maybe some are hidden in macros
> and removing one removes a lot.

cpufreq_table_find_index_...(), mostly.

> The real problem is that sometimes the subtraction is simply the right
> thing to do, and there's no sane way to say "yeah, this is one of
> those cases you shouldn't warn about".

FWIW, the sizes of the most common ones are
     91 sizeof struct cpufreq_frequency_table = 12
Almost all of those come from
	cpufreq_for_each_valid_entry(pos, table)
		if (....)
			return pos - table;
and I wonder if we would be better off with something like
#define cpufreq_for_each_valid_entry(pos, table, idx)                   		\
        for (pos = table, idx = 0; pos->frequency != CPUFREQ_TABLE_END; pos++, idx++)   \
                if (pos->frequency == CPUFREQ_ENTRY_INVALID)            \
                        continue;                                       \
                else
so that those loops would become
	cpufreq_for_each_valid_entry(pos, table, idx)
		if (....)
			return idx;
     36 sizeof struct Indirect = 24
     21 sizeof struct ips_scb = 216
     18 sizeof struct runlist_element = 24
     13 sizeof struct zone = 1728
Some are from
#define zone_idx(zone)          ((zone) - (zone)->zone_pgdat->node_zones)
but there's
static inline int zone_id(const struct zone *zone)
{ 
        struct pglist_data *pgdat = zone->zone_pgdat;

        return zone - pgdat->node_zones;
}
and a couple of places where we have
        for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
Those bloody well ought to be
	for (zone = node_zones, end = node_zones + MAX_NR_ZONES; zone < end; zone++) {
     13 sizeof struct vring = 40
     11 sizeof struct usbhsh_device = 24
     10 sizeof struct xpc_partition = 888
      9 sizeof struct skge_element = 40
      9 sizeof struct lock_class = 400
      9 sizeof struct hstate = 29872
That little horror comes from get_hstate_idx() and hstate_index().  Code generated
for division is
        movabsq $-5542915600080909725, %rax
        sarq    $4, %rdi
        imulq   %rdi, %rax
      7 sizeof struct nvme_rdma_queue = 312
      7 sizeof struct iso_context = 208
      6 sizeof struct i915_power_well = 48
      6 sizeof struct hpet_dev = 168
      6 sizeof struct ext4_extent = 12
      6 sizeof struct esas2r_target = 120
      5 sizeof struct iio_chan_spec = 152
      5 sizeof struct hwspinlock = 96
      4 sizeof struct myri10ge_slice_state = 704
      4 sizeof struct ext4_extent_idx = 12
Another interesting-looking one is struct vhost_net_virtqueue (18080 bytes)

Note that those sizes are rather sensitive to lockdep, spinlock debugging, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
