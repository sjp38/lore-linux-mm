Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9F06B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:33:34 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so9420912pbc.5
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 11:33:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id eq2si25246439pbb.202.2013.12.27.11.33.32
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 11:33:32 -0800 (PST)
Date: Fri, 27 Dec 2013 14:33:30 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
Message-ID: <20131227193330.GE4945@linux.intel.com>
References: <20131227180018.GC4945@linux.intel.com>
 <BLU0-SMTP17D26551261DF285A7E6F497CD0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU0-SMTP17D26551261DF285A7E6F497CD0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John David Anglin <dave.anglin@bell.net>
Cc: linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

On Fri, Dec 27, 2013 at 02:13:16PM -0500, John David Anglin wrote:
> On 27-Dec-13, at 1:00 PM, Matthew Wilcox wrote:
> 
> >+#ifdef __ARCH_FORCE_SHMLBA
> >+	/* Is the mapping cache-coherent? */
> >+	if ((pgoff ^ linear_page_index(vma, start)) &
> >+	    ((SHMLBA-1) >> PAGE_SHIFT))
> >+		goto out;
> >+#endif
> 
> 
> I think this will cause problems on PA-RISC.  The reason is we have
> an additional offset
> for mappings.  See get_offset() in sys_parisc.c.

I don't think it will cause any additional problems.  The test merely
asks "Is the offset to put at this address cache-coherent with the offset
that was at this address when the mmap was established?"

> SHMLBA is 4 MB on PA-RISC.  If we limit ourselves to aligned
> mappings, we run out of
> memory very quickly.  Even with our current implementation, we fail
> the perl locales test
> with locales-all installed.

I know the large SHMLBA is problematic for PA-RISC, but I don't think
there's a lot of code out there using remap_file_pages().  code.google.com
found almost nothing, and a regular google search found only a couple
of little toys.

Have you considered measuring SHMLBA on different CPU models and
reducing it at boot time?  I know that 4MB is the architectural guarantee
(actually, I seem to remember that 16MB was the architectural guarantee,
but jsm found some CPU architects who said it would enver exceed 4MB).
I bet some CPUs have considerably lower cache coherency limits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
