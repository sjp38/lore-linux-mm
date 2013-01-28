Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 356CF6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 21:59:19 -0500 (EST)
Date: Mon, 28 Jan 2013 11:59:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
Message-ID: <20130128025917.GA3321@blaptop>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
 <51029FC3.4060402@linux.vnet.ibm.com>
 <b3ab2d2f-a0a1-44ff-ac8f-bb0ed73d8978@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3ab2d2f-a0a1-44ff-ac8f-bb0ed73d8978@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, Jan 25, 2013 at 07:56:29AM -0800, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
> > 
> > On 01/24/2013 07:33 PM, Minchan Kim wrote:
> > > Hi Seth, frontswap guys
> > >
> > > On Tue, Jan 8, 2013 at 5:24 AM, Seth Jennings
> > > <sjenning@linux.vnet.ibm.com> wrote:
> > >> zs_create_pool() currently takes a gfp flags argument
> > >> that is used when growing the memory pool.  However
> > >> it is not used in allocating the metadata for the pool
> > >> itself.  That is currently hardcoded to GFP_KERNEL.
> > >>
> > >> zswap calls zs_create_pool() at swapon time which is done
> > >> in atomic context, resulting in a "might sleep" warning.
> > >
> > > I didn't review this all series, really sorry but totday I saw Nitin
> > > added Acked-by so I'm afraid Greg might get it under my radar. I'm not
> > > strong against but I would like know why we should call frontswap_init
> > > under swap_lock? Is there special reason?
> > 
> > The call stack is:
> > 
> > SYSCALL_DEFINE2(swapon.. <-- swapon_mutex taken here
> > enable_swap_info() <-- swap_lock taken here
> > frontswap_init()
> > __frontswap_init()
> > zswap_frontswap_init()
> > zs_create_pool()
> > 
> > It isn't entirely clear to me why frontswap_init() is called under
> > lock.  Then again, I'm not entirely sure what the swap_lock protects.
> >  There are no comments near the swap_lock definition to tell me.
> > 
> > I would guess that the intent is to block any writes to the swap
> > device until frontswap_init() has completed.
> > 
> > Dan care to weigh in?
> 
> I think frontswap's first appearance needs to be atomic, i.e.
> the transition from (a) frontswap is not present and will fail
> all calls, to (b) frontswap is fully functional... that transition
> must be atomic.  And, once Konrad's module patches are in, the
> opposite transition must be atomic also.  But there are most
> likely other ways to do those transitions atomically that
> don't need to hold swap_lock.

It could be raced once swap_info is registered.
But what's the problem if we call frontswap_init before calling
_enable_swap_info out of lock?
Swap subsystem never do I/O before it register new swap_info_struct.

And IMHO, if frontswap is to be atomic, it would be better to have
own scheme without dependency of swap_lock if it's possible.
> 
> Honestly, I never really focused on the initialization code
> so I am very open to improvements as long as they work for
> all the various frontswap backends.

How about this?
