From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 5/9] Convert anon_vma lock to rw_sem and
	refcount
Date: Wed, 2 Apr 2008 23:56:04 +0200
Message-ID: <20080402215604.GU19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205636.777127252@sgi.com>
	<20080402175058.GR19189@duo.random>
	<Pine.LNX.4.64.0804021107520.27337@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021107520.27337@schroedinger.engr.sgi.com>
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
Cc: steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 11:15:26AM -0700, Christoph Lameter wrote:
> On Wed, 2 Apr 2008, Andrea Arcangeli wrote:
> 
> > On Tue, Apr 01, 2008 at 01:55:36PM -0700, Christoph Lameter wrote:
> > >   This results in f.e. the Aim9 brk performance test to got down by 10-15%.
> > 
> > I guess it's more likely because of overscheduling for small crtitical
> > sections, did you counted the total number of context switches? I
> > guess there will be a lot more with your patch applied. That
> > regression is a showstopper and it is the reason why I've suggested
> > before to add a CONFIG_XPMEM or CONFIG_MMU_NOTIFIER_SLEEP config
> > option to make the VM locks sleep capable only when XPMEM=y
> > (PREEMPT_RT will enable it too). Thanks for doing the benchmark work!
> 
> There are more context switches if locks are contended. 
> 
> But that has actually also some good aspects because we avoid busy loops 
> and can potentially continue work in another process.

That would be the case if the "wait time" would be longer than the
scheduling time, the whole point is that with anonvma the write side
is so fast it's likely never worth scheduling (probably not even with
preempt-rt for the write side, the read side is an entirely different
matter but the read side can run concurrently if the system is heavy
paging), hence the slowdown. What you benchmarked is the write side,
which is also the fast path when the system is heavily CPU bound. I've
to say aim is a great benchmark to test this regression.

But I think a config option will solve all of this.
