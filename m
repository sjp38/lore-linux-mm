Message-ID: <45A6DAA2.8070605@yahoo.com.au>
Date: Fri, 12 Jan 2007 11:47:30 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 2.6.20-rc4 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
References: <20070111142427.GA1668@localhost>	 <20070111133759.d17730a4.akpm@osdl.org> <45a44e480701111622i32fffddcn3b4270d539620743@mail.gmail.com>
In-Reply-To: <45a44e480701111622i32fffddcn3b4270d539620743@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jaya Kumar wrote:
> On 1/11/07, Andrew Morton <akpm@osdl.org> wrote:
> 
>> That's all very interesting.
>>
>> Please don't dump a bunch of new implementation concepts like this on us
>> with no description of what it does, why it does it and why it does it in
>> this particular manner.
> 
> 
> Hi Andrew,
> 
> Actually, I didn't dump without description. :-) I had posted an RFC
> and an explanation of the design to the lists. Here's an archive link
> to that post. 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=116583546411423&w=2
> I wasn't sure whether to include that description with the patch email
> because it was long.
> 
>> From that email:
> 
> ---
> This is there in order to hide the latency
> associated with updating the display (500ms to 800ms). The method used
> is to fake a framebuffer in memory. Then use pagefaults followed by delayed
> unmaping and only then do the actual framebuffer update. To explain this
> better, the usage scenario is like this:
> 
> - userspace app like Xfbdev mmaps framebuffer
> - driver handles and sets up nopage and page_mkwrite handlers
> - app tries to write to mmaped vaddress
> - get pagefault and reaches driver's nopage handler
> - driver's nopage handler finds and returns physical page ( no
>  actual framebuffer )
> - write so get page_mkwrite where we add this page to a list
> - also schedules a workqueue task to be run after a delay
> - app continues writing to that page with no additional cost
> - the workqueue task comes in and unmaps the pages on the list, then
>  completes the work associated with updating the framebuffer

Have you thought about implementing a traditional write-back cache using
the dirty bits, rather than unmapping the page?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
