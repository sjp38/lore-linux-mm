Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3CB16B0271
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:39:06 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n10-v6so4300384qtp.11
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:39:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u6-v6si4953218qvf.157.2018.06.27.23.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:39:06 -0700 (PDT)
Date: Thu, 28 Jun 2018 14:39:01 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180628063901.GA32539@MiWiFi-R3L-srv>
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-5-bhe@redhat.com>
 <CAGM2reaWkmCF_DWY1jETsC=NOPC7TGFq3VX06YrTDLAp+X2+AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reaWkmCF_DWY1jETsC=NOPC7TGFq3VX06YrTDLAp+X2+AQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/27/18 at 11:19pm, Pavel Tatashin wrote:
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> >
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> Please remove duplicated signed-off

Done.
> 
> >                 if (!usemap) {
> >                         ms->section_mem_map = 0;
> > +                       nr_consumed_maps++;
> 
> Currently, we do not set ms->section_mem_map to 0 when fail to
> allocate usemap, only when fail to allocate mmap we set
> section_mem_map to 0. I think this is an existing bug.

Yes, found it when changing code. Later in sparse_init(), added checking
to see if usemap is available, otherwise also do "ms->section_mem_map = 0;"
to clear its ->section_mem_map.

Here if want to be perfect, we may need to free the relevant memmap
because usemap is allocated together, memmap could be allocated one
section by one section. I didn't do that because usemap allocation is
smaller one, if that allocation even failed in this early system
initializaiton stage, the kernel won't live long, so don't bother to do
that to complicate code.

> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
