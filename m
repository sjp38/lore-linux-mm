Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DAF576B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 18:03:59 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2386522pdj.38
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 15:03:59 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id rj9si933455pbc.246.2014.04.24.15.03.55
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 15:03:55 -0700 (PDT)
Message-ID: <53598A48.2090909@sr71.net>
Date: Thu, 24 Apr 2014 15:03:52 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182426.D6DD1E8F@viggo.jf.intel.com> <20140424103727.GT23991@suse.de> <53594920.8030203@sr71.net> <53594FB3.9050505@redhat.com>
In-Reply-To: <53594FB3.9050505@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, alex.shi@linaro.org, dave.hansen@linux.intel.com, "H. Peter Anvin" <hpa@zytor.com>

On 04/24/2014 10:53 AM, Rik van Riel wrote:
>> I do agree that it's ambiguous at best.  I'll go see if anybody cares to
>> update that bit.
> 
> I suspect that IF the TLB actually uses a 2MB entry for the
> translation, a single INVLPG will work.
> 
> However, the CPU is free to cache the translations for a 2MB
> region with a bunch of 4kB entries, if it wanted to, so in
> the end we have no guarantee that an INVLPG will actually do
> the right thing...
> 
> The same is definitely true for 1GB vs 2MB entries, with
> some CPUs being capable of parsing page tables with 1GB
> entries, but having no TLB entries for 1GB translations.

I believe we _do_ have such a guarantee.  There's another bit in the SDM
that someone pointed out to me in a footnote in "4.10.4.1":

	1. If the paging structures map the linear address using a page
	larger than 4 KBytes and there are multiple TLB entries for
	that page (see Section 4.10.2.3), the instruction invalidates
	all of them.

While that's not in the easiest-to-find place in the documents, it looks
pretty clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
