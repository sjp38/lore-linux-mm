Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9QLR5Ex540922
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 17:27:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9QLR5Jm418502
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 15:27:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9QLR5Pw004545
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 15:27:05 -0600
Subject: Re: [Lhms-devel] Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <417EBFB3.5000803@kolumbus.fi>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>
	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>
	 <1098824141.6188.1.camel@localhost>  <417EBFB3.5000803@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1098826023.7172.4.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 14:27:03 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-26 at 14:20, Mika Penttila wrote:
> "There are two problems that are being solved: having a sparse layout
> requiring splitting up mem_map (solved by discontigmem and your
> nonlinear), and supporting non-linear phys to virt relationships (Dave
> M's implentation which does the mem_map split as well)."
> 
> 
> so what's the split?

So, mem_map is normally laid out so that, if you have 1GB of memory, the
memory for 0x00000000 is at mem_map[0], and the memory for the last page
(at 1GB - 1 page) is at mem_map[1<<30 / PAGE_SIZE - 1].  

That's fine and dandy for most systems.  But, imagine that you have some
memory on a funky machine where you have 2GB of memory, but it is laid
out like this:

    0-1 GB - first 1 GB
  1-100 GB - empty
100-101 GB - second 1 GB

Then, you'd need to have mem_map sized the same as a 101GB system on
your dinky 2GB system (disregard the ia64 implementation).

The split I'm referring to is cutting mem_map[] up into pieces for each
contiguous section of memory.  

Make sense?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
