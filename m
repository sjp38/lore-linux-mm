Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D37F6B01C4
	for <linux-mm@kvack.org>; Mon, 31 May 2010 06:45:08 -0400 (EDT)
Message-ID: <4C03932F.8000303@cesarb.net>
Date: Mon, 31 May 2010 07:45:03 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH] Make kunmap_atomic() harder to misuse
References: <1275043993-26557-1-git-send-email-cesarb@cesarb.net> <20100529204256.b92b1ff6.akpm@linux-foundation.org> <201005311945.19784.rusty@rustcorp.com.au>
In-Reply-To: <201005311945.19784.rusty@rustcorp.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

Em 31-05-2010 07:15, Rusty Russell escreveu:
> On Sun, 30 May 2010 01:12:56 pm Andrew Morton wrote:
>> On Fri, 28 May 2010 07:53:13 -0300 Cesar Eduardo Barros<cesarb@cesarb.net>  wrote:
>>> +/* Prevent people trying to call kunmap_atomic() as if it were kunmap() */
>>> +struct __kunmap_atomic_dummy {};
>>> +#define kunmap_atomic(addr, idx) do { \
>>> +		BUILD_BUG_ON( \
>>> +			__builtin_types_compatible_p(typeof(addr), struct page *)&&  \
>>> +			!__builtin_types_compatible_p(typeof(addr), struct __kunmap_atomic_dummy *)); \
>>> +		kunmap_atomic_notypecheck((addr), (idx)); \
>>> +	} while (0)
>>
>> We have a little __same_type() helper for this.  __must_be_array()
>> should be using it, too.
>
> Yep... but I think BUILD_BUG_ON(__same_type((addr), struct page *)); is
> sufficient; void * is not compatible in my quick tests here.

That is what I get for only reading the manual instead of testing :(

(I only tested the completed patch, not each step along the way.)

I will try it later today and make a new patch if it works as expected.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
