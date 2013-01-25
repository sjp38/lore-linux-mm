Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6E08A6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:09:40 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 10:09:39 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0EDFB38C8054
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:09:38 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PF9bcK343532
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:09:37 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PF7sxr021274
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 08:08:06 -0700
Message-ID: <51029FC3.4060402@linux.vnet.ibm.com>
Date: Fri, 25 Jan 2013 09:07:47 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com> <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
In-Reply-To: <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/24/2013 07:33 PM, Minchan Kim wrote:
> Hi Seth, frontswap guys
> 
> On Tue, Jan 8, 2013 at 5:24 AM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
>> zs_create_pool() currently takes a gfp flags argument
>> that is used when growing the memory pool.  However
>> it is not used in allocating the metadata for the pool
>> itself.  That is currently hardcoded to GFP_KERNEL.
>>
>> zswap calls zs_create_pool() at swapon time which is done
>> in atomic context, resulting in a "might sleep" warning.
> 
> I didn't review this all series, really sorry but totday I saw Nitin
> added Acked-by so I'm afraid Greg might get it under my radar. I'm not
> strong against but I would like know why we should call frontswap_init
> under swap_lock? Is there special reason?

The call stack is:

SYSCALL_DEFINE2(swapon.. <-- swapon_mutex taken here
enable_swap_info() <-- swap_lock taken here
frontswap_init()
__frontswap_init()
zswap_frontswap_init()
zs_create_pool()

It isn't entirely clear to me why frontswap_init() is called under
lock.  Then again, I'm not entirely sure what the swap_lock protects.
 There are no comments near the swap_lock definition to tell me.

I would guess that the intent is to block any writes to the swap
device until frontswap_init() has completed.

Dan care to weigh in?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
