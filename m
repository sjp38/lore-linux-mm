Date: Tue, 25 Feb 2003 21:55:57 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Message-ID: <9860000.1046238956@[10.10.2.4]>
In-Reply-To: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com>
References: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com
 >
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Hmmm, ok, my scenario is this:
> 
> System call entry point (these are futex modifications),
> kernel/futex.c:futex_wake() and kernel/futex.c:futex_wait(). Both of them
> will require to kmap_atomic a page. When they are talking about the same
> futex (say three guys come in at the same time, one to unlock, two to
> lock), the three of them might end up doing kmap_atomic() over the same
> page. 
> 
> So, are you telling me that for that to work, I have to either:
> 
> - each caller uses a different KM_USER<WHATEVER> [kind of clumsy]
> 
> - I shall protect the kmap_atomic() region with an spinlock, to serialize
> it? [note I have the spinlock already, so it'd be a matter of spinlocking
> _before_ kmap_atomic() instead of after - ugly for a quick consistency
> check, but can live with it].
> 
> I think I still don't really understand what's up with the KM_ flags :]

Well, there's one kmap_atomic slot per type per cpu. So you should be fine
without spinlocks as long as you can't get pushed off the cpu by anything
you do (eg schedule) ... it's really intended for very short use, like: 

kmap
copy thing
kunmap

But be aware that pagefaulting inside kmap_atomic is bad - you can get
blocked and rescheduled, so touching user pages, etc is dangerous. Either
you do some really funky error handling to pick up the pieces if it goes
wrong, or just use regular kmap - you can always convert over later.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
