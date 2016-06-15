Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DACDD6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:10:25 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e5so69690633ith.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:10:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o124si978295pfb.247.2016.06.15.13.10.25
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:10:25 -0700 (PDT)
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com>
 <C1C2579D7BE026428F81F41198ADB17237A8670A@irsmsx110.ger.corp.intel.com>
 <613007E2-2A88-4934-9364-A5A66A555305@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5761B630.7020502@linux.intel.com>
Date: Wed, 15 Jun 2016 13:10:24 -0700
MIME-Version: 1.0
In-Reply-To: <613007E2-2A88-4934-9364-A5A66A555305@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "Daniluk, Lukasz" <lukasz.daniluk@intel.com>

On 06/15/2016 01:04 PM, Nadav Amit wrote:
> Be careful here. According to the SDM when invalidating a huge-page,
> each 4KB page needs to be invalidated separately. In practice, when
> Linux invalidates 2MB/1GB pages it performs a full TLB flush. The
> full flush may not be required on knights landing, and specifically
> for the workaround, but you should check.  

Where do you get that?  The SDM says: "they (TLB invalidation operations
invalidate all TLB entries corresponding to the translation specified by
the paging structures."

Here's the full paragraph from the SDM

... some processors may choose to cache multiple smaller-page TLB
entries for a translation specified by the paging structures to use a
page larger than 4 KBytes. There is no way for software to be aware
that multiple translations for smaller pages have been used for a large
page. The INVLPG instruction and page faults provide the same assurances
that they provide when a single TLB entry is used: they invalidate all
TLB entries corresponding to the translation specified by the paging
structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
