Message-ID: <20000828154744.A3741@saw.sw.com.sg>
Date: Mon, 28 Aug 2000 15:47:44 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Question: memory management and QoS
References: <39A4F548.B8EB5308@tuke.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39A4F548.B8EB5308@tuke.sk>; from "Jan Astalos" on Thu, Aug 24, 2000 at 12:13:28PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: linux-mm@kvack.org, Yuri Pudgorodsky <yur@asplinux.ru>
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Aug 24, 2000 at 12:13:28PM +0200, Jan Astalos wrote:
[snip]
> 
> So, why am I writing this to this list ? In last couple of days
> I was experimenting with Linux MM subsystem to find out whether
> Linux can (how it could) assure exclusive access to some amount 
> of memory for user. Of course I was searching the archives. So 
> far, I found only the beancounter patch, which is designed for 
> limiting of memory usage. This is not quite exactly what I am 
> looking for. Rather, users should have their memory reserved... 
> 
> If I missed something please send me the pointers.

Well, the main goal of the memory management part of user beancounter patch
is exactly QoS.  It allows to control how to share resources between
accounting subjects and specify the minimal amount of resources that are
guaranteed to be available to them.  These minimal amounts are the guaranteed
level of service, the remaining resources are provided on a best-effort
basis, doing it more or less fairly.  The mentioned resources are total
amount of memory, and in-core memory (as opposite to swap).

The code implementing this kind of QoS has been in user beancounter patch
since version IV-0006.  See
ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/
ftp://ftp.swusa.com/pub/Linux/people/saw/kernel/user_beancounter/
The current code is dirty and incomplete, so questions (and comments) are
welcome.

The patch also contains some upper limits on virtual address space.  But they
don't play any significant role, clearly being not a QoS or DoS protection
mechanism.

> 
> I have some (rough) ideas how it could work and I would be 
> happy if you'll send me your opinions.
> 
> Concept of personal swapfiles:
[snip]

I don't think that personal swapfiles is an efficient approach to achieve
QoS.  Most of the space will be reserved for exceptional cases, and, thus,
wasted, as Yuri has mentioned.  A shared swap space allowing exceeding the
guaranteed amount (if the memory isn't really used) is much more efficient
spending of the space.  If the system has some spare memory, users exceeding
their limits may still use it (but, certainly, only if only some of them, not
all, exceed the limits).  Moreover, if some users don't consume all the
memory guaranteed to them, others may temporarily use it.

Best regards
					Andrey V.
					Savochkin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
