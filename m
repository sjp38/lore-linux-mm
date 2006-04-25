Message-ID: <444DFF4D.8050108@yahoo.com.au>
Date: Tue, 25 Apr 2006 20:51:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase>	 <20060424180138.52e54e5c.akpm@osdl.org> <1145952628.5282.8.camel@localhost>	  <444DDD1B.4010202@yahoo.com.au> <1145961386.5282.37.camel@localhost>
In-Reply-To: <1145961386.5282.37.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> On Tue, 2006-04-25 at 18:26 +1000, Nick Piggin wrote:

>>I don't think there is any beauty in this scheme, to be honest.
> 
> 
> Beauty lies in the eye of the beholder. From my point of view there is
> benefit to the method.

That's 'cause you have an s390.

> 
> 
>>I don't see why calling into the host is bad - won't it be able to
>>make better reclaim decisions? If starting IO is the wrong thing to
>>do under a hypervisor, why is it the right thing to do on bare metal?
> 
> 
> First some assumptions about the environment. We are talking about a
> paging hypervisor that runs several hundreds of guest Linux images. The
> memory is overcommited, the sum of the guest memory sizes is larger than
> the host memory by a factor of 2-3. Usually a large percentage of the
> guests memory is paged out by the hypervisor.
> 
> Both the host and the guest follow an LRU strategy. That means that the
> host will pick the oldest page from the idlest guest. Almost the same
> would happen if you call into the idlest guest to let the guest free its
> oldest page. But the catch is that the guest will touch a lot of page
> doing its vmscan operation, if that causes a single additional host i/o
> because a guest page needs to be retrieved from the host swap device,
> you are already in negative territory.

Why would most guest memory be paged out if the host reclaims by first
asking guests to reclaim, *then* paging them out?

I can understand that you observe most guest memory to be paged out
under pressure with the present scheme, but the dynamics will completely
change I think... You'll be left with shrunk guests, which you could
then mark as unreclaimable, stop asking them to reclaim, then page the
rest of their memory out from the host.

 > It does attempt to keep some memory free. But lets say 1000 guest images
 > generate a lot of memory pressure. You will run out of memory, and
 > anything that speeds up the host reclaim will improve the situation. And

I believe that, and I'm sure there are lots of really invasive things you
could do to make it even faster...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
