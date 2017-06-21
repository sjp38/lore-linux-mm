Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01EE86B03EB
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:56:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so30286902wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:56:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o90si15996897wrc.330.2017.06.21.05.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 05:56:18 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LCt4xs049409
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:56:17 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b7r1mby4n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:56:16 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 21 Jun 2017 06:56:15 -0600
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <1497977049.20270.100.camel@redhat.com>
 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Wed, 21 Jun 2017 14:56:03 +0200
MIME-Version: 1.0
In-Reply-To: <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-IE
Content-Transfer-Encoding: 7bit
Message-Id: <c5f8cf53-c30b-a7ec-a8e8-9a2c120bdff6@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com
Cc: Nitesh Narayan Lal <nilal@redhat.com>

On 06/20/2017 06:49 PM, David Hildenbrand wrote:
> On 20.06.2017 18:44, Rik van Riel wrote:
>> On Mon, 2017-06-12 at 07:10 -0700, Dave Hansen wrote:
>>
>>> The hypervisor is going to throw away the contents of these pages,
>>> right?  As soon as the spinlock is released, someone can allocate a
>>> page, and put good data in it.  What keeps the hypervisor from
>>> throwing
>>> away good data?
>>
>> That looks like it may be the wrong API, then?
>>
>> We already have hooks called arch_free_page and
>> arch_alloc_page in the VM, which are called when
>> pages are freed, and allocated, respectively.
>>
>> Nitesh Lal (on the CC list) is working on a way
>> to efficiently batch recently freed pages for
>> free page hinting to the hypervisor.
>>
>> If that is done efficiently enough (eg. with
>> MADV_FREE on the hypervisor side for lazy freeing,
>> and lazy later re-use of the pages), do we still
>> need the harder to use batch interface from this
>> patch?
>>
> David's opinion incoming:
> 
> No, I think proper free page hinting would be the optimum solution, if
> done right. This would avoid the batch interface and even turn
> virtio-balloon in some sense useless.
> 
Two reasons why I disagree:
- virtio-balloon is often used as memory hotplug. (e.g. libvirts current/max memory
uses virtio ballon)
- free page hinting will not allow to shrink the page cache of guests (like a ballooner does)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
