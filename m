Date: Fri, 15 Dec 2006 11:45:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Fix sparsemem on Cell
Message-Id: <20061215114536.dc5c93af.akpm@osdl.org>
In-Reply-To: <1166203440.8105.22.camel@localhost.localdomain>
References: <20061215165335.61D9F775@localhost.localdomain>
	<4582D756.7090702@shadowen.org>
	<1166203440.8105.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, mkravetz@us.ibm.com, hch@infradead.org, jk@ozlabs.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, gone@us.ibm.com, Keith Mannthey <kmannth@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Dec 2006 09:24:00 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> 
> ...
>
> I think the comments added say it pretty well, but I'll repeat it here.
> 
> This fix is pretty similar in concept to the one that Arnd posted
> as a temporary workaround, but I've added a few comments explaining
> what the actual assumptions are, and improved it a wee little bit.
> 
> The end goal here is to simply avoid calling the early_*() functions
> when it is _not_ early.  Those functions stop working as soon as
> free_initmem() is called.  system_state is set to SYSTEM_RUNNING
> just after free_initmem() is called, so it seems appropriate to use
> here.

Would really prefer not to do this.  system_state is evil.  Its semantics
are poorly-defined and if someone changes them a bit, or changes memory
initialisation order, you get whacked.

I think an mm-private flag with /*documented*/ semantics would be better. 
It's only a byte.

> +static int __meminit can_online_pfn_into_nid(unsigned long pfn, int nid)

I spent some time trying to work out what "can_online_pfn_into_nid" can
possibly mean and failed.  "We can bring a pfn online then turn it into a
NID"?  Don't think so.  "We can bring this page online and allocate it to
this node"?  Maybe.

Perhaps if the function's role in the world was commented it would be clearer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
