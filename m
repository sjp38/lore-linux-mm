Date: Mon, 17 Nov 2008 13:42:35 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Large stack usage in fs code (especially for PPC64)
In-Reply-To: <20081117133137.616cf287.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0811171337400.18283@nehalem.linux-foundation.org>
References: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com> <20081117130856.92e41cd3.akpm@linux-foundation.org> <alpine.LFD.2.00.0811171320330.18283@nehalem.linux-foundation.org> <20081117133137.616cf287.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 17 Nov 2008, Andrew Morton wrote:
> 
> Yup.  That being said, the younger me did assert that "this is a neater
> implementation anyway".  If we can implement those loops without
> needing those on-stack temporary arrays then things probably are better
> overall.

Sure, if it actually ends up being nicer, I'll not argue with it. But from 
an L1 I$ standpoint (and I$ is often very important, especially for kernel 
loads where loops are fairly rare), it's often _much_ better to do two 
"tight" loops over two subsystems (filesystem and block layer) than it is 
to do one bigger loop that contains both. If the L1 can fit both subsystem 
paths, you're fine - but if not, you may get a lot more misses.

So it's often nice if you can "stage" things so that you do a cluster of 
calls to one area, followed by a cluster of calls to another, rather than 
mix it up. 

But numbers talk. And code cleanliness. If somebody has numbers that the 
code size actually goes down for example, or the code is just more 
readable, micro-optimizing cache patterns isn't worth it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
