Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 408856B02B4
	for <linux-mm@kvack.org>; Fri, 26 May 2017 12:46:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so19263387pff.13
        for <linux-mm@kvack.org>; Fri, 26 May 2017 09:46:08 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r13si1331266pgr.213.2017.05.26.09.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 09:46:07 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
 <20170515193817.GC7551@dhcp22.suse.cz>
 <9b3d68aa-d2b6-2b02-4e75-f8372cbeb041@oracle.com>
 <20170516083601.GB2481@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <07a6772b-711d-4fdc-f688-db76f1ec4c45@oracle.com>
Date: Fri, 26 May 2017 12:45:55 -0400
MIME-Version: 1.0
In-Reply-To: <20170516083601.GB2481@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

Hi Michal,

I have considered your proposals:

1. Making memset(0) unconditional inside __init_single_page() is not 
going to work because it slows down SPARC, and ppc64. On SPARC even the 
BSTI optimization that I have proposed earlier won't work, because after 
consulting with other engineers I was told that stores (without loads!) 
after BSTI without membar are unsafe

2. Adding ARCH_WANT_LARGE_PAGEBLOCK_INIT is not going to solve the 
problem, because while arch might want a large memset(), it still wants 
to get the benefit of parallelized struct page initialization.

3. Another approach that have I considered is moving memset() above 
__init_single_page() and do it in a larger chunks. However, this 
solution is also not going to work, because inside the loops, there are 
cases where "struct page"s are skipped, so every single page is checked:
early_pfn_valid(pfn), early_pfn_in_nid(), and also mirroed_kernelcore cases.

> I wouldn't be so sure about this. If any other platform has a similar
> issues with small memset as sparc then the overhead is just papered over
> by parallel initialization.

That is true, and that is fine, because parallelization gives an order 
of magnitude better improvements compared to trade of slower single 
thread performance. Remember, this will happen during boot and memory 
hotplug only, and not something that will eat up computing resources 
during runtime.

So, at the moment I cannot really find a better solution compared to 
what I have proposed: do memset() inside __init_single_page() only when 
deferred initialization is enabled.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
