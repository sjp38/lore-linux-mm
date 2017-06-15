Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C13A6B02FD
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:37:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k30so2275675wrc.9
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 02:37:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 75si69900wma.1.2017.06.15.02.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 02:37:45 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F9Xo0u051978
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:37:02 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b3q4n9jty-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:37:02 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 15 Jun 2017 03:37:01 -0600
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <eed279c6-bf61-f2f3-c9f2-d9a94568e2e3@linux.vnet.ibm.com>
 <20170614165513.GD17632@arm.com>
 <548e33cb-e737-bb39-91a3-f66ee9211262@linux.vnet.ibm.com>
 <20170615084851.if6sntxo5tswhlk5@node.shutemov.name>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 15 Jun 2017 15:06:49 +0530
MIME-Version: 1.0
In-Reply-To: <20170615084851.if6sntxo5tswhlk5@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <2a54d607-6e46-3693-158b-5e8101010ce2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com



On Thursday 15 June 2017 02:18 PM, Kirill A. Shutemov wrote:
> O
>> I am not suggesting we don't do the invalidate (the need for that is
>> documented in __split_huge_pmd_locked(). I am suggesting we need a new
>> interface, something like Andrea suggested.
>>
>> old_pmd = pmdp_establish(pmd_mknotpresent());
>>
>> instead of pmdp_invalidate(). We can then use this in scenarios where we
>> want to update pmd PTE entries, where right now we go through a pmdp_clear
>> and set_pmd path. We should really not do that for THP entries.
> 
> Which cases are you talking about? When do we need to clear pmd and set
> later?
> 

With the latest upstream I am finding the usage when we mark pte clean 
page_mkclean_one . Also there is a similar usage in 
migrate_misplaced_transhuge_page(). I haven't really verified whether 
they do cause any race. But my suggestion is, we should avoid the usage 
of set_pmd_at() unless we are creating a new pmd PTE entry. If we can 
provide pmdp_establish() we can achieve that easily.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
