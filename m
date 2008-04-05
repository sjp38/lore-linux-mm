From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [PATCH] mmu notifier #v11
Date: Sat, 5 Apr 2008 02:23:30 +0200
Message-ID: <20080405002330.GF14784@duo.random>
References: <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
	<Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
	<20080404202055.GA14784@duo.random>
	<Pine.LNX.4.64.0804041504310.12396@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804041504310.12396@schroedinger.engr.sgi.com>
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

On Fri, Apr 04, 2008 at 03:06:18PM -0700, Christoph Lameter wrote:
> Adds some comments. Still objectionable is the multiple ways of
> invalidating pages in #v11. Callout now has similar locking to emm.

range_begin exists because range_end is called after the page has
already been freed. invalidate_page is called _before_ the page is
freed but _after_ the pte has been zapped.

In short when working with single pages it's a waste to block the
secondary-mmu page fault, because it's zero cost to invalidate_page
before put_page. Not even GRU need to do that.

Instead for the multiple-pte-zapping we have to call range_end _after_
the page is already freed. This is so that there is a single range_end
call for an huge amount of address space. So we need a range_begin for
the subsystems not using page pinning for example. When working with
single pages (try_to_unmap_one, do_wp_page) invalidate_page avoids to
block the secondary mmu page fault, and it's in turn faster.

Besides avoiding need of serializing the secondary mmu page fault,
invalidate_page also reduces the overhead when the mmu notifiers are
disarmed (i.e. kvm not running).
