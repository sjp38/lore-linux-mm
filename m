Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC5D6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 13:38:29 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q18so15397685ioh.4
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 10:38:29 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c4si264502itf.116.2018.01.31.10.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 10:38:28 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w0VIbBIi110165
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:38:27 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2fuc8kjdvm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:38:27 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w0VIcQ9S009434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:38:26 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w0VIcPus003089
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:38:26 GMT
Received: by mail-ot0-f170.google.com with SMTP id a7so11470179otk.9
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 10:38:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180131084313.GP21609@dhcp22.suse.cz>
References: <20180131054243.28141-1-pasha.tatashin@oracle.com> <20180131084313.GP21609@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 31 Jan 2018 13:38:24 -0500
Message-ID: <CAOAebxu1T4U_D2QqJ5jzosppEz7nmUf30x_fm5Hxn_+Yq5H7QA@mail.gmail.com>
Subject: Re: [PATCH v1] mm: optimize memory hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>

Hi Michal,

> So how do we check that there is no page_to_nid() user before we online
> the page?

The poisoning helps to catch these now, and will in the future.
Because we are setting "struct page" to all 1s, we get nid that is
bigger than supported, and thus panic due to NULL pointer dereference,
or some other reason.

For example, if in online_pages() I replace get_section_nid() back to
pfn_to_nid(), I am getting panic like this:

[   45.473228] BUG: KASAN: null-ptr-deref in zone_for_pfn_range+0xce/0x240
[   45.475273] Read of size 8 at addr 0000000000000068 by task bash/144
[   45.477240]
[   45.477744] CPU: 0 PID: 144 Comm: bash Not tainted
4.15.0-next-20180130_pt_memset #11
[   45.479947] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.11.0-20171110_100015-anatol 04/01/2014
[   45.482053] Call Trace:
[   45.482589]  dump_stack+0xa6/0x109
[   45.483304]  ? _atomic_dec_and_lock+0x137/0x137
[   45.484248]  ? zone_for_pfn_range+0xce/0x240
[   45.485140]  kasan_report+0x208/0x350
[   45.485916]  zone_for_pfn_range+0xce/0x240
[   45.486787]  online_pages+0xf0/0x4a0

 I remember I was fighting strange bugs when reworking this
> code. I have forgot all the details of course, I just remember some
> nasty and subtle code paths. Maybe we have got rid of those in the past
> year but this should be done really carefully. We might have similar
> dependences on PageReserved.

I am adding a new PG_POISON_CHECK() to help with both Page* macros,
and page_to_nid(). A new patch is coming.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
