From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: EMM: Require single threadedness for registration.
Date: Thu, 3 Apr 2008 00:01:48 +0200
Message-ID: <20080402220148.GV19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
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

On Wed, Apr 02, 2008 at 02:05:28PM -0700, Christoph Lameter wrote:
> Here is a patch to require single threaded execution during emm_register. 
> This also allows an easy implementation of an unregister function and gets
> rid of the races that Andrea worried about.

That would work for #v10 if I remove the invalidate_range_start from
try_to_unmap_cluster, it can't work for EMM because you've
emm_invalidate_start firing anywhere outside the context of the
current task (even regular rmap code, not just nonlinear corner case
will trigger the race). In short the single threaded approach would be
workable only thanks to the fact #v10 has the notion of
invalidate_page for flushing the tlb _after_ and to avoid blocking the
secondary page fault during swapping. In the kvm case I don't want to
block the page fault for anything but madvise which is strictly only
used after guest inflated the balloon, and the existence of
invalidate_page allows that optimization, and allows not to serialize
against the kvm page fault during all regular page faults when the
invalidate_page is called while the page is pinned by the VM.

The requirement for invalidate_page is that the pte and linux tlb are
flushed _before_ and the page is freed _after_ the invalidate_page
method. that's not the case for _begin/_end. The page is freed well
before _end runs, hence the need of _begin and to block the secondary
mmu page fault during the vma-mangling operations.

#v10 takes care of all this, and despite I could perhaps fix the
remaining two issues using the single-threaded enforcement I
suggested, I preferred to go safe and spend an unsigned per-mm in case
anybody needs to attach at runtime, the single threaded restriction
didn't look very clean.
