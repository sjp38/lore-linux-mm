Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDF016B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 21:03:37 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id h7-v6so864876oti.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 18:03:37 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i3si392178oik.340.2018.03.13.18.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 18:03:36 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w2E11wpT132040
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:03:36 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2gps3bg2er-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:03:35 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w2E13YGp002089
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:03:35 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w2E13YwM014418
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:03:34 GMT
Received: by mail-oi0-f44.google.com with SMTP id g5so1344728oiy.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 18:03:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com> <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com> <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 13 Mar 2018 21:02:53 -0400
Message-ID: <CAGM2reYo2EbH0W70rJGSGWRBAO=upcNDanBoCQgve+eQ_94C8A@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On Tue, Mar 13, 2018 at 8:53 PM, Sasha Levin
<Alexander.Levin@microsoft.com> wrote:
> On Tue, Mar 13, 2018 at 08:38:57PM -0400, Pavel Tatashin wrote:
>>Hi Sasha,
>>
>>It seems the patch is doing the right thing, and it catches bugs. Here
>>we access uninitialized struct page. The question is why this happens?
>
> Not completely; note that we die on an invalid reference rather than
> assertion failure.

I think that invalid reference happens within assertion failure, as
far as I can tell, it is dump_page() where we get the invalid
reference, but to get to dump_page() from get_nid_for_pfn() we must
have triggered the assertion.

>
>>register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>>   page_nid = get_nid_for_pfn(pfn);
>>
>>node id is stored in page flags, and since struct page is poisoned,
>>and the pattern is recognized, the panic is triggered.
>>
>>Do you have config file? Also, instructions how to reproduce it?
>
> Attached the config. It just happens on boot.

Thanks, I will try in qemu.

Pasha
