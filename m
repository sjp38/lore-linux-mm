From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 5/9] Convert anon_vma lock to rw_sem and
	refcount
Date: Thu, 3 Apr 2008 00:12:28 +0200
Message-ID: <20080402221228.GX19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205636.777127252@sgi.com>
	<20080402175058.GR19189@duo.random>
	<Pine.LNX.4.64.0804021107520.27337@schroedinger.engr.sgi.com>
	<20080402215604.GU19189@duo.random>
	<Pine.LNX.4.64.0804021455180.31247@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021455180.31247@schroedinger.engr.sgi.com>
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

On Wed, Apr 02, 2008 at 02:56:25PM -0700, Christoph Lameter wrote:
> I am a bit surprised that brk performance is that important. There may be 

I think it's not brk but fork that is being slowed down, did you
oprofile? AIM forks a lot... The write side fast path generating the
overscheduling I guess is when the new vmas are created for the child
and queued in the parent anon-vma in O(1), so immediate, even
preempt-rt would be ok with it spinning and not scheduling, it's just
a list_add (much faster than schedule() indeed). Every time there's a
collision when multiple child forks simultaneously and they all try to
queue in the same anon-vma, things will slowdown.
