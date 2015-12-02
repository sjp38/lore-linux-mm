Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 91B646B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 17:00:34 -0500 (EST)
Received: by padhx2 with SMTP id hx2so52224089pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:00:34 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rp16si7246740pab.8.2015.12.02.14.00.33
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 14:00:33 -0800 (PST)
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
 <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
 <1449022764.31589.24.camel@hpe.com>
 <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
 <1449078237.31589.30.camel@hpe.com>
 <CAPcyv4ikJ73nzQTCOfnBRThkv=rZGPM76S7=6O3LSB4kQBeEpw@mail.gmail.com>
 <CAPcyv4j1vA6eAtjsE=kGKeF1EqWWfR+NC7nUcRpfH_8MRqpM8Q@mail.gmail.com>
 <1449084362.31589.37.camel@hpe.com>
 <CAPcyv4jt7JmWCgcsd=p32M322sCyaar4Pj-k+F446XGZvzrO8A@mail.gmail.com>
 <1449086521.31589.39.camel@hpe.com> <1449087125.31589.45.camel@hpe.com>
 <CAPcyv4hvX_s3xN9UZ69v7npOhWVFehfGDPZG1MsDmKWBk4Gq1A@mail.gmail.com>
 <1449092226.31589.50.camel@hpe.com>
 <CAPcyv4jtVkptiFhiFP=2KXvDXs=Tw17pF=249sLj2fw-0vgsEg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <565F69FE.601@intel.com>
Date: Wed, 2 Dec 2015 14:00:30 -0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jtVkptiFhiFP=2KXvDXs=Tw17pF=249sLj2fw-0vgsEg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/02/2015 12:54 PM, Dan Williams wrote:
> On Wed, Dec 2, 2015 at 1:37 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
>> > On Wed, 2015-12-02 at 11:57 -0800, Dan Williams wrote:
> [..]
>>> >> The whole point of __get_user_page_fast() is to avoid the overhead of
>>> >> taking the mm semaphore to access the vma.  _PAGE_SPECIAL simply tells
>>> >> __get_user_pages_fast that it needs to fallback to the
>>> >> __get_user_pages slow path.
>> >
>> > I see.  Then, I think gup_huge_pmd() can simply return 0 when !pfn_valid(),
>> > instead of VM_BUG_ON.
> Is pfn_valid() a reliable check?  It seems to be based on a max_pfn
> per node... what happens when pmem is located below that point.  I
> haven't been able to convince myself that we won't get false
> positives, but maybe I'm missing something.

With sparsemem at least, it makes sure that you're looking at a valid
_section_.  See the pfn_valid() at ~include/linux/mmzone.h:1222.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
