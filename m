Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19FD36B0351
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:47:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r89so69588pfi.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:47:19 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r76si1809307pfj.47.2017.03.24.04.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 04:47:14 -0700 (PDT)
Date: Fri, 24 Mar 2017 14:47:09 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [x86/mm/gup] 2947ba054a [   71.329069] kernel BUG at
 include/linux/pagemap.h:151!
Message-ID: <20170324114709.pcytvyb3d6ajux33@black.fi.intel.com>
References: <20170319225124.xodpqjldom6ceazz@wfg-t540p.sh.intel.com>
 <20170324102436.xltop6udkx5pg4oq@node.shutemov.name>
 <20170324105153.xvy5rcuawicqoanl@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170324105153.xvy5rcuawicqoanl@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, LKP <lkp@01.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, Mar 24, 2017 at 11:51:53AM +0100, Peter Zijlstra wrote:
> On Fri, Mar 24, 2017 at 01:24:36PM +0300, Kirill A. Shutemov wrote:
> 
> > I'm not sure what is the best way to fix this.
> > Few options:
> >  - Drop the VM_BUG();
> >  - Bump preempt count during __get_user_pages_fast();
> >  - Use get_page() instead of page_cache_get_speculative() on x86.
> > 
> > Any opinions?
> 
> I think I'm in favour of the first; either remove or amend to include
> irqs_disabled() or so.
> 
> This in favour of keeping the variants of GUP down.

Something like this?

-------------------8<-----------------------
