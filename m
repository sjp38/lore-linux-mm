Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4806B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:32:40 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so6364215pab.20
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 09:32:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id du3si4859191pdb.245.2014.07.25.09.32.39
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 09:32:39 -0700 (PDT)
Message-ID: <53D286A5.7050100@intel.com>
Date: Fri, 25 Jul 2014 09:32:37 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Background page clearing
References: <000001cfa81a$110d15c0$33274140$@com> <53D27590.2090500@intel.com> <A610E03AD50BFC4D95529A36D37FA55E3756EFEC80@GEORGE.Emea.Arm.com>
In-Reply-To: <A610E03AD50BFC4D95529A36D37FA55E3756EFEC80@GEORGE.Emea.Arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wilco Dijkstra <Wilco.Dijkstra@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/25/2014 09:27 AM, Wilco Dijkstra wrote:
>> On 07/25/2014 08:06 AM, Wilco Dijkstra wrote:
>>> Is there a reason Linux does not do background page clearing like other OSes to reduce this
>>> overhead? It would be a good fit for typical mobile workloads (bursts of high activity
>> followed by
>>> periods of low activity).
>>
>> If the page is being allocated, it is about to be used and be brought in
>> to the CPU's cache.  If we zero it close to this use, we only pay to
>> bring it in to the CPU's cache once.  Or so goes the theory...
> 
> I can see the reasoning for 4KB pages and small allocations (eg. stack),
> but would that ever be true for huge pages?

Probably not, but huge pages aren't allocated and freed enough in any
workload that I know of for this to make a difference for them.

>> I tried a zero-on-free implementation a year or so ago.  It helped some
>> workloads and hurt others.  The gains were not large enough or
>> widespread enough to merit pushing it in to the kernel.
> 
> Was that literally zero-on-free or zero in the background? Was the result
> the same for different page sizes? My guess is that the result will be
> different for huge pages.

Literally zero-on-free for 4k pages only.  I did it inside the
per-cpu-pages lists.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
