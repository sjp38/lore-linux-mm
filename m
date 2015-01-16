Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 972746B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:16:48 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so8883757yha.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:16:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si1253602yka.164.2015.01.15.17.16.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 17:16:47 -0800 (PST)
Date: Thu, 15 Jan 2015 17:16:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-Id: <20150115171634.685237a4.akpm@linux-foundation.org>
In-Reply-To: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 15 Jan 2015 16:40:32 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> We had to insert a preempt enable/disable in the fastpath a while ago
> in order to guarantee that tid and kmem_cache_cpu are retrieved on the
> same cpu. It is the problem only for CONFIG_PREEMPT in which scheduler
> can move the process to other cpu during retrieving data.
> 
> Now, I reach the solution to remove preempt enable/disable in the fastpath.
> If tid is matched with kmem_cache_cpu's tid after tid and kmem_cache_cpu
> are retrieved by separate this_cpu operation, it means that they are
> retrieved on the same cpu. If not matched, we just have to retry it.
> 
> With this guarantee, preemption enable/disable isn't need at all even if
> CONFIG_PREEMPT, so this patch removes it.
> 
> I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)

I'm surprised.  preempt_disable/enable are pretty fast.  I wonder why
this makes a measurable difference.  Perhaps preempt_enable()'s call to
preempt_schedule() added pain?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
