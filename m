Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3A4E6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:36:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x124so9050387wmf.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:36:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m6si2039116pgn.163.2017.03.24.02.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 02:36:07 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2O9Y5Q7125985
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:36:06 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29cyr5k9ne-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:36:04 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 24 Mar 2017 09:36:00 -0000
Date: Fri, 24 Mar 2017 10:35:55 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
 <341568c3-0473-860f-aa20-63723aa40b87@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <341568c3-0473-860f-aa20-63723aa40b87@de.ibm.com>
Message-Id: <20170324093555.GB5891@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390 <linux-s390@vger.kernel.org>

On Fri, Mar 24, 2017 at 09:51:09AM +0100, Christian Borntraeger wrote:
> On 03/24/2017 12:01 AM, Pavel Tatashin wrote:
> > When deferred struct page initialization feature is enabled, we get a
> > performance gain of initializing vmemmap in parallel after other CPUs are
> > started. However, we still zero the memory for vmemmap using one boot CPU.
> > This patch-set fixes the memset-zeroing limitation by deferring it as well.
> > 
> > Here is example performance gain on SPARC with 32T:
> > base
> > https://hastebin.com/ozanelatat.go
> > 
> > fix
> > https://hastebin.com/utonawukof.go
> > 
> > As you can see without the fix it takes: 97.89s to boot
> > With the fix it takes: 46.91 to boot.
> > 
> > On x86 time saving is going to be even greater (proportionally to memory size)
> > because there are twice as many "struct page"es for the same amount of memory,
> > as base pages are twice smaller.
> 
> Fixing the linux-s390 mailing list email.
> This might be useful for s390 as well.

Unfortunately only for the fake numa case, since as far as I understand it,
parallelization happens only on a node granularity. And since we are
usually only having one node...

But anyway, it won't hurt to set ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT on
s390 also. I'll do some testing and then we'll see.

Pavel, could you please change your patch 5 so it also converts the s390
call sites of vmemmap_alloc_block() so they use VMEMMAP_ZERO instead of
'true' as argument?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
