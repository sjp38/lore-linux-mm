Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 857236B0002
	for <linux-mm@kvack.org>; Sun, 19 May 2013 09:34:54 -0400 (EDT)
Date: Sun, 19 May 2013 16:34:18 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130519133418.GA24381@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
 <20130519093526.GD19883@redhat.com>
 <1368966844.6828.111.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368966844.6828.111.camel@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Sun, May 19, 2013 at 08:34:04AM -0400, Steven Rostedt wrote:
> On Sun, 2013-05-19 at 12:35 +0300, Michael S. Tsirkin wrote:
> 
> > No, I was not assuming that. What I'm trying to say is that a caller
> > that does something like this under a spinlock:
> > 	preempt_disable
> > 	pagefault_disable
> > 	error = copy_to_user
> > 	pagefault_enable
> > 	preempt_enable_no_resched
> > 
> > is not doing anything wrong and should not get a warning,
> > as long as error is handled correctly later.
> > Right?
> > 
> 
> What I see wrong with the above is the preempt_enable_no_resched(). The
> only place that should be ever used is right before a schedule(), as you
> don't want to schedule twice (once for the preempt_enable() and then
> again for the schedule itself).
> 
> Remember, in -rt, a spin lock does not disable preemption.
> 
> -- Steve

Right but we need to keep it working on upstream as well.
If I do preempt_enable under a spinlock upstream won't it
try to sleep under spinlock?


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
