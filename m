Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7735B831EB
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:22:06 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so61451016pfh.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:22:06 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e69si3565482pgc.181.2017.03.08.07.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:22:05 -0800 (PST)
Date: Wed, 8 Mar 2017 18:21:30 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 6/7] mm: convert generic code to 5-level paging
Message-ID: <20170308152129.sknp75d5usdu4vne@black.fi.intel.com>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
 <20170306204514.1852-7-kirill.shutemov@linux.intel.com>
 <20170308135734.GA11034@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308135734.GA11034@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 08, 2017 at 02:57:35PM +0100, Michal Hocko wrote:
> On Mon 06-03-17 23:45:13, Kirill A. Shutemov wrote:
> > Convert all non-architecture-specific code to 5-level paging.
> > 
> > It's mostly mechanical adding handling one more page table level in
> > places where we deal with pud_t.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> OK, I haven't spotted anything major. I am just scratching my head about
> the __ARCH_HAS_5LEVEL_HACK leak into kasan_init.c (see below). Why do we
> need it?  It looks more than ugly but I am not familiar with kasan so
> maybe this is really necessary.

Yeah ugly.

kasan_zero_p4d is only defined if we have real page table level. It's okay
if the page table level is folded properly -- using pgtable-nop4d.h -- in
this case pgd_populate() is nop and we don't reference kasan_zero_p4d.

With 5level-fixup.h, pgd_populate() is not nop, so we would reference
kasan_zero_p4d and build breaks. We don't need this as p4d_populate()
would do what we really need in this case.

We can drop the hack once all architectures that support kasan would be
converted to pgtable-nop4d.h -- amd64 and x86 at the moment.

Makes sense?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
