Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EF3FF6B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 12:45:35 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jan 2012 10:45:34 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0BHjUS7149100
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 10:45:31 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0BHjUMe027287
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 10:45:30 -0700
Message-ID: <4F0DCAA7.4000601@linux.vnet.ibm.com>
Date: Wed, 11 Jan 2012 11:45:11 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <<1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>> <b5b5a961-85e5-4ce1-8280-7ca382cb0e0f@default>
In-Reply-To: <b5b5a961-85e5-4ce1-8280-7ca382cb0e0f@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/11/2012 11:19 AM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
>>
>> From: Nitin Gupta <ngupta@vflare.org>
>>
>> This patch creates a new memory allocation library named
>> zsmalloc.
>>
>> +/*
>> + * Allocate a zspage for the given size class
>> + */
>> +static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>> +{
>> +	int i, error;
>> +	struct page *first_page = NULL;
>> +
>> +	/*
>> +	 * Allocate individual pages and link them together as:
>> +	 * 1. first page->private = first sub-page
>> +	 * 2. all sub-pages are linked together using page->lru
>> +	 * 3. each sub-page is linked to the first page using page->first_page
>> +	 *
>> +	 * For each size class, First/Head pages are linked together using
>> +	 * page->lru. Also, we set PG_private to identify the first page
>> +	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
>> +	 * identify the last page.
>> +	 */
>> +	error = -ENOMEM;
>> +	for (i = 0; i < class->zspage_order; i++) {
>> +		struct page *page, *prev_page;
>> +
>> +		page = alloc_page(flags);
> 
> Hmmm... I thought we agreed offlist that the new allocator API would
> provide for either preloads or callbacks (which may differ per pool)
> instead of directly allocating raw pages from the kernel.  The caller
> (zcache or ramster or ???) needs to be able to somehow manage maximum
> memory capacity to avoid OOMs.
> 
> Or am I missing the code that handles that?

No, you aren't missing it; it's not there.  And I agree that we
should add that.

However, the existing allocator, xvmalloc, doesn't support callback
functionality either.  Would it be simpler to add the that as 
a separate patch, that way we can keep the changes to zcache/zram
in this patchset isolated to just changing the xvmalloc calls to 
zsmalloc calls?

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
