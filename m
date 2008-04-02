From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: EMM: Require single threadedness for registration.
Date: Wed, 2 Apr 2008 15:06:19 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080402220148.GV19189@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Thu, 3 Apr 2008, Andrea Arcangeli wrote:

> That would work for #v10 if I remove the invalidate_range_start from
> try_to_unmap_cluster, it can't work for EMM because you've
> emm_invalidate_start firing anywhere outside the context of the
> current task (even regular rmap code, not just nonlinear corner case
> will trigger the race). In short the single threaded approach would be

But in that case it will be firing for a callback to another mm_struct. 
The notifiers are bound to mm_structs and keep separate contexts.

> The requirement for invalidate_page is that the pte and linux tlb are
> flushed _before_ and the page is freed _after_ the invalidate_page
> method. that's not the case for _begin/_end. The page is freed well
> before _end runs, hence the need of _begin and to block the secondary
> mmu page fault during the vma-mangling operations.

You could flush in _begin and free on _end? I thought you are taking a 
refcount on the page? You can drop the refcount only on _end to ensure 
that the page does not go away before.
