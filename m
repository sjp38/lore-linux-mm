Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6B6E56B0068
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 13:12:21 -0500 (EST)
Date: Mon, 30 Jan 2012 12:12:18 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <20120130180224.GH3355@google.com>
Message-ID: <alpine.DEB.2.00.1201301206080.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org> <20120130171558.GB3355@google.com> <alpine.DEB.2.00.1201301121330.28693@router.home> <20120130174256.GF3355@google.com> <alpine.DEB.2.00.1201301145570.28693@router.home>
 <20120130175434.GG3355@google.com> <alpine.DEB.2.00.1201301156530.28693@router.home> <20120130180224.GH3355@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Tejun Heo wrote:

> Hello,
>
> On Mon, Jan 30, 2012 at 11:58:52AM -0600, Christoph Lameter wrote:
> > > No, NULL is never gonna be a valid return from any allocator including
> > > percpu.  Percpu allocator doesn't and will never do so.
> >
> > How do you prevent the percpu allocator from returning NULL? I thought the
> > per cpu offsets can wrap around?
>
> I thought it didn't.  I rememer thinking about this and determining
> that NULL can't be allocated for dynamic addresses.  Maybe I'm
> imagining things.  Anyways, if it can return NULL for valid
> allocation, it is a bug and should be fixed.

I dont see anything that would hinder an arbitrary value to be returned.
NULL is also used for the failure case. Definitely a bug.

> > > I'm saying we don't have this for ZERO_SIZE_PTR in any meaningful way
> > > at this point.  If somebody wants to implement it properly, please
> > > feel free to, but simply applying ZERO_SIZE_PTR without other changes
> > > doesn't make any sense.
> >
> > We have no clean notion of how a percpu pointer needs to be handled. Both
> > ways of handling things have drawbacks.
>
> We don't have returned addr >= PAGE_SIZE guarantee yet but I'm fairly
> sure that's the only acceptable direction if we want any improvement
> in this area.

The ZERO_SIZE_PTR patch would not make the situation that much worse.

If the per cpu allocator happens to return NULL for a valid allocation
then this allocation cannot be freed anymore since the free function
checks for NULL. Most callers check the result for NULL though and will
fail in other ways at a higher level. Such an allocation can only happen
once and from hen on some memory is wasted.

If the per cpu allocator just happens to return ZERO_SIZE_PTR for a valid
allocation then this value is going to be passed to other per cpu
functions. However, the size is 0 so no actual read or write should ever
take place.

On free its not going to be freed since the free function checks for
ZERO_SIZE_PTR. So we have a situation almost the same as for NULL pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
