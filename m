Date: Wed, 28 Jul 2004 12:47:19 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Use of __pa() with CONFIG_NONLINEAR
Message-ID: <35960000.1091044039@flay>
In-Reply-To: <20040728181645.GA13758@w-mikek2.beaverton.ibm.com>
References: <1090965630.15847.575.camel@nighthawk> <20040728181645.GA13758@w-mikek2.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>> So, for CONFIG_NONLINEAR, we introduce a new indirection layer for
>> virtual to physical conversions (and the inverse as well).  Our
>> implementation uses some data structures to do this (patch is here:
>> http://lwn.net/Articles/79124/), and the side-effect is that we can't
>> use __pa() or __va() until after the initialization has run, which is
>> early in setup_arch().
>> 
>> But, there are quite a few things that obviously need physical addresses
>> earlier than that, such as cr3 initialization at compile-time.  So, in
>> Dave McCracken's patch, he introduced a new function: __boot_pa() that
>> does what the old __pa() did.
>> 
> 
> As Joel Stated in another note, I think documentation/comments is a must.
> My 'guess' is that anyone writing early init code is going to have a
> difficult time here.  As you stated the memsection initialization would
> happen in setup_arch().  For arch independent code this makes it pretty
> straight forward as everything run before the setup_arch() can use
> the old/offset method of calculating physical addresses and everything
> after can use the new method.  However, the arch specific initialization
> code is more difficult as it depends on where the call paths are relative
> to setup/alloc_memsections within setup_arch().
> 
> When I was trying to get nonlinear working on a specific architecture,
> I made the routines go through 'pointer to functions' and had the memsections
> initialization code modify the pointer after initialization was complete.
> In this way, I got the nonlinear code code up and working without changing
> all the early __pa/__va calls.  Obviously, this is a hack that should not
> be used as it introduces another level of indirection to performance
> critical code.  However, it was easy and saved me the effort of all that
> code inspection. :)

Can someone explain the necessity to create the new address space? We don't
need it with the current holes between nodes, and from my discssions with
Andy, I'm now unconvinced it's necessary.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
