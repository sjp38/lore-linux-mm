Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A6E8F6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 17:03:40 -0500 (EST)
Date: Mon, 19 Dec 2011 14:03:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Put braces around potentially empty 'if' body in
 handle_pte_fault()
Message-Id: <20111219140338.a05bd83d.akpm@linux-foundation.org>
In-Reply-To: <20111218011828.GA4445@p183.telecom.by>
References: <alpine.LNX.2.00.1112180059080.21784@swampdragon.chaosbits.net>
	<1324167535.3323.63.camel@edumazet-laptop>
	<20111218003419.GE2203@ZenIV.linux.org.uk>
	<20111218011828.GA4445@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Jesper Juhl <jj@chaosbits.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, 18 Dec 2011 04:18:28 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Sun, Dec 18, 2011 at 12:34:19AM +0000, Al Viro wrote:
> > On Sun, Dec 18, 2011 at 01:18:55AM +0100, Eric Dumazet wrote:
> > > Thats should be fixed in the reverse way :
> > > 
> > > #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
> > 
> > There's a better way to do that -
> > #define f(a) do { } while(0)
> > does not work as a function returning void -
> > 	f(1), g();
> > won't work.  OTOH
> > #define f(a) ((void)0)
> > works just fine.
> 
> Two words: static inline.

Amen.  How often must we teach ourselves this lesson?


It gets a bit messy because of:

#ifndef flush_tlb_fix_spurious_fault
#define flush_tlb_fix_spurious_fault(vma, address) flush_tlb_page(vma, address)
#endif

But that can be handled with

static inline void flush_tlb_fix_spurious_fault(...)
{
	...
}
#define flush_tlb_fix_spurious_fault flush_tlb_fix_spurious_fault

and

#ifndef flush_tlb_fix_spurious_fault
static inline void flush_tlb_fix_spurious_fault(...)
{
}
#define flush_tlb_fix_spurious_fault flush_tlb_fix_spurious_fault
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
