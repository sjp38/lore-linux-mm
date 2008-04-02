From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: EMM: Require single threadedness for registration.
Date: Thu, 3 Apr 2008 00:17:16 +0200
Message-ID: <20080402221716.GY19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 03:06:19PM -0700, Christoph Lameter wrote:
> On Thu, 3 Apr 2008, Andrea Arcangeli wrote:
> 
> > That would work for #v10 if I remove the invalidate_range_start from
> > try_to_unmap_cluster, it can't work for EMM because you've
> > emm_invalidate_start firing anywhere outside the context of the
> > current task (even regular rmap code, not just nonlinear corner case
> > will trigger the race). In short the single threaded approach would be
> 
> But in that case it will be firing for a callback to another mm_struct. 
> The notifiers are bound to mm_structs and keep separate contexts.

Why can't it fire on the mm_struct where GRU just registered? That
mm_struct existed way before GRU registered, and VM is free to unmap
it w/o mmap_sem if there was any memory pressure.

> You could flush in _begin and free on _end? I thought you are taking a 
> refcount on the page? You can drop the refcount only on _end to ensure 
> that the page does not go away before.

we're going to lock + flush on begin and unlock on _end w/o
refcounting to microoptimize. Free is done by
unmap_vmas/madvise/munmap at will. That's a very slow path, inflating
the balloon is not problematic. But invalidate_page allows to avoid
blocking page faults during swapping so minor faults can happen and
refresh the pte young bits etc... When the VM unmaps the page while
holding the page pin, there's no race and that's where invalidate_page
is being used to generate lower invalidation overhead.
