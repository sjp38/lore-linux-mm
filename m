Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 588A76B0006
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:46:56 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id s22-v6so5468278oie.9
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:46:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w69si11550898otb.35.2018.10.30.23.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 23:46:55 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9V6i3vU128743
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:46:54 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nf63n2upe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:46:54 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 06:46:52 -0000
Date: Wed, 31 Oct 2018 07:46:47 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
In-Reply-To: <CAEemH2f2gW22PJYpVrh7p5zJyHOVRfVawJWD+kN3+8LmApePbw@mail.gmail.com>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
	<1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
	<CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
	<20181031073149.55ddc085@mschwideX1>
	<CAEemH2f2gW22PJYpVrh7p5zJyHOVRfVawJWD+kN3+8LmApePbw@mail.gmail.com>
MIME-Version: 1.0
Message-Id: <20181031074647.32c6e0d7@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 31 Oct 2018 14:43:38 +0800
Li Wang <liwang@redhat.com> wrote:

> On Wed, Oct 31, 2018 at 2:31 PM, Martin Schwidefsky <schwidefsky@de.ibm.com>
> wrote:
> 
> > On Wed, 31 Oct 2018 14:18:33 +0800
> > Li Wang <liwang@redhat.com> wrote:
> >  
> > > On Tue, Oct 16, 2018 at 12:42 AM, Martin Schwidefsky <  
> > schwidefsky@de.ibm.com  
> > > > wrote:  
> > >  
> > > > In case a fork or a clone system fails in copy_process and the error
> > > > handling does the mmput() at the bad_fork_cleanup_mm label, the
> > > > following warning messages will appear on the console:
> > > >
> > > >   BUG: non-zero pgtables_bytes on freeing mm: 16384
> > > >
> > > > The reason for that is the tricks we play with mm_inc_nr_puds() and
> > > > mm_inc_nr_pmds() in init_new_context().
> > > >
> > > > A normal 64-bit process has 3 levels of page table, the p4d level and
> > > > the pud level are folded. On process termination the free_pud_range()
> > > > function in mm/memory.c will subtract 16KB from pgtable_bytes with a
> > > > mm_dec_nr_puds() call, but there actually is not really a pud table.
> > > >
> > > > One issue with this is the fact that pgtable_bytes is usually off
> > > > by a few kilobytes, but the more severe problem is that for a failed
> > > > fork or clone the free_pgtables() function is not called. In this case
> > > > there is no mm_dec_nr_puds() or mm_dec_nr_pmds() that go together with
> > > > the mm_inc_nr_puds() and mm_inc_nr_pmds in init_new_context().
> > > > The pgtable_bytes will be off by 16384 or 32768 bytes and we get the
> > > > BUG message. The message itself is purely cosmetic, but annoying.
> > > >
> > > > To fix this override the mm_pmd_folded, mm_pud_folded and mm_p4d_folded
> > > > function to check for the true size of the address space.
> > > >  
> > >
> > > I can confirm that it works to the problem, the warning message is gone
> > > after applying this patch on s390x. And I also done ltp syscalls/cve test
> > > for the patch set on x86_64 arch, there has no new regression.
> > >
> > > Tested-by: Li Wang <liwang@redhat.com>  
> >
> > Thanks for testing. Unfortunately Heiko reported another issue yesterday
> > with the patch applied. This time the other way around:
> >
> > BUG: non-zero pgtables_bytes on freeing mm: -16384
> >  
> 
> Okay, the problem is still triggered by LTP/cve-2017-17052.c?

No, unfortunately we do not have a simple testcase to trigger this new bug.
It happened once with one of our test kernels, the path that leads to this
is completely unclear.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
