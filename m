Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 1FEC06B0087
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:37:12 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so437793dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:37:11 -0800 (PST)
Date: Wed, 14 Nov 2012 15:37:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 09/11] thp: lazy huge zero page allocation
In-Reply-To: <1352300463-12627-10-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141535190.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-10-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Instead of allocating huge zero page on hugepage_init() we can postpone it
> until first huge zero page map. It saves memory if THP is not in use.
> 

Is it worth the branch on every non-write pagefault after that?  The 
unlikely() is not going to help on x86.  If thp is enabled in your 
.config (which isn't the default), then I think it's better to just 
allocate the zero huge page once and avoid any branches after that to 
lazily allocate it.  (Or do it only when thp is set to "madvise" or 
"always" if booting with transparent_hugepage=never.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
