Message-ID: <4797384B.7080200@redhat.com>
Date: Wed, 23 Jan 2008 13:51:23 +0100
From: Gerd Hoffmann <kraxel@redhat.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH] export notifier #1
References: <20080113162418.GE8736@v2.random>	<20080116124256.44033d48@bree.surriel.com>	<478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random>	<478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random>	<20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com>	<20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Jumping in here, looks like this could develop into a direction useful
for Xen.

Background:  Xen has a mechanism called "grant tables" for page sharing.
 Guest #1 can issue a "grant" for another guest #2, which in turn then
can use that grant to map the page owned by guest #1 into its address
space.  This is used by the virtual network/disk drivers, i.e. typically
Domain-0 (which has access to the real hardware) maps pages of other
guests to fill in disk/network data.

Establishing and tearing down mappings for those grants must happen
through a special grant table hypercall, and especially for the tear
down part of the problem mmu/export/whatever-we-call-them-in-the-end
notifies could help.

> Issues with mmu_ops #2
> 
> - Notifiers are called *after* we tore down ptes.

That would render the notifies useless for Xen too.  Xen needs to
intercept the actual pte clear and instead of just zapping it use the
hypercall to do the unmap and release the grant.

Current implementation uses a new vm_ops operation which is called if
present instead of doing a ptep_get_and_clear_full().  It is in the
XenSource tree only, mainline hasn't this yet due to implementing only
the DomU bits so far.  When adding Dom0 support to mainline we'll need
some way to handle it, and I'd like to see the notifies be designed in a
way that Xen can simply use them.

cheers,
  Gerd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
