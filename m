Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED8BA6B0262
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 01:21:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 83so26582886pfx.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 22:21:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n28si16022066pgd.148.2016.11.04.22.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 22:21:34 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA55IkLF107936
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 01:21:33 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26gy1nvbmq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 05 Nov 2016 01:21:32 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 5 Nov 2016 15:21:30 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DBAF52CE8054
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 16:21:26 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA55LQZl8519774
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 16:21:26 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA55LQnk024284
	for <linux-mm@kvack.org>; Sat, 5 Nov 2016 16:21:26 +1100
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com> <87a8dtawas.fsf@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sat, 5 Nov 2016 10:51:21 +0530
MIME-Version: 1.0
In-Reply-To: <87a8dtawas.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <581D6C51.3070102@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Glisse <j.glisse@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On 10/25/2016 09:56 AM, Aneesh Kumar K.V wrote:
> I looked at the hmm-v13 w.r.t migration and I guess some form of device
> callback/acceleration during migration is something we should definitely
> have. I still haven't figured out how non addressable and coherent device
> memory can fit together there. I was waiting for the page cache
> migration support to be pushed to the repository before I start looking
> at this closely.

Aneesh, did not get that. Currently basic page cache migration is supported,
right ? The device callback during migration, fault etc are supported through
page->pgmap pointer and extending dev_pagemap structure to accommodate new
members. IIUC that is the reason ZONE_DEVICE is being modified so that page
->pgmap overloading can be used for various driver/device specific callbacks
while inside core VM functions or HMM functions.

HMM V13 has introduced non-addressable ZONE_DEVICE based device memory which
can have it's struct pages in system RAM but they cannot be accessed from the
CPU. Now coherent device memory is kind of similar to persistent memory like
NVDIMM which is already supported through ZONE_DEVICE (though we might not
want to use vmemap_altmap instead have the struct pages in the system RAM).
Now HMM has to learn working with 'dev_pagemap->addressable' type of device
memory and then support all possible migrations through it's API. So in a
nutshell, these are the changes we need to do to make HMM work with coherent
device memory.

(0) Support all possible migrations between system RAM and device memory
    for current un-addressable device memory and make the HMM migration
    API layer comprehensive and complete.

(1) Create coherent device memory representation in ZONE_DEVICE
	(a) Make it exactly the same as that of persistent memory/NVDIMM

	or

	(b) Create a new type for coherent device memory representation

(2) Support all possible migrations between system RAM and device memory
    for new addressable coherent device memory represented in ZONE_DEVICE
    extending the HMM migration API layer.

Right now, HMM V13 patch series supports migration for a subset of private
anonymous pages for un-addressable device memory. I am wondering how difficult
is it to implement all possible anon, file mapping migration support for both
un-addressable and addressable coherent device memory through ZONE_DEVICE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
