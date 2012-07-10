Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4E6346B0073
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:54:35 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 10 Jul 2012 11:54:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C0CD238C9506
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:29:50 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6AFTmPL056790
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:29:48 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6AFUng0029965
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 09:30:49 -0600
Message-ID: <4FFC4A61.3020601@linux.vnet.ibm.com>
Date: Tue, 10 Jul 2012 10:29:37 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] zsmalloc: remove x86 dependency
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-2-git-send-email-sjenning@linux.vnet.ibm.com> <4FFB91B8.5070009@kernel.org>
In-Reply-To: <4FFB91B8.5070009@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/09/2012 09:21 PM, Minchan Kim wrote:
> On 07/03/2012 06:15 AM, Seth Jennings wrote:
<snip>
>> +static void zs_copy_map_object(char *buf, struct page *firstpage,
>> +				int off, int size)
> 
> firstpage is rather misleading.
> As you know, we use firstpage term for real firstpage of zspage but
> in case of zs_copy_map_object, it could be a middle page of zspage.
> So I would like to use "page" instead of firstpage.

Accepted.

>> +{
>> +	struct page *pages[2];
>> +	int sizes[2];
>> +	void *addr;
>> +
>> +	pages[0] = firstpage;
>> +	pages[1] = get_next_page(firstpage);
>> +	BUG_ON(!pages[1]);
>> +
>> +	sizes[0] = PAGE_SIZE - off;
>> +	sizes[1] = size - sizes[0];
>> +
>> +	/* disable page faults to match kmap_atomic() return conditions */
>> +	pagefault_disable();
> 
> If I understand your intention correctly, you want to prevent calling
> this function on non-atomic context. Right?

This is moved to zs_map_object() in a later patch, but the
point is to provide uniform return conditions, regardless of
whether the object to be mapped is contained in a single
page or spans two pages.  kmap_atomic() disables page
faults, so I did it here to create symmetry.  The result is
that zs_map_object always returns with preemption and page
faults disabled.

Also, Greg already merged these patches so I'll have to
incorporate these changes as a separate patch.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
