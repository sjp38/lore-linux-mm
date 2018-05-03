Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7D06B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 22:11:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o16-v6so11030341wri.8
        for <linux-mm@kvack.org>; Wed, 02 May 2018 19:11:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x58-v6si6488941edx.338.2018.05.02.19.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 19:11:12 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4329FW8119385
	for <linux-mm@kvack.org>; Wed, 2 May 2018 22:11:11 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hqs3mgnfg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 May 2018 22:11:10 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 3 May 2018 03:11:06 +0100
Date: Wed, 2 May 2018 19:10:58 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
Message-Id: <20180503021058.GA5670@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, ".linuxppc-dev"@lists.ozlabs.org

On Wed, May 02, 2018 at 09:23:49PM +0000, Andy Lutomirski wrote:
> 
> > If I recall correctly, the POWER maintainer did express a strong desire
> > back then for (what is, I believe) their current semantics, which my
> > PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.
> 
> Ram, I really really don't like the POWER semantics.  Can you give some
> justification for them?  Does POWER at least have an atomic way for
> userspace to modify just the key it wants to modify or, even better,
> special load and store instructions to use alternate keys?

I wouldn't call it POWER semantics. The way I implemented it on power
lead to the semantics, given that nothing was explicitly stated 
about how the semantics should work within a signal handler.

As far as power ISA is concerned, there are no special load
and store instructions that can somehow circumvent the permissions
of the key associated with the PTE.

Also unlike x86;  on POWER, pkey-permissions are not administered based
on its run context (user context, signal context).
Hence the default behavior tends to make the key permissions remain the
same regardless of the context.


> Does POWER at least have an atomic way for userspace to modify just the 
> key it wants to modify .. ?

No. just like PKRU, on power its a register which has bits corresponding
to each key. Entire register has to be read and written, which means
multiple keys could get modified in the same write.


adding ppc mailing list to the CC.

> 
> --Andy

-- 
Ram Pai
