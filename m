Date: Thu, 13 Apr 2006 17:08:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/5] Swapless page migration V2: Overview
Message-Id: <20060413170853.0757af41.akpm@osdl.org>
In-Reply-To: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> Swapless Page migration V2
> 
> Currently page migration is depending on the ability to assign swap entries
> to pages. However, those entries will only be to identify anonymous pages.
> Page migration will not work without swap although swap space is never
> really used.

That strikes me as a fairly minor limitation?

> ...
>
> Efficiency of migration is increased by:
> 
> 1. Avoiding useless retries
>    The use of migration entries avoids raising the page count in do_swap_page().
>    The existing approach can increase the page count between the unmapping
>    of the ptes for a page and the page migration page count check resulting
>    in having to retry migration although all accesses have been stopped.

Minor.

> 2. Swap entries do not have to be assigned and removed from pages.

Minor.

> 3. No swap space has to be setup for page migration. Page migration
>    will never use swap.

Minor.

> The patchset will allow later patches to enable migration of VM_LOCKED vmas,
> the ability to exempt vmas from page migration, and allow the implementation
> of a another userland migration API for handling batches of pages.

These seem like more important justifications.  Would you agree with that
judgement?

Is it not possible to implement some or all of these new things without
this work?



That all being said, this patchset is pretty low-impact:

 include/linux/rmap.h    |    1 
 include/linux/swap.h    |    6 
 include/linux/swapops.h |   32 +++++
 mm/Kconfig              |    4 
 mm/memory.c             |    6 
 mm/migrate.c            |  242 ++++++++++++++++++++------------------
 mm/rmap.c               |   88 ++++---------
 mm/swapfile.c           |   15 --
 8 files changed, 212 insertions(+), 182 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
