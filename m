Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84D706B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:17:00 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 11so194160itj.3
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:00 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c132si994977iof.248.2018.02.14.06.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 06:16:59 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1EEBr5o101957
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:16:58 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2g4g41a0dq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:16:58 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1EEGt7V004764
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:16:55 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w1EEGsqD003639
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:16:54 GMT
Received: by mail-ot0-f178.google.com with SMTP id l10so20485491oth.1
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:16:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180214050843.GA2811@jagdpanzerIV>
References: <20180209192216.20509-1-pasha.tatashin@oracle.com>
 <20180209192216.20509-2-pasha.tatashin@oracle.com> <20180214050843.GA2811@jagdpanzerIV>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 14 Feb 2018 09:16:53 -0500
Message-ID: <CAOAebxuwn0hvp7Rwv5nFDy=POUJf81X=xVEjM6MBEy6nzaNYgQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/1] mm: initialize pages on demand during boot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, m.mizuma@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, baiyaowei@cmss.chinamobile.com, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Sergey,

Thank you for noticing this! I will send out an updated patch soon.

Pavel

On Wed, Feb 14, 2018 at 12:08 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (02/09/18 14:22), Pavel Tatashin wrote:
> [..]
>> +/*
>> + * If this zone has deferred pages, try to grow it by initializing enough
>> + * deferred pages to satisfy the allocation specified by order, rounded up to
>> + * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
>> + * of SECTION_SIZE bytes by initializing struct pages in increments of
>> + * PAGES_PER_SECTION * sizeof(struct page) bytes.
>> + *
>> + * Return true when zone was grown by at least number of pages specified by
>> + * order. Otherwise return false.
>> + *
>> + * Note: We use noinline because this function is needed only during boot, and
>> + * it is called from a __ref function _deferred_grow_zone. This way we are
>> + * making sure that it is not inlined into permanent text section.
>> + */
>> +static noinline bool __init
>> +deferred_grow_zone(struct zone *zone, unsigned int order)
>> +{
>> +     int zid = zone_idx(zone);
>> +     int nid = zone->node;
>
>                 ^^^^^^^^^
>
> Should be CONFIG_NUMA dependent
>
> struct zone {
> ...
> #ifdef CONFIG_NUMA
>         int node;
> #endif
> ...
>
>         -ss
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
