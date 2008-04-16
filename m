Date: Wed, 16 Apr 2008 12:10:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080416121003.8440caf4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080416112341.ef1d5452.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
	<20080416092334.2dabce2c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080416112341.ef1d5452.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008 11:23:41 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 16 Apr 2008 09:23:34 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > What I experienced was.
> > ==
> > %echo offline > /sys/device/system/memoryXXXX/state
> > ...wait for a minute
> > Ctrl-C
> > % sync
> > % sync
> > % echo offline > /sys/device/system/memoryXXXX/state
> > ...wait for a minute
> > % echo 3 > /proc/sys/vm/drop_caches
> > % echo offline > /sys/device/system/memoryXXXX/state
> > success.
> > ==
> > 
> > I'll see what happens wish -EBUSY but maybe no help...
> > 
> Adding -EBUSY was no help. some pages seems never to be Uptodate...
> 
BTW, a bit off-topic.
I found I can't do memory offline when I use SLAB not SLUB, 
This is because some not-migratable page are in ZONE_MOVABLE.

here is zonestat.
==
Node 1, zone  Movable
  pages free     193181
        min      190
        low      237
        high     285
        scanned  0 (a: 0 i: 0)
        spanned  196608
        present  195744
    nr_free_pages 193181
    nr_inactive  102
    nr_active    2154
    nr_anon_pages 1851
    nr_mapped    365
    nr_file_pages 407
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 101
    nr_slab_unreclaimable 920
    nr_page_table_pages 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    numa_hit     0
    numa_miss    77029
    numa_foreign 0
    numa_interleave 0
    numa_local   0
    numa_other   76119
    pgpgin       910
        protection: (0, 0, 0)
==
Hmm, I guess SLAB's gfp_mask handling is wrong .....

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
