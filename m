Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73861C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:25:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2712E20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:25:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="mExFPkFx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2712E20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B0F8E0004; Wed,  6 Mar 2019 11:25:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A49218E0003; Wed,  6 Mar 2019 11:25:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939B08E0004; Wed,  6 Mar 2019 11:25:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE468E0003
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 11:25:23 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k21so10320657qkg.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 08:25:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TLFNRaBXKZns1+8KdSrlpQM+Fx38R+PSvw7GHUE0UyQ=;
        b=ipiEe8I0IfnNLt6mkU/jwr2OZs7T9uErrznr8PED1xRCji54cQ1LzWPttDZ/YOI3gN
         +MbmyvcyrSVSPtY3mxOjKtNpFwBsVNq7w5bvcnhVX0gLTE+qHzMbFWQdXvZsV84Ai7KL
         X1CHqUiWSShiPrRmzpjK4V35AMeJfBx3d1YKLKMcZJ3N7vVb19mlLSrIwVk8T7Ea8/Zh
         Mebxpuj8yWbynhhH3bkRYRC73gQRNuRnzNulyf/jye/f6y7mUmXQRwbESrqr+5S3qO9Z
         hQoqV+1UqTTS9/UVlvbbVYXcijV14s747goJch0SDR0czwlnM32+cSLhaELbySiqLfhi
         mVuA==
X-Gm-Message-State: APjAAAVCMp5nlGPUuPzGQaSyarAv71C94471pvdytbRS0kLjf7dGxJIv
	UjsGptRNiFe6X6YBT4Ivswf7Bd7v4y5VELjoXawdODKn+hYe2R+TTq6AL+A6k+yfHCBqzTUKI7k
	CpOfQhadKIlpQzx1YYKRVBhzsodJhLQDgnqtArvcCUgpfavP3ESr4jxKEzmGZOzrNz3E7vPOC8d
	vhuVF2jZeQv/t9kU+abLUFDX7YLfMaZTCn7jYr0umGnMFLgiVm8bM4GdeTe7DG+ibQyuNWgDBNr
	22ksfxTxJASaAgXJn8e9lu2lcm7crq6ZiQEfkU6JfJoHzbhlbtYa6OctABod5hHarx7vGR+/Lil
	LbQIFMM9poR03ArthJb+Dg1OiDNVP3F1+hG9RkD0LSfml/OIN99KqMXTqWYO3DYg3oOY75DGsNq
	e
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr6385536qtw.228.1551889523163;
        Wed, 06 Mar 2019 08:25:23 -0800 (PST)
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr6385462qtw.228.1551889522003;
        Wed, 06 Mar 2019 08:25:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551889522; cv=none;
        d=google.com; s=arc-20160816;
        b=QgsTV6fgsTAxxwdAaQzf0h81Nd6v/wOud1/1y7w37JNTQGcqQY9RtXv78+ZVVkBE2l
         KkQu7bRgvTO1tpYzer6Odf/4GIz0RXucVFWzb5QCDnlbu6MYnRRz8ZIo2C0rIoBVC2vI
         JMHMUUzqwAkuL0XLhqJ1Ik+3yVienvHG9cWV9HLNeSnEm6pwDgJPenC6Pw3YEn206BGV
         e17CmijKpB1P5y9/RWUCskP9povNQ2KEuBoXmdfO/+lD3Q1n5465dpD2/zxBl6S+mDDK
         M19uH0twuweIW0UQA9nLzxAPGEMeLOrCTaZfPHh8Frz7QWw/xijkXA2kVY/4H2OOv/oD
         Tzzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TLFNRaBXKZns1+8KdSrlpQM+Fx38R+PSvw7GHUE0UyQ=;
        b=LTZyzAAOyy0+dQJUyEptmYP0elyMbcsOLcYXxBW0e30BvGXvKUWavxZMLOtPMAOwcs
         aObhQmW5xVsabQvPWn+y+mIdmX6KcmeNZIRBcdAuifMDRrWQosFhHssJpIKWNhnS7zZy
         g7Q4KdzXxsrEsWELRPTM/kZytI0mRn3Hquhwn+WlicBxGUYx1BAp2AbLJBRlHrp67u/n
         ad8ghajMa4BOC7Iz4CwggCT5D9TDvT6TabL92Fb+isQQllQHGP9j419Hq1P8ABM1uWBw
         oEGz4YfuI9eVuKZy4hi71VTjuHzq34Auw8T77S/l6va67hRaeJOMFpOf+/Af9SPlfLtQ
         whJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=mExFPkFx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor2304769qvn.37.2019.03.06.08.25.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 08:25:21 -0800 (PST)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=mExFPkFx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TLFNRaBXKZns1+8KdSrlpQM+Fx38R+PSvw7GHUE0UyQ=;
        b=mExFPkFxzhZwwgDc8Iiv/OP6/UoPj699I3u/Zaoh9iDqrcedzjMWCQ7H0ddSeD2S6q
         MItIlD7YeYCStj7UezZI0nLL/giXtsyzgEHq7PmmGQfpFbOuX3pnC7u5/g/HBDXWBXbf
         zdDt/mP+tC67xtGszwTEv3P1NE9KvT0piKTfQ=
X-Google-Smtp-Source: APXvYqzcrKQw6+sLInw6mV4NIizF2Oy6RZ5vBLLoODVN6ZGWsVQGoHNU7QfNQxHlseqA/x8Y4pdqeg==
X-Received: by 2002:a0c:88db:: with SMTP id 27mr6880276qvo.41.1551889521472;
        Wed, 06 Mar 2019 08:25:21 -0800 (PST)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id w8sm1626418qkw.80.2019.03.06.08.25.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 08:25:20 -0800 (PST)
