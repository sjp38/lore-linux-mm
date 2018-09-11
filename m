Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2B98E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:39:01 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22-v6so10836035plq.21
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 19:39:01 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id k195-v6si12408591pgc.53.2018.09.10.19.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 19:38:59 -0700 (PDT)
Date: Mon, 10 Sep 2018 19:39:31 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 08/12] mm: Track VMA's in use for each memory encryption
 keyid
Message-ID: <20180911023931.GB1732@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <3c891d076a376c8cff04403e90d04cf98b203960.1536356108.git.alison.schofield@intel.com>
 <781e142c17199a6ab44bf0b5fbf07190093fe5dc.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <781e142c17199a6ab44bf0b5fbf07190093fe5dc.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

On Mon, Sep 10, 2018 at 09:20:45PM +0300, Jarkko Sakkinen wrote:
> On Fri, 2018-09-07 at 15:37 -0700, Alison Schofield wrote:
> > Keep track of the VMA's oustanding for each memory encryption keyid.
> > The count is used by the MKTME (Multi-Key Total Memory Encryption)
> > Key Service to determine when it is safe to reprogram a hardware
> > encryption key.
> 
> Maybe a stupid question but why they are tracked and what do you 
> mean by tracking?
> 
> /Jarkko

Perhaps 'Keep a count of' instead of 'Keep track of' will be clearer.

Counting VMA's using each keyid prevents in use keys from being cleared
and reused. The counting is done here, and the mtkme key service checks
these counts to decide if it is OK to allow a userspace key to be revoked.
A successful userspace key revoke will clear the hardware keyid slot and
leave the key available to be reprogrammed.

> 
> > Approach here is to do gets and puts on the encryption reference
> > wherever kmem_cache_alloc/free's of vma_area_cachep's are executed.
> > A couple of these locations will not be hit until cgroup support is
> > added. One of these locations should never hit, so use a VM_WARN_ON.
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > ---
> >  arch/x86/mm/mktme.c |  2 ++
> >  kernel/fork.c       |  2 ++
> >  mm/mmap.c           | 12 ++++++++++++
> >  mm/nommu.c          |  4 ++++
> >  4 files changed, 20 insertions(+)
> > 

.... snip ....
