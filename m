Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1486B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 04:02:42 -0400 (EDT)
Received: by ywa17 with SMTP id 17so3353216ywa.14
        for <linux-mm@kvack.org>; Mon, 24 Oct 2011 01:02:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m2obx755md.fsf@firstfloor.org>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
	<1319384922-29632-7-git-send-email-gilad@benyossef.com>
	<m2obx755md.fsf@firstfloor.org>
Date: Mon, 24 Oct 2011 10:02:38 +0200
Message-ID: <CAOtvUMfVFV3_2wtT-qNpcHxzsTW-1j3wGUqt+O5GhayZHxW1mg@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if offstack
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: lkml@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Mon, Oct 24, 2011 at 7:19 AM, Andi Kleen <andi@firstfloor.org> wrote:
>
> Gilad Ben-Yossef <gilad@benyossef.com> writes:
>
> > We need a cpumask to track cpus with per cpu cache pages
> > to know which cpu to whack during flush_all. For
> > CONFIG_CPUMASK_OFFSTACK=n we allocate the mask on stack.
> > For CONFIG_CPUMASK_OFFSTACK=y we don't want to call kmalloc
> > on the flush_all path, so we preallocate per kmem_cache
> > on cache creation and use it in flush_all.
>
> What's the problem with calling kmalloc in flush_all?
> That's a slow path anyways, isn't it?
>
> I believe the IPI functions usually allocate anyways.
>
> So maybe you can do that much simpler.

That was what the first version of the patch did (use
alloc_cpumask_var in flush_all).

Pekka Enberg pointed out that calling kmalloc on the kmem_cache
shrinking code path is not a good idea
and it does sound like a deadlock waiting to happen.

Gilad

--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
