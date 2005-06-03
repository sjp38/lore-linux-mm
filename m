Date: Thu, 02 Jun 2005 22:42:52 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Avoiding external fragmentation with a placement policy Version 12
Message-ID: <358040000.1117777372@[10.10.2.4]>
In-Reply-To: <20050602.223712.41634750.davem@davemloft.net>
References: <1117770488.5084.25.camel@npiggin-nld.site><20050602.214927.59657656.davem@davemloft.net><357240000.1117776882@[10.10.2.4]> <20050602.223712.41634750.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: nickpiggin@yahoo.com.au, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


--"David S. Miller" <davem@davemloft.net> wrote (on Thursday, June 02, 2005 22:37:12 -0700):

> From: "Martin J. Bligh" <mbligh@mbligh.org>
> Date: Thu, 02 Jun 2005 22:34:42 -0700
> 
>> One of the calls I got the other day was for loopback interface. 
>> Default MTU is 16K, which seems to screw everything up and do higher 
>> order allocs. Turning it down to under 4K seemed to fix things. I'm 
>> fairly sure loopback doesn't really need phys contig memory, but it 
>> seems to use it at the moment ;-)
> 
> It helps get better bandwidth to have larger buffers.
> That's why AF_UNIX tries to use larger orders as well.

Though surely the reality will be that after your system is up for a 
while, and is thorougly fragmented, your latency becomes frigging horrible 
for most allocs though? You risk writing a crapload of pages out to disk
for every alloc ...

> With all these processors using prefetching in their
> memcpy() implementations, reducing the number of memcpy()
> calls per byte is getting more and more important.
> Each memcpy() call makes you hit the memory latency
> cost since the first prefetch can't be done early
> enough.

but it's vastly different order of magnitude than touching disk.
Can we not do a "sniff alloc" first (ie if this is easy, give it
to me, else just fail and return w/o reclaim), then fall back to
smaller allocs? Though I suspect the reality is that on any real
system, a order 4 alloc will never actually succeed in any sensible
amount of time anyway? Perhaps us lot just reboot too often ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
