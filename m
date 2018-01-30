Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3966B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:30:16 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id n28so10478350qtk.7
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:30:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 8si3952818qku.255.2018.01.30.00.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 00:30:15 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0U8TaHp132875
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:30:14 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ftmqbhdy7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:30:14 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 08:30:12 -0000
Date: Tue, 30 Jan 2018 14:00:06 +0530
From: Bharata B Rao <bharata@linux.vnet.ibm.com>
Subject: Memory hotplug not increasing the total RAM
Reply-To: bharata@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20180130083006.GB1245@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pasha.tatashin@oracle.com

Hi,

With the latest upstream, I see that memory hotplug is not working
as expected. The hotplugged memory isn't seen to increase the total
RAM pages. This has been observed with both x86 and Power guests.

1. Memory hotplug code intially marks pages as PageReserved via
__add_section().
2. Later the struct page gets cleared in __init_single_page().
3. Next online_pages_range() increments totalram_pages only when
   PageReserved is set.

The step 2 has been introduced recently by the following commit:

commit f7f99100d8d95dbcf09e0216a143211e79418b9f
Author: Pavel Tatashin <pasha.tatashin@oracle.com>
Date:   Wed Nov 15 17:36:44 2017 -0800

    mm: stop zeroing memory during allocation in vmemmap
    
Reverting this commit restores the correct behaviour of memory hotplug.

Regards,
Bharata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
