Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B57886B078C
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 07:29:11 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so10860291qka.9
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 04:29:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h12si1941581qvb.79.2018.11.10.04.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 04:29:10 -0800 (PST)
Date: Sat, 10 Nov 2018 20:29:05 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181110122905.GA2653@MiWiFi-R3L-srv>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
 <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/26/18 at 03:28pm, Kirill A. Shutemov wrote:
> On 5-level paging LDT remap area is placed in the middle of
> KASLR randomization region and it can overlap with direct mapping,
> vmalloc or vmap area.
             ~~~
		We usually call it vmemmap.
> 
> Let's move LDT just before direct mapping which makes it safe for KASLR.
> This also allows us to unify layout between 4- and 5-level paging.
...

> diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
> index 702898633b00..75bff98928a8 100644
> --- a/Documentation/x86/x86_64/mm.txt
> +++ b/Documentation/x86/x86_64/mm.txt
> @@ -34,23 +34,24 @@ __________________|____________|__________________|_________|___________________
>  ____________________________________________________________|___________________________________________________________
>                    |            |                  |         |
>   ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole, also reserved for hypervisor
> - ffff880000000000 | -120    TB | ffffc7ffffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
> - ffffc80000000000 |  -56    TB | ffffc8ffffffffff |    1 TB | ... unused hole
> + ffff880000000000 | -120    TB | ffff887fffffffff |  0.5 TB | LDT remap for PTI
> + ffff888000000000 | -119.5  TB | ffffc87fffffffff |   64 TB | direct mapping of all physical memory (page_offset_base)
> + ffffc88000000000 |  -55.5  TB | ffffc8ffffffffff |  0.5 TB | ... unused hole

Hi Kirill,

Thanks for this fix. One small concern is whether we can put LDT
remap in other place, e.g shrink KASAN area and save one pgd size for
it, Just from Redhat's enterprise relase point of view, we don't
enable CONFIG_KASAN, and LDT is rarely used for server, now cutting one
block from the direct mapping area and moving it up one pgd slot seems a
little too abrupt. Does KASAN really cost 16 TB in 4-level and 8 PB in
5-level? After all the direct mapping is the core mapping and has been
there always, LDT remap is kind of not so core and important mapping.
Just a very perceptual feeling.

Other than this, this patch looks good to me.

Thanks
Baoquan
