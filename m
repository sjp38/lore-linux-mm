Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E0B5A6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:00:50 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 10:00:49 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 430F46E8088
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:00:45 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BE0hUL355168
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:00:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BJVZgZ004832
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 15:31:36 -0400
Message-ID: <4FFD86FE.1090307@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 09:00:30 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <4FFD2524.2050300@kernel.org>
In-Reply-To: <4FFD2524.2050300@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 02:03 AM, Minchan Kim wrote:
> On 07/03/2012 06:15 AM, Seth Jennings wrote:
>> zsmapbench measures the copy-based mapping at ~560 cycles for a
>> map/unmap operation on spanned object for both KVM guest and bare-metal,
>> while the page table mapping was ~1500 cycles on a VM and ~760 cycles
>> bare-metal.  The cycles for the copy method will vary with
>> allocation size, however, it is still faster even for the largest
>> allocation that zsmalloc supports.
>>
>> The result is convenient though, as mempcy is very portable :)
> 
> Today, I tested zsmapbench in my embedded board(ARM).
> tlb-flush is 30% faster than copy-based so it's always not win.
> I think it depends on CPU speed/cache size.
> 
> zram is already very popular on embedded systems so I want to use
> it continuously without 30% big demage so I want to keep our old approach
> which supporting local tlb flush. 
> 
> Of course, in case of KVM guest, copy-based would be always bin win.
> So shouldn't we support both approach? It could make code very ugly
> but I think it has enough value.
> 
> Any thought?

Thanks for testing on ARM.

I can add the pgtable assisted method back in, no problem.
The question is by which criteria are we going to choose
which method to use? By arch (i.e. ARM -> pgtable assist,
x86 -> copy, other archs -> ?)?

Also, what changes did you make to zsmapbench to measure
elapsed time/cycles on ARM?  Afaik, rdtscll() is not
supported on ARM.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
