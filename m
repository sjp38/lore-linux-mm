Date: Thu, 28 Feb 2008 01:11:04 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080228001104.GB8091@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com> <200802201008.49933.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2008 at 02:35:59PM -0800, Christoph Lameter wrote:
> Could you be specific? This refers to page migration? Hmmm... Guess we 

If the reader schedule, the synchronize_rcu will return in the other
cpu and the objects in the list will be freed and overwritten, and
when the task is scheduled back in, it'll follow dangling pointers...
You can't use RCU if you want any of your invalidate methods to
schedule. Otherwise it's like having zero locking.

> 2. Not handle file backed mappings (XPmem could work mostly in such a 
> config)

IMHO that fits under your definition of "hacking something in now and
then having to modify it later".

> 3. Keep the refcount elevated until pages are freed in another execution 
> context.

Page refcount is not enough (the mmu_notifier_release will run in
another cpu the moment after i_mmap_lock is unlocked) but mm_users may
prevent us to change the i_mmap_lock to a mutex, but it'll slowdown
truncate as it'll have to drop the lock and restart the radix tree
walk every time so a change like this better fits as a separate
CONFIG_XPMEM IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
