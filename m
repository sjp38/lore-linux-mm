Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB016B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 18:39:50 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so64216216obb.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 15:39:50 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id f16si13440359oes.68.2015.05.14.15.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 15:39:49 -0700 (PDT)
Message-ID: <1431642030.22510.8.camel@misato.fc.hp.com>
Subject: Re: [PATCH v9 10/10] drivers/block/pmem: Map NVDIMM with
 ioremap_wt()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 14 May 2015 16:20:30 -0600
In-Reply-To: <CAPcyv4je=q92aytAXLR=Eqc3yD8pdmSuyuCF+4QJRb34LFU=VQ@mail.gmail.com>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
	 <1431551151-19124-11-git-send-email-toshi.kani@hp.com>
	 <CAPcyv4je=q92aytAXLR=Eqc3yD8pdmSuyuCF+4QJRb34LFU=VQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, jgross@suse.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, mcgrof@suse.com, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stefan.bader@canonical.com, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, hmh@hmh.eng.br, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

On Thu, 2015-05-14 at 14:52 -0700, Dan Williams wrote:
> On Wed, May 13, 2015 at 2:05 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
> > write back the contents of the CPU caches in case of a crash.
> >
> > This patch changes to use ioremap_wt(), which provides uncached
> > writes but cached reads, for improving read performance.
> 
> I'm thinking that for the libnd integration we don't want the pmem
> driver hard coding the cache-policy decision.  This is something that
> should be specified to nd_pmem_region_create().  Especially
> considering that platform firmware tables (NFIT) may specify the cache
> policy for the range.  As Matthew Wilcox mentioned offline we also
> must match the DAX-to-mmap cache policy with the policy for the driver
> mapping  for architectures that are not capable of multiple mappings
> of the same physical address with different policies.

Agreed.  I believe this hardcoded ioremap is temporary (either UC- or
WT), and we need to allow NFIT or user to specify a map type, such as
WB.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
