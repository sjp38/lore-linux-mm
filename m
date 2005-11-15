Date: Tue, 15 Nov 2005 01:50:08 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 01/05] mm fix __alloc_pages cpuset ALLOC_* flags
Message-Id: <20051115015008.55d5a25e.pj@sgi.com>
In-Reply-To: <4379A1C4.509@yahoo.com.au>
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>
	<4379A1C4.509@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon.Derr@bull.net, clameter@sgi.com, rohit.seth@intel.com
List-ID: <linux-mm.kvack.org>

Nick wrote:
> I was under the impression that you
> introduced the exception reverted in #2 due to seeing atomic
> allocation failures?!

For the record, the discussion Nick is recalling starts here:

  http://www.ussg.iu.edu/hypermail/linux/kernel/0503.3/0763.html

My motivation for letting GFP_ATOMIC requests escape cpuset confinement
was not based on seeing real world events, but based on code reading.

If some GFP_ATOMIC requests fail, the system can panic.  Apparently
these allocations are in init and setup code, where only a really
sick system could fail a kmalloc() anyway.  But, back then in March
2005, I concluded that GFP_ATOMIC requests were the absolute most
essential allocations to satisfy, at all costs, cpusets be damned.

This time around, when reading __alloc_pages() again, I realized that
GFP_ATOMIC requests did not get the highest priority in setting
watermarks.  Even they had to leave some reserves behind.  The only
allocations allowed to ignore all mins were the special case of
allocations that promised to free more memory than they were consuming,
really soon now (such as an exiting task).

I figured this time that what's good for watermark setting is good for
cpuset setting.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
