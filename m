Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 898666B72A5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:25:30 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so14208027ply.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:25:30 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id n184si16370570pgn.95.2018.12.04.21.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:25:29 -0800 (PST)
Date: Tue, 4 Dec 2018 21:28:03 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 07/13] x86/mm: Add helpers for reference counting
 encrypted VMAs
Message-ID: <20181205052802.GA18596@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <e4407d95c74300c4a6b4c5f9321660e9097fff8f.1543903910.git.alison.schofield@intel.com>
 <20181204085835.GO11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204085835.GO11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 09:58:35AM +0100, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:39:54PM -0800, Alison Schofield wrote:
> 
> > +void vma_put_encrypt_ref(struct vm_area_struct *vma)
> > +{
> > +	if (vma_keyid(vma))
> > +		if (refcount_dec_and_test(&encrypt_count[vma_keyid(vma)])) {
> > +			mktme_map_lock();
> > +			mktme_map_free_keyid(vma_keyid(vma));
> > +			mktme_map_unlock();
> > +		}
> 
> This violates CodingStyle

Got it!
Will fix this and the other instances where you noticed poorly nested
if statements. 

> > +	if (refcount_dec_and_test(&encrypt_count[keyid])) {
> > +		mktme_map_lock();
> 
> That smells like it wants to use refcount_dec_and_lock() instead.
> 
> Also, if you write that like:
> 
> 	if (!refcount_dec_and_lock(&encrypt_count[keyid], &lock))
> 		return;
> 
> you loose an indent level.
Looks good! I need to make sure it's OK to switch to a spinlock to use
the *_lock functions.
