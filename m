Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E481E6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 23:18:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA64IQH7022277
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 13:18:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18F8D45DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:18:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E728F45DE4E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:18:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C906B1DB8040
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:18:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8269D1DB803A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:18:25 +0900 (JST)
Date: Fri, 6 Nov 2009 13:15:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
Message-Id: <20091106131545.62f52abb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	<20091104234923.GA25306@redhat.com>
	<alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
	<alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 10:36:06 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> +static inline unsigned long get_mm_rss(struct mm_struct *mm)
> +{
> +	int cpu;
> +	unsigned long r = 0;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct mm_counter *c = per_cpu_ptr(mm->rss, cpu);
> +
> +		r = c->file + c->anon;
> +	}
> +
> +	return r;
> +}
> +
> +static inline void update_hiwater_rss(struct mm_struct *mm)
> +{
> +	unsigned long _rss = get_mm_rss(mm);
> +	if (mm->hiwater_rss < _rss)
> +		mm->hiwater_rss = _rss;
> +}
> +

I'm sorry for my replies are scatterd.

Isn't it better to add some filter in following path ?

==
static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
                                enum ttu_flags flags)
{
<snip>
       /* Update high watermark before we lower rss */
        update_hiwater_rss(mm);
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
