Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7200C6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 14:00:37 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so2119122eei.19
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:00:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si9422183eep.137.2014.04.24.11.00.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 11:00:35 -0700 (PDT)
Date: Thu, 24 Apr 2014 19:00:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] x86: mm: rip out complicated, out-of-date, buggy TLB
 flushing
Message-ID: <20140424180030.GX23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182421.DFAAD16A@viggo.jf.intel.com>
 <20140424084552.GQ23991@suse.de>
 <535942A3.3020800@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <535942A3.3020800@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On Thu, Apr 24, 2014 at 09:58:11AM -0700, Dave Hansen wrote:
> On 04/24/2014 01:45 AM, Mel Gorman wrote:
> >> +/*
> >> + * See Documentation/x86/tlb.txt for details.  We choose 33
> >> + * because it is large enough to cover the vast majority (at
> >> + * least 95%) of allocations, and is small enough that we are
> >> + * confident it will not cause too much overhead.  Each single
> >> + * flush is about 100 cycles, so this caps the maximum overhead
> >> + * at _about_ 3,000 cycles.
> >> + */
> >> +/* in units of pages */
> >> +unsigned long tlb_single_page_flush_ceiling = 1;
> >> +
> > 
> > This comment is premature. The documentation file does not exist yet and
> > 33 means nothing yet. Out of curiousity though, how confident are you
> > that a TLB flush is generally 100 cycles across different generations
> > and manufacturers of CPUs? I'm not suggesting you change it or auto-tune
> > it, am just curious.
> 
> Yeah, the comment belongs in the later patch where I set it to 33.
> 
> I looked at this on the last few generations of Intel CPUs.  "100
> cycles" was a very general statement, and not precise at all.  My laptop
> averages out to 113 cycles overall, but the flushes of 25 pages averaged
> 96 cycles/page while the flushes of 2 averaged 219/page.
> 
> Those cycles include some costs of from the instrumentation as well.
> 
> I did not test on other CPU manufacturers, but this should be pretty
> easy to reproduce.  I'm happy to help folks re-run it on other hardware.
> 
> I also believe with the modalias stuff we've got in sysfs for the CPU
> objects we can do this in the future with udev rules instead of
> hard-coding it in the kernel.
> 

You convinced me. Regardless of whether you move the comment or update
the changelog;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
