Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5B2C36B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:20:19 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id oy10so7098940veb.34
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 13:20:18 -0700 (PDT)
Date: Tue, 13 Aug 2013 16:19:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130813201958.GA28996@mtj.dyndns.org>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
 <201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
 <20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
 <52099187.80301@tilera.com>
 <20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello,

On Tue, Aug 13, 2013 at 12:35:12PM -0700, Andrew Morton wrote:
> I don't know how lots-of-kmallocs compares with alloc_percpu()
> performance-wise.

If this is actually performance sensitive, the logical thing to do
would be pre-allocating per-cpu buffers instead of depending on
dynamic allocation.  Do the invocations need to be stackable?

> That being said, the `cpumask_var_t mask' which was added to
> lru_add_drain_all() is unneeded - it's just a temporary storage which
> can be eliminated by creating a schedule_on_each_cpu_cond() or whatever
> which is passed a function pointer of type `bool (*call_needed)(int
> cpu, void *data)'.

I'd really like to avoid that.  Decision callbacks tend to get abused
quite often and it's rather sad to do that because cpumask cannot be
prepared and passed around.  Can't it just preallocate all necessary
resources?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
