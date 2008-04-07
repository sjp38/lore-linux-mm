From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [PATCH] mmu notifier #v11
Date: Mon, 7 Apr 2008 08:02:34 +0200
Message-ID: <20080407060234.GD9309@duo.random>
References: <20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
	<Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
	<20080404202055.GA14784@duo.random>
	<Pine.LNX.4.64.0804041504310.12396@schroedinger.engr.sgi.com>
	<20080405002330.GF14784@duo.random>
	<Pine.LNX.4.64.0804062244110.18148@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804062244110.18148@schroedinger.engr.sgi.com>
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

On Sun, Apr 06, 2008 at 10:45:41PM -0700, Christoph Lameter wrote:
> That depends on what the notifier is being used for. Some serialization 
> with the external mappings has to be done anyways. And its cleaner to have 

As far as I can tell no, you don't need to serialize against the
secondary mmu page fault in invalidate_page, like you instead have to
do in range_begin if you don't unpin the pages in range_end.

> one API that does a lock/unlock scheme. Atomic operations can easily lead
> to races.

What races? Note that if you don't want to optimize XPMEM and GRU can
feel free to implement their own invalidate_page as this:

     invalidate_page(mm, addr) {
     	range_begin(mm, addr, addr+PAGE_SIZE)
	range_end(mm, addr, addr+PAGE_SIZE)
     }

There's zero risk of adding races if they do this, but I doubt they
want to run as slow as with EMM so I guess they'll exploit the
optimization by going lock-free vs the spte page fault in
invalidate_page.