Date: Wed, 6 Mar 2019 11:25:19 -0500
From: Joel Fernandes <joel@joelfernandes.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-ID: <20190306162519.GB193418@google.com>
References: <20190124115648.9433-1-urezki@gmail.com>
 <20190124115648.9433-3-urezki@gmail.com>
 <20190128224528.GB38107@google.com>
 <20190129173936.4sscooiybzbhos77@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129173936.4sscooiybzbhos77@pc636>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:39:36PM +0100, Uladzislau Rezki wrote:
> On Mon, Jan 28, 2019 at 05:45:28PM -0500, Joel Fernandes wrote:
> > On Thu, Jan 24, 2019 at 12:56:48PM +0100, Uladzislau Rezki (Sony) wrote:
> > > commit 763b218ddfaf ("mm: add preempt points into
> > > __purge_vmap_area_lazy()")
> > > 
> > > introduced some preempt points, one of those is making an
> > > allocation more prioritized over lazy free of vmap areas.
> > > 
> > > Prioritizing an allocation over freeing does not work well
> > > all the time, i.e. it should be rather a compromise.
> > > 
> > > 1) Number of lazy pages directly influence on busy list length
> > > thus on operations like: allocation, lookup, unmap, remove, etc.
> > > 
> > > 2) Under heavy stress of vmalloc subsystem i run into a situation
> > > when memory usage gets increased hitting out_of_memory -> panic
> > > state due to completely blocking of logic that frees vmap areas
> > > in the __purge_vmap_area_lazy() function.
> > > 
> > > Establish a threshold passing which the freeing is prioritized
> > > back over allocation creating a balance between each other.
> > 
> > I'm a bit concerned that this will introduce the latency back if vmap_lazy_nr
> > is greater than half of lazy_max_pages(). Which IIUC will be more likely if
> > the number of CPUs is large.
> > 
> The threshold that we establish is two times more than lazy_max_pages(),
> i.e. in case of 4 system CPUs lazy_max_pages() is 24576, therefore the
> threshold is 49152, if PAGE_SIZE is 4096.
> 
> It means that we allow rescheduling if vmap_lazy_nr < 49152. If vmap_lazy_nr 
> is higher then we forbid rescheduling and free areas until it becomes lower
> again to stabilize the system. By doing that, we will not allow vmap_lazy_nr
> to be enormously increased.

Sorry for late reply.

This sounds reasonable. Such an extreme situation of vmap_lazy_nr being twice
the lazy_max_pages() is probably only possible using a stress test anyway
since (hopefully) the try_purge_vmap_area_lazy() call is happening often
enough to keep the vmap_lazy_nr low.

Have you experimented with what is the highest threshold that prevents the
issues you're seeing? Have you tried 3x or 4x the vmap_lazy_nr?

I also wonder what is the cost these days of the global TLB flush on the most
common Linux architectures and if the whole purge vmap_area lazy stuff is
starting to get a bit dated, and if we can do the purging inline as areas are
freed. There is a cost to having this mechanism too as you said, which is as
the list size grows, all other operations also take time.

thanks,

 - Joel


> > In fact, when vmap_lazy_nr is high, that's when the latency will be the worst
> > so one could say that that's when you *should* reschedule since the frees are
> > taking too long and hurting real-time tasks.
> > 
> > Could this be better solved by tweaking lazy_max_pages() such that purging is
> > more aggressive?
> > 
> > Another approach could be to detect the scenario you brought up (allocations
> > happening faster than free), somehow, and avoid a reschedule?
> > 
> This is what i am trying to achieve by this change. 
> 
> Thank you for your comments.
> 
> --
> Vlad Rezki
> > > 
> > > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > > ---
> > >  mm/vmalloc.c | 18 ++++++++++++------
> > >  1 file changed, 12 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index fb4fb5fcee74..abe83f885069 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -661,23 +661,27 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> > >  	struct llist_node *valist;
> > >  	struct vmap_area *va;
> > >  	struct vmap_area *n_va;
> > > -	bool do_free = false;
> > > +	int resched_threshold;
> > >  
> > >  	lockdep_assert_held(&vmap_purge_lock);
> > >  
> > >  	valist = llist_del_all(&vmap_purge_list);
> > > +	if (unlikely(valist == NULL))
> > > +		return false;
> > > +
> > > +	/*
> > > +	 * TODO: to calculate a flush range without looping.
> > > +	 * The list can be up to lazy_max_pages() elements.
> > > +	 */
> > >  	llist_for_each_entry(va, valist, purge_list) {
> > >  		if (va->va_start < start)
> > >  			start = va->va_start;
> > >  		if (va->va_end > end)
> > >  			end = va->va_end;
> > > -		do_free = true;
> > >  	}
> > >  
> > > -	if (!do_free)
> > > -		return false;
> > > -
> > >  	flush_tlb_kernel_range(start, end);
> > > +	resched_threshold = (int) lazy_max_pages() << 1;
> > >  
> > >  	spin_lock(&vmap_area_lock);
> > >  	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
> > > @@ -685,7 +689,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
> > >  
> > >  		__free_vmap_area(va);
> > >  		atomic_sub(nr, &vmap_lazy_nr);
> > > -		cond_resched_lock(&vmap_area_lock);
> > > +
> > > +		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
> > > +			cond_resched_lock(&vmap_area_lock);
> > >  	}
> > >  	spin_unlock(&vmap_area_lock);
> > >  	return true;
> > > -- 
> > > 2.11.0
> > > 

