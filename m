Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D81586B0005
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 09:30:49 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fl4so66211577pad.0
        for <linux-mm@kvack.org>; Sat, 20 Feb 2016 06:30:49 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id 79si24259697pfo.227.2016.02.20.06.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 20 Feb 2016 06:30:48 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 20 Feb 2016 09:30:47 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AF8A06E8040
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 09:17:37 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1KEUju132506020
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 14:30:46 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1KEUjPc014228
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 09:30:45 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: Problems with THP in v4.5-rc4 on POWER
In-Reply-To: <20160220055419.GB16191@fergus.ozlabs.ibm.com>
References: <20160220013942.GA16191@fergus.ozlabs.ibm.com> <20160220055419.GB16191@fergus.ozlabs.ibm.com>
Date: Sat, 20 Feb 2016 20:00:42 +0530
Message-ID: <878u2fe9nx.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Sat, Feb 20, 2016 at 12:39:42PM +1100, Paul Mackerras wrote:
>> It seems there's something wrong with our transparent hugepage
>> implementation on POWER server processors as of v4.5-rc4.  I have seen
>> the email thread on "[BUG] random kernel crashes after THP rework on
>> s390 (maybe also on PowerPC and ARM)", but this doesn't seem exactly
>> the same as that (though it may of course be related).
>> 
>> I have been testing v4.5-rc4 with Aneesh's patch "powerpc/mm/hash:
>> Clear the invalid slot information correctly" on top, on a KVM guest
>> with 160 vcpus (threads=8) and 32GB of memory backed by 16MB large
>> pages, running on a POWER8 machine running a 4.4.1 host kernel (20
>> cores * 8 threads, 128GB of RAM).  The guest kernel is compiled with
>> THP enabled and set to "always" (i.e. not "madvise").
>> 
>> On this setup, when doing something like a large kernel compile, I see
>> random segfaults happening (in gcc, cc1, sh, etc.).  I also see bursts
>> of messages like this on the host console:
>> 
>> [50957.570859] Harmless Hypervisor Maintenance interrupt [Recovered]
>> [50957.570864]  Error detail: Processor Recovery done
>> [50957.570869]  HMER: 2040000000000000
>
> When I use a merge of v4.5-rc4 with the fixes branch from the powerpc
> tree, I don't see these messages any more, presumably due to
> "powerpc/mm: Fix Multi hit ERAT cause by recent THP update".  With my
> patch, I still see that it is finding HPTEs to invalidate, but without
> my patch, even though it is presumably leaving HPTEs around, I don't
> see any errors (such as random segfaults) occurring.
>

Yes that patch should fix that. With thp, we use the deposited page
table to store hash pte slot information. On splitting, we were doing a
withdraw of deposited table, without doing the required hash pte flush.
This fix is to call pmdp_huge_split_prepare, which does the required
flush and also clear the _PAGE_USER. Clearning _PAGE_USER ensure that we
don't be inserting any other hash pte entries w.r.t to this THP.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
