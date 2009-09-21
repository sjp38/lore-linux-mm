Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 50A8D6B0116
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 02:23:55 -0400 (EDT)
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <4AB6508C.4070602@kernel.org>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
	 <1253302451-27740-2-git-send-email-mel@csn.ul.ie>
	 <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com>
	 <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi>
	 <4AB6508C.4070602@kernel.org>
Date: Mon, 21 Sep 2009 09:24:00 +0300
Message-Id: <1253514240.5216.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On Mon, 2009-09-21 at 00:55 +0900, Tejun Heo wrote:
> Pekka Enberg wrote:
> > Tejun Heo wrote:
> >> Pekka Enberg wrote:
> >>> On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> >>>> SLQB used a seemingly nice hack to allocate per-node data for the
> >>>> statically
> >>>> initialised caches. Unfortunately, due to some unknown per-cpu
> >>>> optimisation, these regions are being reused by something else as the
> >>>> per-node data is getting randomly scrambled. This patch fixes the
> >>>> problem but it's not fully understood *why* it fixes the problem at the
> >>>> moment.
> >>> Ouch, that sounds bad. I guess it's architecture specific bug as x86
> >>> works ok? Lets CC Tejun.
> >>
> >> Is the corruption being seen on ppc or s390?
> > 
> > On ppc.
> 
> Can you please post full dmesg showing the corruption?  Also, if you
> apply the attached patch, does the added BUG_ON() trigger?

I don't have the affected machines, Sachin and Mel do.

			Pekka

> diff --git a/include/linux/percpu.h b/include/linux/percpu.h
> index 878836c..fb690d2 100644
> --- a/include/linux/percpu.h
> +++ b/include/linux/percpu.h
> @@ -127,7 +127,7 @@ extern int __init pcpu_page_first_chunk(size_t reserved_size,
>   * dynamically allocated. Non-atomic access to the current CPU's
>   * version should probably be combined with get_cpu()/put_cpu().
>   */
> -#define per_cpu_ptr(ptr, cpu)	SHIFT_PERCPU_PTR((ptr), per_cpu_offset((cpu)))
> +#define per_cpu_ptr(ptr, cpu)	({ BUG_ON(!(ptr)); SHIFT_PERCPU_PTR((ptr), per_cpu_offset((cpu))); })
> 
>  extern void *__alloc_reserved_percpu(size_t size, size_t align);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
