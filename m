Message-ID: <41F68BE6.3090704@ammasso.com>
Date: Tue, 25 Jan 2005 12:11:50 -0600
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: Re: Query on remap_pfn_range compatibility
References: <OF0A92B996.F674A9A0-ON86256F93.0066BC3F@raytheon.com>
In-Reply-To: <OF0A92B996.F674A9A0-ON86256F93.0066BC3F@raytheon.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark_H_Johnson@raytheon.com wrote:


> I am also trying to avoid an ugly hack like the following:
> 
>   VMA_PARAM_IN_REMAP=`grep remap_page_range
> $PATH_LINUX_INCLUDE/linux/mm.h|grep vma`
>   if [ -z "$VMA_PARAM_IN_REMAP" ]; then
>     export REMAP_PAGE_RANGE_PARAM="4"
>   else
>     export REMAP_PAGE_RANGE_PARAM="5"
>   endif

My makefile has a ton of stuff like this. Our driver needs to work with 
all 2.4 and 2.6 kernels, and it makes heavy use of the VM.  It also 
needs to deal with distros that have "broken" header files.

This wouldn't be such a problem if the kernel developers would add 
macros to indicate the version of the function parameters.  Basically, 
the header file should define REMAP_PAGE_RANGE_PARAM (or some 
equivalent), so that you don't need to calculate it in your makefile. 
But the kernel developers don't care about backwards compatibility, so 
we're stuck with these ugly hacks.

> Would it be acceptable to add a symbol like
>   #define MM_VM_REMAP_PFN_RANGE
> in include/linux/mm.h or is that too much of a hack as well?

The easiest solution would be to update gcc to provide some kind of 
internal macro that would tell me if a function is defined or not.  For 
instance, I could do this:

#if defined(remap_pfn_range)
remap_pfn_range(...)
#else
remap_page_range(...)
#endif

This doesn't work because remap_pfn_range is a function, not a macro. 
Then we could do other things like:

#if parameters(remap_page_range) = 4
remap_page_range(a, b, c, d)
#else
remap_page_range(a, b, c, d, e)
#endif

This would allow me to handle kernel versions that have 4 instead of 5 
parameters for remap_page_range().

Ironically, even if gcc were updated like this, it wouldn't help me a 
whole lot, because I still need to use the older versions of gcc on the 
older distros.  But at least it the problem wouldn't be getting worse, 
like it is today.

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
