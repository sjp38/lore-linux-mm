Message-ID: <48C5247A.1030801@evidence.eu.com>
Date: Mon, 08 Sep 2008 15:11:22 +0200
From: Claudio Scordino <claudio@evidence.eu.com>
MIME-Version: 1.0
Subject: Re: Warning message when compiling ioremap.c
References: <48BCED2A.6030109@evidence.eu.com> <20080903140140.333bc137@doriath.conectiva>
In-Reply-To: <20080903140140.333bc137@doriath.conectiva>
Content-Type: multipart/mixed;
 boundary="------------090309050101040006030104"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: linux-mm@kvack.org, philb@gnu.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090309050101040006030104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Luiz Fernando N. Capitulino ha scritto:
> Em Tue, 02 Sep 2008 09:37:14 +0200
> Claudio Scordino <claudio@evidence.eu.com> escreveu:
> 
> | Hi,
> | 
> |        I'm not skilled with MM at all, so sorry if I'm saying something
> | stupid.
> | 
> | When compiling Linux (latest kernel from Linus' git) on ARM, I noticed 
> | the following warning:
> | 
> | CC      arch/arm/mm/ioremap.o
> | arch/arm/mm/ioremap.c: In function '__arm_ioremap_pfn':
> | arch/arm/mm/ioremap.c:83: warning: control may reach end of non-void
> | function 'remap_area_pte' being inlined
> | 
> | According to the message in the printk, we go to "bad" when the page
> | already exists.
> 
>  You see that right before the return you have added there is a
> BUG() macro? That macro will call panic(), this means that this
> function will never return if it reaches that point.

Well, probably BUG() doesn't call panic() always. For instance, in
arch/arm/include/asm/bug.h in case CONFIG_DEBUG_BUGVERBOSE is defined
(and it might be), BUG just causes an oops (by dereferencing a NULL
pointer). If I'm not wrong this doesn't always mean a panic...

However, in any case, the handler of pagefault eventually calls
do_exit(), so you're right: what follows BUG() won't be executed.

>  If all you want is to silent gcc, you should remove the goto and
> move the bad label contents there.
> 
>  This is minor, but I see no need for the goto.

Yes, it's obviously minor. But I don't like having meaningless
warnings during compilation: they just confuse output, and people may
miss some important warning message...

The need for the goto exists only if BUG() can return, and it doesn't, 
so we can safely remove it as you suggested.

Who's in charge of maintaining this piece of code? Should the patch in 
attachment be submitted to some specific person?

Many thanks,

         Claudio

--------------090309050101040006030104
Content-Type: text/x-diff;
 name="0001-Fix-compilation-warning-in-remap_area_pte.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-Fix-compilation-warning-in-remap_area_pte.patch"


--------------090309050101040006030104--
