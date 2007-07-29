Date: Sun, 29 Jul 2007 19:26:29 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: Sparc32 not working:2.6.23-rc1 (git commit
 1e4dcd22efa7d24f637ab2ea3a77dd65774eb005)
In-Reply-To: <20070729174535.9eb6d0aa.krzysztof.h1@wp.pl>
Message-ID: <Pine.LNX.4.61.0707291900010.31211@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707281903350.27869@mtfhpc.demon.co.uk>
 <20070728234856.0fb78952.krzysztof.h1@wp.pl> <20070729003855.1c5422ed.krzysztof.h1@wp.pl>
 <Pine.LNX.4.61.0707290011300.28457@mtfhpc.demon.co.uk>
 <20070729174535.9eb6d0aa.krzysztof.h1@wp.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Krzysztof Helt <krzysztof.h1@wp.pl>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 29 Jul 2007, Krzysztof Helt wrote:

> On Sun, 29 Jul 2007 00:21:06 +0100 (BST)
> Mark Fortescue <mark@mtfhpc.demon.co.uk> wrote:
>
>> Hi Krzysztof,
>>
>> There have been lots of changes to the DMA system (git bisect is not
>> viable form my working 2.6.22 kernel as the dma changes kill the build for
>> over half the posible commits to check). It could be a side effect of
>> these changes.
>>
>
> It is not DMA I suppose. It does not happen in any specific place. It is easy to trigger by loading
> and unloading the sunlance module, but it hangs linux in other places (init process, console login).
>
> It happens only in SMP. If it happens in the sunlance module it happens in sparc_lance_probe_one()
> (in probing function). I thought it is due to openprom accesses so I commented them out (and put
> hardcoded values there). No real change. It is always in the probe_one method before any DMA is
> started.
>
> Sometimes it drops me to the prom prompt. I am not very experienced so I was able only to find (ctrace) that
> the prompt was called in the method spwin_bad_ustack_from_kernel() which got there from mna_handler
> (misaligned access) through kernel_unaligned_trap(). I don't know which function triggered the
> unaligned access. The %o register values sent to the kernel_unaligned_trap() are outside addresses
> from System.map and outside addresses of loaded (or just loaded the sunlance) modules.
>
> This is where I need help. How can I find where the misaligned access happened?
>

The is a memory corruption issue on Sparc32 - sun4c (I am going to try and 
track it done over the next few days). It sounds like it may affect more 
than just sun4c issue.

Try going back to v2.6.22 and then appling 
f61698e6489f229f9fcfe29e68f228389a772993 - memset.S error, 
196bffa5dc3181897bd32e41415ec0db8dbab5e7 - entry.S delay loops,
f3c681c028846bd5d39f563909409832a295ca69 - Serial Console Locking

(My last working kernel is v2.6.22 Commit
eb6bf6bfb580afaf1e1a1d30cba17a078530cf4 with the first of the above two 
patches applied and some additional ones that fix verious sun 
partition/UFS filing sustem issues).

I am going to try to cherry pick a set of commits to see if I can't get a 
better idear of where the memory corruption on sun4c is coming from. Build 
problems sue to the DMA changes make git bisecting un-usable untill I have 
found out which patches fix the DMA build issues.

> Regards,
> Krzysztof
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
