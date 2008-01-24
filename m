Date: Thu, 24 Jan 2008 16:42:39 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080124154239.GP7141@v2.random>
References: <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <20080123114136.GE15848@v2.random> <20080123123230.GH26420@sgi.com> <20080123173325.GG7141@v2.random> <Pine.LNX.4.64.0801231220590.13547@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801231220590.13547@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 12:27:47PM -0800, Christoph Lameter wrote:
> There are still dirty bit issues.

Yes, but no big issues given ->invalidate_page is fully capable of
running set_page_dirty if needed.

> > The window that you must close with that bitflag is the request coming
> > from the remote node to map the page after the linux pte has been
> > cleared. If you map the page in a remote node after the linux pte has
> > been cleared ->invalidate_page won't be called again because the page
> > will look unmapped in the linux VM. Now invalidate_page will clear the
> > bitflag, so the map requests will block. But where exactly you know
> > that the linux pte has been cleared so you can "unblock" the map
> > requests? If a page is not mapped by some linux pte, mm/rmap.c will
> > never be called and this is why any notification in mm/rmap.c should
> > track the "address space" and not the "physical page".
> 
> The subsystem needs to establish proper locking for that case.

How? I Your answer was to have the subsystem-fault wait PG_exported to
return ON... when later you told me the subsystem-fault is the thing
supposed to set PG_exported ON again... Perhaps you really could
invent a proper locking to make your #v1 workable somehow but I didn't
see a sign of it yet.

Infact I'm not so sure if all will be race-free with
invalidate_page_after (given you pretend to call it outside the PT
lock so concurrent linux minor faults can happen in parallel of your
invalidate_page_after) but at least it has a better chance to work
without having to invent much new complex locking.

> It also deals f.e. with page dirty status.

I think you should consider if you can also build a rmap per-MM like
KVM does and index it by the virtual address like KVM does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
