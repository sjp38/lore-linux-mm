Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23D266B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:25:03 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t1-v6so838335ply.16
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:25:03 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d2-v6si8433010pla.359.2018.07.23.10.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 10:25:02 -0700 (PDT)
Date: Mon, 23 Jul 2018 10:22:49 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [PATCHv5 10/19] x86/mm: Implement page_keyid() using page_ext
Message-ID: <20180723172249.GA13530@alison-desk.jf.intel.com>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-11-kirill.shutemov@linux.intel.com>
 <2166be55-3491-f620-5eb0-6f671a53645f@intel.com>
 <20180723094517.7sxt62p3h75htppw@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723094517.7sxt62p3h75htppw@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 23, 2018 at 12:45:17PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 04:38:02PM -0700, Dave Hansen wrote:
> > On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > > Store KeyID in bits 31:16 of extended page flags. These bits are unused.
> > 
> > I'd love a two sentence remind of what page_ext is and why you chose to
> > use it.  Yes, you need this.  No, not everybody that you want to review
> > this patch set knows what it is or why you chose it.
> 
> Okay.
> 
> > > page_keyid() returns zero until page_ext is ready.
> > 
> > Is there any implication of this?  Or does it not matter because we
> > don't run userspace until after page_ext initialization is done?
> 
> It matters in sense that we shouldn't reference page_ext before it's
> initialized otherwise we will get garbage and crash.
> 
> > > page_ext initializer enables static branch to indicate that
> > 
> > 			"enables a static branch"
> > 
> > > page_keyid() can use page_ext. The same static branch will gate MKTME
> > > readiness in general.
> > 
> > Can you elaborate on this a bit?  It would also be a nice place to hint
> > to the folks working hard on the APIs to ensure she checks this.
> 
> Okay.

At API init time we can check if (MKTME_ENABLED &&  mktme_nr_keyids > 0)
Sounds like this is another dependency we need to check and 'wait' on?
It happens after MKTME_ENABLED is set?  Let me know.

> 
> > > We don't yet set KeyID for the page. It will come in the following
> > > patch that implements prep_encrypted_page(). All pages have KeyID-0 for
> > > now.
> > 
> > It also wouldn't hurt to mention why you don't use an X86_FEATURE_* for
> > this rather than an explicit static branch.  I'm sure the x86
> > maintainers will be curious.
> 
> Sure.
> 
> -- 
>  Kirill A. Shutemov
