Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5D1466B006E
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:58:56 -0500 (EST)
Date: Mon, 30 Jan 2012 11:58:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <20120130175434.GG3355@google.com>
Message-ID: <alpine.DEB.2.00.1201301156530.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org> <20120130171558.GB3355@google.com> <alpine.DEB.2.00.1201301121330.28693@router.home> <20120130174256.GF3355@google.com> <alpine.DEB.2.00.1201301145570.28693@router.home>
 <20120130175434.GG3355@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Tejun Heo wrote:

> Hello, Christoph.
>
> On Mon, Jan 30, 2012 at 11:52:23AM -0600, Christoph Lameter wrote:
> > We have two possibilities now:
> >
> > 1. We say that the value returned from the per cpu allocator is an opaque
> > value.
> >
> > 	This means that we have to remove the NULL check from the free
> > 	function. And audit the kernel code for all occurrences where
> > 	a per cpu pointer value of NULL is assumed to mean that no per
> > 	cpu allocation has occurred.
>
> No, NULL is never gonna be a valid return from any allocator including
> percpu.  Percpu allocator doesn't and will never do so.

How do you prevent the percpu allocator from returning NULL? I thought the
per cpu offsets can wrap around?

> > 2. We say that there are special values for the per cpu pointers (NULL,
> > 	ZERO_SIZE_PTR)
> >
> > 	Then we would have to guarantee that the per cpu allocator never
> > 	returns those values.
> >
> > 	Plus then the ZERO_SIZE_PTR patch will be fine.
> >
> > 	The danger exist of these values being passed as
> > 	parameters to functions that do not support them (per_cpu_ptr
> > 	etc). Those would need VM_BUG_ONs or some other checks to detect
> > 	potential problems.
>
> I'm saying we don't have this for ZERO_SIZE_PTR in any meaningful way
> at this point.  If somebody wants to implement it properly, please
> feel free to, but simply applying ZERO_SIZE_PTR without other changes
> doesn't make any sense.

We have no clean notion of how a percpu pointer needs to be handled. Both
ways of handling things have drawbacks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
