Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 337EE6B026D
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:25:19 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c33so6775166itf.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:25:19 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c34si3397250iod.104.2017.11.30.09.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 09:25:18 -0800 (PST)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vAUHPHDD002891
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:25:17 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id vAUHPGH2026639
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:25:16 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id vAUHPGJX010034
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:25:16 GMT
Received: by mail-oi0-f49.google.com with SMTP id j17so5338662oih.3
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:25:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
References: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 30 Nov 2017 12:25:14 -0500
Message-ID: <CAOAebxti9DVyjb0dsR-E_8ULenaRf0OZ_WeWxppbdDVmFbt8mA@mail.gmail.com>
Subject: Re: [PATCH] mm: check pfn_valid first in zero_resv_unavail
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Dave,

Because unavailable memory can be in the middle of a section, I think
a proper fix would be to do pfn_valid() check only at the beginning of
section. Otherwise, we might miss zeroing  a struct page is in the
middle of a section but pfn_valid() could potentially return false as
that page is indeed invalid.

So, I would do something like this:
+                       if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))
+                               continue;

Could you please test if this fix works?

We should really look into this memory that is reserved by memblock
but Linux is not aware of physical backing, so far I know that only
x86 can have such scenarios, so we should really see if the problem
can be addressed on x86 platform. It would be very nice if we could
enforce inside memblock to reserve only memory that has real physical
backing.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
