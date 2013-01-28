Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C5FFE6B0005
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:05:09 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 12:04:40 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2EEF1C90045
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:02:09 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SH268d246220
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:02:06 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SH3p5N022041
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 10:03:51 -0700
Message-ID: <5106AEE8.4060003@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 11:01:28 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] staging: zsmalloc: add gfp flags to zs_create_pool
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com> <20130128033944.GB3321@blaptop>
In-Reply-To: <20130128033944.GB3321@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/27/2013 09:39 PM, Minchan Kim wrote:
> Hi Seth,
> 
> On Fri, Jan 25, 2013 at 11:46:15AM -0600, Seth Jennings wrote:
>> zs_create_pool() currently takes a gfp flags argument
>> that is used when growing the memory pool.  However
>> it is not used in allocating the metadata for the pool
>> itself.  That is currently hardcoded to GFP_KERNEL.
>>
>> zswap calls zs_create_pool() at swapon time which is done
>> in atomic context, resulting in a "might sleep" warning.
>>
>> This patch changes the meaning of the flags argument in
>> zs_create_pool() to mean the flags for the metadata allocation,
>> and adds a flags argument to zs_malloc that will be used for
>> memory pool growth if required.
> 
> As I mentioned, I'm not strongly against with this patch but it
> should be last resort in case of not being able to address
> frontswap's init routine's dependency with swap_lock.
> 
> I sent a patch and am waiting reply of Konrand or Dan.
> If we can fix frontswap, it would be better rather than
> changing zsmalloc.

I agree that moving the call to frontswap_init() out of the swap_lock
would be a good thing.  However, it doesn't mean that we still
shouldn't allow the users to control the gfp mask for the allocation
done by zs_create_pool(). While moving the frontswap_init() outside
the lock removes the _need_ for this patch, I think that is it good
API design to allow the user to specify the gfp mask.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
