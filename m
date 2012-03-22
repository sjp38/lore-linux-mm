Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5B3A26B00F8
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 18:09:05 -0400 (EDT)
Received: by werj55 with SMTP id j55so3009070wer.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:09:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120322144122.59d12051.akpm@linux-foundation.org>
References: <20120321065140.13852.52315.stgit@zurg> <20120321100602.GA5522@barrios>
 <4F69D496.2040509@openvz.org> <20120322142647.42395398.akpm@linux-foundation.org>
 <20120322212810.GE6589@ZenIV.linux.org.uk> <20120322144122.59d12051.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Mar 2012 15:08:43 -0700
Message-ID: <CA+55aFzbhYvw7Am9EYgatpjTknBFm9eq+3jBWQHkSCUpnb3HRQ@mail.gmail.com>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Thu, Mar 22, 2012 at 2:41 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>>
>> Use __bitwise for that - check how gfp_t is handled.
>
> So what does __nocast do?

__nocast warns about explicit or implicit casting to different types.

HOWEVER, it doesn't consider two 32-bit integers to be different
types, so a __nocast 'int' type may be returned as a regular 'int'
type and then the __nocast is lost.

So "__nocast" on integer types is usually not that powerful. It just
gets lost too easily. It's more useful for things like pointers. It
also doesn't warn about the mixing: you can add integers to __nocast
integer types, and it's not really considered anything wrong.

__bitwise ends up being a "stronger integer separation". That one
doesn't allow you to mix with non-bitwise integers, so now it's much
harder to lose the type by mistake.

So basic rules is:

 - "__nocast" on its own tends to be more useful for *big* integers
that still need to act like integers, but you want to make it much
less likely that they get truncated by mistake. So a 64-bit integer
that you don't want to mistakenly/silently be returned as "int", for
example. But they mix well with random integer types, so you can add
to them etc without using anything special. However, that mixing also
means that the __nocast really gets lost fairly easily.

 - "__bitwise" is for *unique types* that cannot be mixed with other
types, and that you'd never want to just use as a random integer (the
integer 0 is special, though, and gets silently accepted iirc - it's
kind of like "NULL" for pointers). So "gfp_t" or the "safe endianness"
types would be __bitwise: you can only operate on them by doing
specific operations that know about *that* particular type.

Generally, you want __bitwise if you are looking for type safety.
"__nocast" really is pretty weak.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
