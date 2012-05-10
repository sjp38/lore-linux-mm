Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 340796B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 13:39:32 -0400 (EDT)
Date: Thu, 10 May 2012 13:33:22 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
Message-ID: <20120510173322.GA30481@phenom.dumpdata.com>
References: <4FA33DF6.8060107@kernel.org>
 <20120509201918.GA7288@kroah.com>
 <4FAB21E7.7020703@kernel.org>
 <20120510140215.GC26152@phenom.dumpdata.com>
 <4FABD503.4030808@vflare.org>
 <4FABDA9F.1000105@linux.vnet.ibm.com>
 <20120510151941.GA18302@kroah.com>
 <4FABECF5.8040602@vflare.org>
 <20120510164418.GC13964@kroah.com>
 <4FABF9D4.8080303@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FABF9D4.8080303@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2012 at 01:24:36PM -0400, Nitin Gupta wrote:
> On 5/10/12 12:44 PM, Greg Kroah-Hartman wrote:
> >On Thu, May 10, 2012 at 12:29:41PM -0400, Nitin Gupta wrote:
> >>On 5/10/12 11:19 AM, Greg Kroah-Hartman wrote:
> >>>On Thu, May 10, 2012 at 10:11:27AM -0500, Seth Jennings wrote:
> >>>>On 05/10/2012 09:47 AM, Nitin Gupta wrote:
> >>>>
> >>>>>On 5/10/12 10:02 AM, Konrad Rzeszutek Wilk wrote:
> >>>>>>struct zs {
> >>>>>>     void *ptr;
> >>>>>>};
> >>>>>>
> >>>>>>And pass that structure around?
> >>>>>>
> >>>>>
> >>>>>A minor problem is that we store this handle value in a radix tree node.
> >>>>>If we wrap it as a struct, then we will not be able to store it directly
> >>>>>in the node -- the node will have to point to a 'struct zs'. This will
> >>>>>unnecessarily waste sizeof(void *) for every object stored.
> >>>>
> >>>>
> >>>>I don't think so. You can use the fact that for a struct zs var,&var
> >>>>and&var->ptr are the same.
> >>>>
> >>>>For the structure above:
> >>>>
> >>>>void * zs_to_void(struct zs *p) { return p->ptr; }
> >>>>struct zs * void_to_zs(void *p) { return (struct zs *)p; }
> >>>
> >>>Do like what the rest of the kernel does and pass around *ptr and use
> >>>container_of to get 'struct zs'.  Yes, they resolve to the same pointer
> >>>right now, but you shouldn't "expect" to to be the same.
> >>>
> >>>
> >>
> >>I think we can just use unsigned long as zs handle type since all we
> >>have to do is tell the user that the returned value is not a
> >>pointer. This will be less pretty than a typedef but still better
> >>than a single entry struct + container_of stuff.
> >
> >But then you are casting the thing all around just as much as you were
> >with the void *, right?
> >
> >Making this a "real" structure ensures type safety and lets the compiler
> >find the problems you accidentally create at times :)
> >
> 
> If we return a 'struct zs' from zs_malloc then I cannot see how we
> are solving the original problem of storing the handle directly in a
> radix node. If we pass a struct zs we will require pointing radix
> node to this struct, wasting sizeof(void *) for every object.   If
> we pass unsigned long, then this problem is solved and it also makes
> it clear that the passed value is not a pointer.

It is the same size: sizeof(struct zs) == sizeof(void *).
When you return the 'struct zs' it will be as if you are returning 
a void * pointer.

> 
> Its true that making it a real struct would prevent accidental casts
> to void * but due to the above problem, I think we have to stick
> with unsigned long.
> 
> Thanks,
> Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
