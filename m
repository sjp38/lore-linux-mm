Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9E6896B00FE
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 18:52:10 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2985292bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:52:08 -0700 (PDT)
Message-ID: <4F6BAD15.90802@openvz.org>
Date: Fri, 23 Mar 2012 02:52:05 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg> <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org> <20120322142647.42395398.akpm@linux-foundation.org> <20120322212810.GE6589@ZenIV.linux.org.uk> <20120322144122.59d12051.akpm@linux-foundation.org> <4F6BA221.8020602@openvz.org> <4F6BA69F.1040707@openvz.org> <CA+55aFz4hWfT5c93rUWvN4OsYHjOSAjmNtoT7Rkjz7kYsaC7xg@mail.gmail.com>
In-Reply-To: <CA+55aFz4hWfT5c93rUWvN4OsYHjOSAjmNtoT7Rkjz7kYsaC7xg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

Linus Torvalds wrote:
> On Thu, Mar 22, 2012 at 3:24 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org>  wrote:
>>
>> # define __nocast       __attribute__((nocast))
>>
>> typedef long __nocast long_t;
>
> So the intention is that this really creates a *new* type.
>
> So "long_t" really is a different type from "long", but because
> __nocast is so weak, it happily casts to another integer type of the
> same size.
>
> But a pointer to it is different, the same way "int *" is different
> from "long *" even if "int" and "long" happen to have the same size.
> So I do think that the warning you quote is correct and expected:
>
>> 1.c:13:12: warning: incorrect type in argument 1 (different modifiers)
>> 1.c:13:12:    expected int [nocast] [usertype] *x
>> 1.c:13:12:    got int *<noident>
>> 1.c:13:12: warning: implicit cast to nocast type
>>
>> Is this ok?
>
> Yes.
>
> The thing about __nocast is that it's so *very* very easy to lose it.
> For example, do this:
>
>    typedef long __nocast long_t;
>
>    int main(long_t a)
>    {
>          return a;
>    }
>
> and you get the (expected) warning.
>
> HOWEVER. Now do "return a+1" instead, and the warning goes away. Why?
> Because the expression ends up having just the type "long", because
> the "a" mixed happily with the "1" (that was cast from 'int' to 'long'
> by the normal C type rules).
>
> That is arguably a bug, but this kind of thing really wasn't what
> __nocast was designed for. The __nocast design ended up being too
> weak, though, and we hardly use it in the kernel.
>

Thanks. Looks like "__nocast" totally undocumented.
It would be nice to add something about this into Documentation/sparse.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
