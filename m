Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 852CE6B04CD
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:57:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so206006153pfv.5
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 22:57:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k5si21233900pfk.138.2016.11.20.22.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 22:57:31 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAL6sIcO040649
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:57:31 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26uty5jj31-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:57:31 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 16:57:28 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6D430357806C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:57:26 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAL6vQXC43647010
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:57:26 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAL6vPvT022788
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:57:26 +1100
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
 <e4157b8e-ef9b-0539-bb2b-649152fbc7f2@gmail.com>
 <20161121045352.GA7872@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 12:27:15 +0530
MIME-Version: 1.0
In-Reply-To: <20161121045352.GA7872@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <58329ACB.6030700@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On 11/21/2016 10:23 AM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 11:44:36AM +1100, Balbir Singh wrote:
>>
>>
>> On 19/11/16 05:18, Jerome Glisse wrote:
>>> Only usefull for arch where we support ZONE_DEVICE and where we want to
>>> also support un-addressable device memory. We need struct page for such
>>> un-addressable memory. But we should avoid populating the kernel linear
>>> mapping for the physical address range because there is no real memory
>>> or anything behind those physical address.
>>>
>>> Hence we need more flags than just knowing if it is device memory or not.
>>>
>>
>>
>> Isn't it better to add a wrapper to arch_add/remove_memory and do those
>> checks inside and then call arch_add/remove_memory to reduce the churn.
>> If you need selectively enable MEMORY_UNADDRESSABLE that can be done with
>> _ARCH_HAS_FEATURE
> 
> The flag parameter can be use by other new features and thus i thought the
> churn was fine. But i do not mind either way, whatever people like best.

Right, once we get the device memory classification right, these flags
can be used in more places.

> 
> [...]
> 
>>> -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
>>> +
>>> +/*
>>> + * For device memory we want more informations than just knowing it is device
>> 				     information
>>> + * memory. We want to know if we can migrate it (ie it is not storage memory
>>> + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
>>> + * memory can not be access by CPU but we still want struct page so that we
>> 			accessed
>>> + * can use it like regular memory.
>>
>> Can you please add some details on why -- migration needs them for example?
> 
> I am not sure what you mean ? DAX ie persistent memory device is intended to be
> use for filesystem or persistent storage. Hence memory migration does not apply
> to it (it would go against its purpose).

Why ? It can still be used for compaction, HW errors etc where we need to
move between persistent storage areas. The source and destination can be
persistent storage memory.

> 
> So i want to extend ZONE_DEVICE to be more then just DAX/persistent memory. For
> that i need to differentatiate between device memory that can be migrated and
> should be more or less treated like regular memory (with struct page). This is
> what the MEMORY_MOVABLE flag is for.

ZONE_DEVICE right now also supports struct page for the addressable memory,
(whether inside it's own range or in system RAM) with this we are extending
it to cover un-addressable memory with struct pages. Yes the differentiation
is required.

> 
> Finaly in my case the device memory is not accessible by the CPU so i need yet
> another flag. In the end i am extending ZONE_DEVICE to be use for 3 differents
> type of memory.
> 
> Is this the kind of explanation you are looking for ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
