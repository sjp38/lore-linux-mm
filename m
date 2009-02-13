Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5653F6B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 08:21:23 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Export symbol ksize()
Date: Sat, 14 Feb 2009 00:20:44 +1100
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name> <20090212230934.GA21609@gondor.apana.org.au> <1234481821.3152.27.camel@calx>
In-Reply-To: <1234481821.3152.27.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902140020.45522.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Pekka Enberg <penberg@cs.helsinki.fi>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Friday 13 February 2009 10:37:01 Matt Mackall wrote:
> On Fri, 2009-02-13 at 07:09 +0800, Herbert Xu wrote:
> > On Fri, Feb 13, 2009 at 12:10:45AM +1100, Nick Piggin wrote:
> > > I would be interested to know how that goes. You always have this
> > > circular issue that if a little more space helps significantly, then
> > > maybe it is a good idea to explicitly ask for those bytes. Of course
> > > that larger allocation is also likely to have some slack bytes.
> >
> > Well, the thing is we don't know apriori whether we need the
> > extra space.  The idea is to use the extra space if available
> > to avoid reallocation when we hit things like IPsec.
>
> I'm not entirely convinced by this argument. If you're concerned about
> space rather than performance, then you want an allocator that doesn't
> waste space in the first place and you don't try to do "sub-allocations"
> by hand. If you're concerned about performance, you instead optimize
> your allocator to be as fast as possible and again avoid conditional
> branches for sub-allocations.

Well, my earlier reasoning is no longer so clear cut if eg. there
are common cases where no extra space is required, but rare cases
where extra space might be a big win if it eg avoids extra
alloc, copy, free or something.

Because even with performance oriented allocators, there is a non-zero
cost to explicitly asking for more memory -- queues tend to get smaller
at larger object sizes, and page allocation orders can increase. So if
it is very uncommon to need extra space you don't want to burden the
common case with it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
