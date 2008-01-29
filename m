Message-ID: <479F85F9.3040104@sgi.com>
Date: Tue, 29 Jan 2008 12:00:57 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu>
In-Reply-To: <20080124224613.GA24855@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
...
> 
> tried it on x86.git and 1/3 did not build and 2/3 causes a boot hang 
> with the attached .config.
> 
> 	Ingo
> 

I've tracked down the failure to an early printk that when CONFIG_PRINTK_TIME
is enabled, any early printks cause cpu_clock to be called, which accesses
cpu_rq which is defined as:

 595 #define cpu_rq(cpu)             (&per_cpu(runqueues, (cpu)))

Since the zero-based patch is changing the offset from one based on
__per_cpu_start to zero, it's causing the function to access a
different area.

I'm working on a fix now.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
