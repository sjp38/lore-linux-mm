Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C470F6B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 17:56:58 -0400 (EDT)
Received: by wwg9 with SMTP id 9so4891745wwg.26
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 14:56:56 -0700 (PDT)
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110822135218.f2d9f462.akpm@linux-foundation.org>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
	 <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
	 <20110822135218.f2d9f462.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Aug 2011 23:56:51 +0200
Message-ID: <1314050211.4791.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, linux-arch@vger.kernel.org

Le lundi 22 aoA>>t 2011 A  13:52 -0700, Andrew Morton a A(C)crit :
> On Tue, 23 Aug 2011 01:29:07 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 
> > memchr_inv() is mainly used to check whether the whole buffer is filled
> > with just a specified byte.
> > 
> > The function name and prototype are stolen from logfs and the
> > implementation is from SLUB.
> > 
> > ...
> >
> > +/**
> > + * memchr_inv - Find a character in an area of memory.
> > + * @s: The memory area
> > + * @c: The byte to search for
> > + * @n: The size of the area.
> 
> This text seems to be stolen from memchr().  I guess it's close enough.
> 
> > + * returns the address of the first character other than @c, or %NULL
> > + * if the whole buffer contains just @c.
> > + */
> > +void *memchr_inv(const void *start, int c, size_t bytes)
> > +{
> > +	u8 value = c;
> > +	u64 value64;
> > +	unsigned int words, prefix;
> > +
> > +	if (bytes <= 16)
> > +		return check_bytes8(start, value, bytes);
> > +
> > +	value64 = value | value << 8 | value << 16 | value << 24;
> > +	value64 = (value64 & 0xffffffff) | value64 << 32;
> > +	prefix = 8 - ((unsigned long)start) % 8;
> > +

<snip>

> > +	if (prefix) {
> > +		u8 *r = check_bytes8(start, value, prefix);
> > +		if (r)
> > +			return r;
> > +		start += prefix;
> > +		bytes -= prefix;
> > +	}

</snip>

Please note Andrew the previous code just make sure 'start' is aligned
on 8 bytes boundary. (It is suboptimal because if 'start' was already
aligned, we call the slow check_bytes(start, value, 8))

Code should probably do

prefix = (unsigned long)start % 8;
if (prefix) {
	prefix = 8 - prefix;
	r = check_bytes8(start, value, prefix);
	...



> > +
> > +	words = bytes / 8;
> > +
> > +	while (words) {
> > +		if (*(u64 *)start != value64)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
