Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4A26B026F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:40:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b5-v6so3398130pfi.5
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:40:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o61-v6si7691947pld.109.2018.06.22.08.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 08:40:00 -0700 (PDT)
Date: Fri, 22 Jun 2018 18:39:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180622153949.sjfdaeax6exfzxx2@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
 <169af1d8-7fb6-5e1a-4f34-0150570018cc@intel.com>
 <20180618100721.qvm4maovfhxbfoo7@black.fi.intel.com>
 <7fab87eb-7b6d-6995-b6c6-46c0fd049d2a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fab87eb-7b6d-6995-b6c6-46c0fd049d2a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 18, 2018 at 12:54:29PM +0000, Dave Hansen wrote:
> On 06/18/2018 03:07 AM, Kirill A. Shutemov wrote:
> > On Wed, Jun 13, 2018 at 06:20:10PM +0000, Dave Hansen wrote:
> >>> +int page_keyid(const struct page *page)
> >>> +{
> >>> +	if (mktme_status != MKTME_ENABLED)
> >>> +		return 0;
> >>> +
> >>> +	return lookup_page_ext(page)->keyid;
> >>> +}
> >>> +EXPORT_SYMBOL(page_keyid);
> >> Please start using a proper X86_FEATURE_* flag for this.  It will give
> >> you all the fancy static patching that you are missing by doing it this way.
> > There's no MKTME CPU feature.
> 
> Right.  We have tons of synthetic features that have no basis in the
> hardware CPUID feature.

I've tried the approach, but it doesn't fit here.

We enable MKTME relatively late during boot process -- after page_ext as
page_keyid() depends on it. Enabling it earlier would make page_keyid()
return garbage.

By the time page_ext initialized, CPU features is already handled and
setup_force_cpu_cap() doesn't do anything.

I've implemented the enabling with static key instead.

-- 
 Kirill A. Shutemov
