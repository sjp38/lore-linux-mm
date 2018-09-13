Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 211A88E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 08:05:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z77-v6so4706852wrb.20
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:05:01 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i129-v6si3423549wmg.146.2018.09.13.05.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 13 Sep 2018 05:04:59 -0700 (PDT)
Date: Thu, 13 Sep 2018 14:04:58 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: How to profile 160 ms spent in
 `add_highpages_with_active_regions()`?
In-Reply-To: <d2ad2459-61ea-edb1-3b22-da92c039bfae@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1809131400070.1473@nanos.tec.linutronix.de>
References: <d5a65984-36a7-15d8-b04a-461d0f53d36d@molgen.mpg.de> <5e5a39f4-1b91-c877-1368-0946160ef4be@molgen.mpg.de> <4f8d0de0-e9f1-e3cd-1f94-e95e6fa47ecf@molgen.mpg.de> <alpine.DEB.2.21.1808221539190.1652@nanos.tec.linutronix.de>
 <d2ad2459-61ea-edb1-3b22-da92c039bfae@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-1620629746-1536840298=:1473"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>
Cc: linux-mm@kvack.org, x86@kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1620629746-1536840298=:1473
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Tue, 4 Sep 2018, Paul Menzel wrote:
> On 08/22/18 15:41, Thomas Gleixner wrote:
> > On Wed, 22 Aug 2018, Paul Menzel wrote:
> >> Am 21.08.2018 um 11:37 schrieb Paul Menzel:
> >>> [Removed non-working Pavel Tatashin <pasha.tatashin@oracle.com>]
> >>
> >> So a??freea??inga?? pfn = 225278 to e_pfn = 818492 in the for loop takes 160 ms.
> > 
> > That's 593214 pages and each one takes about 270ns. I don't see much
> > optimization potential with that.
> > 
> > 32bit and highmem sucks ...

We all know that.

> Interestingly on my ASRock E350M1 with 4 GB, `pfn_valid()` is always true.
>
> Additionally, after removing the for loop, the system still boots and seems
> to work fine.
> 
> Here is the hunk I removed (with my debug statements).
> 
> -               for ( ; pfn < e_pfn; pfn++)
> -                       if (pfn_valid(pfn)) {
> -                               free_highmem_page(pfn_to_page(pfn));
> -                               //printk(KERN_INFO "%s: in for loop pfn_valid(pfn) after fre
> e_highmem_page, pfn = %lu\n", __func__, pfn);
> -                       } else {
> -                               printk(KERN_INFO "%s: pfn = %lu is invalid\n", __func__);
> -                       }
> 
> Is the code there for certain memory sizes?

No, it's there to give the highmem pages back for allocation. You're losing
usable memory that way. /proc/meminfo should tell you the difference.

Thanks,

	tglx
--8323329-1620629746-1536840298=:1473--
