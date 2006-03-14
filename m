Message-ID: <4416432E.1050904@yahoo.com.au>
Date: Tue, 14 Mar 2006 15:14:38 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: A lockless pagecache for Linux
References: <20060207021822.10002.30448.sendpatchset@linux.site> <Pine.LNX.4.64.0603131528180.13687@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603131528180.13687@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 10 Mar 2006, Nick Piggin wrote:
> 
> 
>>I'm writing some stuff about these patches, and I've uploaded a
>>**draft** chapter on the RCU radix-tree, 'radix-intro.pdf' in above
>>directory (note the bibliography didn't make it -- but thanks Paul
>>McKenney!)
> 
> 
> Ah thanks. I had a look at it. Note that the problem with the radix tree 
> tags is that these are inherited from the lower layer. How is the 
> consistency of these guaranteed? Also you may want to add a more elaborate 
> intro and conclusion. Typically these summarize other sections of the 
> paper.
> 

Thanks for looking at it. Yeah in the intro I say that I'm considering
a simplified radix-tree (without tags or gang lookups) to start with.
At the end I say how tags are handled... it isn't quite clear enough
for my liking yet though.

Intro and conclusion - yes they should be better. It _is_ a chapter from
a larger document, however I want it to still stand alone as a good
document.

What happens is: read-side tag operations (ie. tag lookups etc) are done
under lock. Ie. they are not made lockless.

> What you are proposing is to allow lockless read operations right? No 
> lockless write? The concurrency issue that we currently have is multiple 
> processes faulting in pages in different ranges from the same file. I 
> think this is a rather typical usage scenario. Faulting in a page from a 
> file for reading requires a write operation on the radix tree. The 
> approach with a lockless read path does not help us. This proposed scheme 
> would only help if pages are already faulted in and another process starts
> using the same pages as an earlier process.
> 

Yep, lockless reads only to start with. I think you'll see some benefit
because the read(2) and ->nopage paths also take read-side locks, so your
write side will no longer have to contend with them.

It won't be a huge improvement in scalability though, maybe just a constant
factor.

> Would it not be better to handle the radix tree in the same way as a page 
> table? Have a lock at the lowest layer so that different sections of the 
> radix tree can be locked by different processes? That would enable 
> concurrent writes.
> 

Yeah this is the next step. Note that it is not the first step because I
actually want to _speed up_ single threaded lookup paths, rather than
slowing them down, otherwise it will never get accepted.

It also might add quite a large amount of complexity to the radix tree, so
it may no longer be suitable for a generic data structure anymore (depends
how it is implemented). But the write side should be easier than the
read-side so I don't think there is too much to worry about. I already have
some bits and pieces to make it fine-grained.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
