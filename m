Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD3A1C31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:36:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81AF321841
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:36:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81AF321841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13A236B026F; Fri, 14 Jun 2019 14:36:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD086B0270; Fri, 14 Jun 2019 14:36:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7ED96B0271; Fri, 14 Jun 2019 14:36:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD70C6B026F
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:36:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so2349413pfv.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:36:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NM9O7OiIIOAneHmYP7fBDG0QJlVHFQg9SbvEgFkcLPY=;
        b=bWMGCOesMEuU+gnudFxGoStBaKWKGh4Hb3OsR6YPpU/dsIoxaWtXlO5krPekHpvVbX
         ixFcBKsdXfHauB8uq8s0m4JQniXDHkjC6qTPjYoAdMALsmecwf5VVXl/JF9zDuGz/NYW
         KtN78FatdfNDj9wg5uzwSl5d9BPFz8M7lqscDnX5gzAPBHhR/3eGVX3hanX32RA769p/
         lyGVEul4dMgbyvXdK8HIYJPcFDjFXxO3csFCSuW8O1upLB81F/zfGmrE3mIz9pzNYCT3
         ni6ZZDr2nsB/2B0u5ZWTfGhLtyX/wU+DbKJX8cfFquH6OMTwux0O+pSEqOZAL7K8FSTd
         F5vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2iZPICwbux4oTRSApLu5PH25azPPcIPvoN1nXZ/fJi/hGOE3g
	HP6cwoZ3rr7xFhWblnBbPahRLSsdezoGonr0jK7JwIrAmN8XcbjLiPQ0iGj2mgnvg/T3CCzaRTD
	xE0Tj5KWKuRYcRrplhjgcd7/tDUoQPgcJIDoat7Hv39OXVctOAanDfTaRdWRCcykncA==
X-Received: by 2002:a17:902:778d:: with SMTP id o13mr44067557pll.82.1560537405354;
        Fri, 14 Jun 2019 11:36:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX5F/X44eI4P9guSxovZdA9D/BHLiQDNl/B1hxz/SNMqjMUJzxdyKl7EDdC3f8lrQRCof0
X-Received: by 2002:a17:902:778d:: with SMTP id o13mr44067474pll.82.1560537404180;
        Fri, 14 Jun 2019 11:36:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560537404; cv=none;
        d=google.com; s=arc-20160816;
        b=BLv85EFiPw6JjTs+uYx9Gl0BFxk9nNWdh15wHmkkO/JzEh6ls9bcFVK9wtrlqp0fWx
         wKfrIejGxL8eVg7I7GWEupsmM9GIwKFv6jyt2jDzP3TUdGgTLBf6jN4MU5m6G2HzsuXX
         utuiBvXBpFt29WHy5kRFHUFFdV8StRrsFC9ycDLPcxqpSogQ1e5rrT3avufn5QI5wtm/
         mrlTg7CMa9GuKh1Gv0mbx2k6nnYgfkMYi43uMQt3MaupoG48fQgmTYiXcB5fJzVLCUa5
         On0TIZ8DiaqzLdAjCdl0Q5rprn7szvpq+d/VWTte16k81aH/OVrWoJ2KTSJUnGmh7c8A
         9vYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NM9O7OiIIOAneHmYP7fBDG0QJlVHFQg9SbvEgFkcLPY=;
        b=D8LtYUCsUUuPKqNireKbJiA7jY5yvJ90BdrsDvUlQszapzVgZLzUYKOVMpoCJ1Xsdp
         STMBwF1+r7TUSqsYjWS/RZLXIjIE4MCjaijpSmi2zL7FNUjwAv3vz4ZuqHmSPDaOGSdm
         zAovKsJtPAV1TR5DYvaJ/4/L3UukNYzlVFSryhwmQ1LE/jhc1PukimKonSH4/MrxhU6Q
         UIVI0DnSsRNY0+hYN6mnLcUQP5hmUCwlshSfdcCVBicA0J91+KnS6jnDLe5FZH5/RgJO
         PMYbHADL4Qa8PraWC5xpk8T59klQRJOJlIVuW2q1reWWyXytDmWl5MEcU+DcWaZrCuGm
         DyEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k11si2766933pll.377.2019.06.14.11.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:36:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 11:36:41 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga008-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 11:36:40 -0700
Date: Fri, 14 Jun 2019 11:39:47 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 46/62] x86/mm: Keep reference counts on encrypted
 VMAs for MKTME
Message-ID: <20190614183947.GA7252@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-47-kirill.shutemov@linux.intel.com>
 <20190614115424.GG3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614115424.GG3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:54:24PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:06PM +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > The MKTME (Multi-Key Total Memory Encryption) Key Service needs
> > a reference count on encrypted VMAs. This reference count is used
> > to determine when a hardware encryption KeyID is no longer in use
> > and can be freed and reassigned to another Userspace Key.
> > 
> > The MKTME Key service does the percpu_ref_init and _kill, so
> > these gets/puts on encrypted VMA's can be considered the
> > intermediaries in the lifetime of the key.
> > 
> > Increment/decrement the reference count during encrypt_mprotect()
> > system call for initial or updated encryption on a VMA.
> > 
> > Piggy back on the vm_area_dup/free() helpers. If the VMAs being
> > duplicated, or freed are encrypted, adjust the reference count.
> 
> That all talks about VMAs, but...
> 
> > @@ -102,6 +115,22 @@ void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> >  
> >  		page++;
> >  	}
> > +
> > +	/*
> > +	 * Make sure the KeyID cannot be freed until the last page that
> > +	 * uses the KeyID is gone.
> > +	 *
> > +	 * This is required because the page may live longer than VMA it
> > +	 * is mapped into (i.e. in get_user_pages() case) and having
> > +	 * refcounting per-VMA is not enough.
> > +	 *
> > +	 * Taking a reference per-4K helps in case if the page will be
> > +	 * split after the allocation. free_encrypted_page() will balance
> > +	 * out the refcount even if the page was split and freed as bunch
> > +	 * of 4K pages.
> > +	 */
> > +
> > +	percpu_ref_get_many(&encrypt_count[keyid], 1 << order);
> >  }

snip

> 
> counts pages, what gives?

Yeah. Comments are confusing. We implemented the refcounting w VMA's in
mind, and then added the page counting. I'll update the comments and
dig around some more based on your overall concerns about the
refcounting you mentioned in the cover letter.



