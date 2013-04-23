Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2829A6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 01:06:42 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id p1so138747dad.34
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 22:06:41 -0700 (PDT)
Message-ID: <517616DD.2010005@converseincode.com>
Date: Tue, 23 Apr 2013 00:06:37 -0500
From: Behan Webster <behanw@converseincode.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
References: <1366225776.8817.28.camel@pippen.local.home>  <alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>  <20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org> <1366664301.9609.140.camel@gandalf.local.home>
In-Reply-To: <1366664301.9609.140.camel@gandalf.local.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On 13-04-22 03:58 PM, Steven Rostedt wrote:
> On Mon, 2013-04-22 at 13:44 -0700, Andrew Morton wrote:
>> On Wed, 17 Apr 2013 17:03:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
>>
>>> On Wed, 17 Apr 2013, Steven Rostedt wrote:
>>>
>>>> The slab.c code has a size check macro that checks the size of the
>>>> following structs:
>>>>
>>>> struct arraycache_init
>>>> struct kmem_list3
>>>>
>>>> The index_of() function that takes the sizeof() of the above two structs
>>>> and does an unnecessary __builtin_constant_p() on that. As sizeof() will
>>>> always end up being a constant making this always be true. The code is
>>>> not incorrect, but it just adds added complexity, and confuses users and
>>>> wastes the time of reviewers of the code, who spends time trying to
>>>> figure out why the builtin_constant_p() was used.
>>>>
>>>> This patch is just a clean up that makes the index_of() code a little
>>>> bit less complex.
>>>>
>>>> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
>>> Acked-by: David Rientjes <rientjes@google.com>
>>>
>>> Adding Pekka to the cc.
>> I ducked this patch because it seemed rather pointless - but a little
>> birdie told me that there is a secret motivation which seems pretty
>> reasonable to me.  So I shall await chirp-the-second, which hopefully
>> will have a fuller and franker changelog ;)
> <little birdie voice>
> The real motivation behind this patch was it prevents LLVM (Clang) from
> compiling the kernel. There's currently a bug in Clang where it can't
> determine if a variable is constant or not, so instead, when
> __builtin_constant_p() is used, it just treats it like it isn't a
> constant (always taking the slow *safe* path).
>
> Unfortunately, the "confusing" code of slub.c that unnecessarily uses
> the __builtin_constant_p() will fail to compile if the variable passed
> in is not constant. As Clang will say constants are not constant at this
> point, the compile fails.
>
> When looking into this, we found the only two users of the index_of()
> static function that has this issue, passes in size_of(), which will
> always be a constant, making the check redundant.
>
> Note, this is a bug in Clang that will hopefully be fixed soon. But for
> now, this strange redundant compile time check is preventing Clang from
> even testing the Linux kernel build.
> </little birdie voice>
>
> And I still think the original change log has rational for the change,
> as it does make it rather confusing to what is happening there.
>
> -- Steve
Just to pipe up since Steve was helping me out with this patch.

I just want to make it clear that in no way am I trying to sneak any 
code into the kernel in order to merely support Clang (certainly the 
motivation for the patch wasn't meant to be a secret). That in this case 
the code might be considered clearer at the same time as enabling Clang 
to be used to compile this portion of code seemed to be a win-win 
situation to me.

I certainly thank Steve, Christoph and Andrew for their support in 
principle in this particular matter (not that it is yet a done deal). I 
merely complained about this particular issue at my talk at the recent 
Collab Summit and Steve jumped in to follow up with this particular 
solution as well as connecting up myself with the three of them (all of 
us being in the same hotel in San Francisco at the same time). My god 
Steve works fast! It made my head spin.

My motivation (as a part of the LLVMLinux project) is purely to provide 
another choice of toolchain to the kernel developer and system 
integrator, some of whom would like the choice of using (or at least 
trying) Clang. I certainly do not intentionally want to negatively 
impact the performance nor code quality of the kernel code base to the 
best of my ability (quite the opposite actually).

I think I can safely say that the competition between the 2 toolchains 
has already made both even stronger than they were previously (certainly 
gcc 4.8 and the upcoming LLVM/Clang 3.3 seem to be the best either have 
ever been).

As far as __builtin_constant_p() in clang goes, it gets it right in many 
places (i.e. agrees with how gcc evaluates it), but in this particular 
situation it got it wrong. However, in this case I was having troubles 
understanding why __builtin_constant_p() was being used the way it was 
in slab.c at all...

Behan

-- 
Behan Webster
behanw@converseincode.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
