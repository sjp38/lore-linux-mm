Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1B836B02C3
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:43:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g7so107032306pgp.1
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 22:43:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f22si8055793pli.265.2017.07.09.22.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 22:43:35 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A5hUnF077618
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:43:35 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bjux6qc9a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:43:35 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 15:43:32 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6A5hU9u19595472
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 15:43:30 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6A5hLbv006870
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 15:43:22 +1000
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 10 Jul 2017 11:13:23 +0530
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d9030b2c-493b-94c4-8c97-8aaec3be34ba@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/06/2017 02:51 AM, Ram Pai wrote:
> Memory protection keys enable applications to protect its
> address space from inadvertent access or corruption from
> itself.
> 
> The overall idea:
> 
>  A process allocates a   key  and associates it with
>  an  address  range  within    its   address   space.
>  The process  then  can  dynamically  set read/write 
>  permissions on  the   key   without  involving  the 
>  kernel. Any  code that  violates   the  permissions
>  of  the address space; as defined by its associated
>  key, will receive a segmentation fault.
> 
> This patch series enables the feature on PPC64 HPTE
> platform.
> 
> ISA3.0 section 5.7.13 describes the detailed specifications.
> 
> 
> Testing:
> 	This patch series has passed all the protection key
> 	tests available in  the selftests directory.
> 	The tests are updated to work on both x86 and powerpc.
> 
> version v5:
> 	(1) reverted back to the old design -- store the 
> 	    key in the pte, instead of bypassing it.
> 	    The v4 design slowed down the hash page path.
> 	(2) detects key violation when kernel is told to 
> 		access user pages.
> 	(3) further refined the patches into smaller consumable
> 		units
> 	(4) page faults handlers captures the faulting key 
> 	    from the pte instead of the vma. This closes a
> 	    race between where the key update in the vma and
> 	    a key fault caused cause by the key programmed
> 	    in the pte.
> 	(5) a key created with access-denied should
> 	    also set it up to deny write. Fixed it.
> 	(6) protection-key number is displayed in smaps
> 		the x86 way.

Hello Ram,

This patch series has now grown a lot. Do you have this
hosted some where for us to pull and test it out ? BTW
do you have data points to show the difference in
performance between this version and the last one where
we skipped the bits from PTE and directly programmed the
HPTE entries looking into VMA bits.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
