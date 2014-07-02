Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0C86B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 01:46:46 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so11827991pad.41
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 22:46:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yu2si29173787pac.156.2014.07.01.22.46.45
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 22:46:45 -0700 (PDT)
Date: Tue, 1 Jul 2014 22:46:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
Message-Id: <20140701224621.bb6a5157.akpm@linux-foundation.org>
In-Reply-To: <53B216C5.8020503@codeaurora.org>
References: <53A8D092.4040801@lge.com>
	<xa1td2dvmznq.fsf@mina86.com>
	<53ACAB82.6020201@lge.com>
	<53B06DD0.8030106@codeaurora.org>
	<53B209BA.8010106@lge.com>
	<53B216C5.8020503@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Gioh Kim <gioh.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?UTF-8?Q?=EC=9D=B4=EA=B1=B4=ED=98=B8?= <gunho.lee@lge.com>, Hugh Dickins <hughd@google.com>

On Mon, 30 Jun 2014 19:02:45 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:

> On 6/30/2014 6:07 PM, Gioh Kim wrote:
> > Hi,Laura.
> > 
> > I have a question.
> > 
> > Does the __evict_bh_lru() not need bh_lru_lock()?
> > The get_cpu_var() has already preenpt_disable() and can prevent other thread.
> > But get_cpu_var cannot prevent IRQ context such like page-fault.
> > I think if a page-fault occured and a file is read in IRQ context it can change cpu-lru.
> > 
> > Is my concern correct?
> > 
> > 
> 
> __evict_bh_lru is called via on_each_cpu_cond which I believe will disable irqs.
> I based the code on the existing invalidate_bh_lru which did not take the bh_lru_lock
> either. It's possible I missed something though.

I fear that running on_each_cpu() within try_to_free_buffers() is going
to be horridly expensive in some cases.

Maybe CMA can use invalidate_bh_lrus() to shoot down everything before
trying the allocation attempt.  That should increase the success rate
greatly and doesn't burden page reclaim.  The bh LRU isn't terribly
important from a performance point of view, so emptying it occasionally
won't hurt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
