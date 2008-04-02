From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: EMM: Fixup return value handling of emm_notify()
Date: Wed, 2 Apr 2008 23:25:15 +0200
Message-ID: <20080402212515.GS19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
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

On Wed, Apr 02, 2008 at 12:03:50PM -0700, Christoph Lameter wrote:
> +			/*
> +			 * Callback may return a positive value to indicate a count
> +			 * or a negative error code. We keep the first error code
> +			 * but continue to perform callbacks to other subscribed
> +			 * subsystems.
> +			 */
> +			if (x && result >= 0) {
> +				if (x >= 0)
> +					result += x;
> +				else
> +					result = x;
> +			}
>  		}
> +

Now think of when one of the kernel janitors will micro-optimize
PG_dirty to be returned by invalidate_page so a single set_page_dirty
will be invoked... Keep in mind this is a kernel internal APIs, ask
Greg if we can change it in order to optimize later in the future. I
think my #v9 is optimal enough while being simple at the same time,
but anyway it's silly to be hardwired to such an interface that worst
of all requires switch statements instead of proper pointer to
functions and a fixed set of parameters and retval semantics for all
methods.
