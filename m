Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 839B76B0068
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:52:26 -0500 (EST)
Date: Mon, 30 Jan 2012 11:52:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <20120130174256.GF3355@google.com>
Message-ID: <alpine.DEB.2.00.1201301145570.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org> <20120130171558.GB3355@google.com> <alpine.DEB.2.00.1201301121330.28693@router.home> <20120130174256.GF3355@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Tejun Heo wrote:

> On Mon, Jan 30, 2012 at 11:22:14AM -0600, Christoph Lameter wrote:
> > On Mon, 30 Jan 2012, Tejun Heo wrote:
> >
> > > Percpu pointers are in a different address space and using
> > > ZERO_SIZE_PTR directly will trigger sparse address space warning.
> > > Also, I'm not entirely sure whether 16 is guaranteed to be unused in
> > > percpu address space (maybe it is but I don't think we have anything
> > > enforcing that).
> >
> > We are already checking for NULL on free. So there is a presumption that
> > these numbers are unused.
>
> Yes, we probably don't use 16 as valid dynamic address because static
> area would be larger than that.  It's just fuzzier than NULL.  And, as
> I wrote in another reply, ZERO_SIZE_PTR simply doesn't contribute
> anything.  Maybe we can update the allocator to always not use the
> lowest 4k for either static or dynamic and add debug code to
> translation macros to check for percpu addresses < 4k, but without
> such changes ZERO_SIZE_PTR simply doesn't do anything.

We have two possibilities now:

1. We say that the value returned from the per cpu allocator is an opaque
value.

	This means that we have to remove the NULL check from the free
	function. And audit the kernel code for all occurrences where
	a per cpu pointer value of NULL is assumed to mean that no per
	cpu allocation has occurred.

2. We say that there are special values for the per cpu pointers (NULL,
	ZERO_SIZE_PTR)

	Then we would have to guarantee that the per cpu allocator never
	returns those values.

	Plus then the ZERO_SIZE_PTR patch will be fine.

	The danger exist of these values being passed as
	parameters to functions that do not support them (per_cpu_ptr
	etc). Those would need VM_BUG_ONs or some other checks to detect
	potential problems.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
