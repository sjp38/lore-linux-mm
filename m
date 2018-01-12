Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7336B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:28:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r63so2178185wmb.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:28:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 189si1402071wmr.127.2018.01.11.16.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 16:28:29 -0800 (PST)
Date: Thu, 11 Jan 2018 16:28:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, THP: vmf_insert_pfn_pud depends on
 CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
Message-Id: <20180111162825.4cdaba2a21d8f15b21c45c75@linux-foundation.org>
In-Reply-To: <71853228-0beb-1e69-df47-59fa1bc5bd2f@upmem.com>
References: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
	<20180111100620.GY1732@dhcp22.suse.cz>
	<71853228-0beb-1e69-df47-59fa1bc5bd2f@upmem.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <aghiti@upmem.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, gregkh@linuxfoundation.org, n-horiguchi@ah.jp.nec.com, willy@linux.intel.com, mark.rutland@arm.com, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 14:05:34 +0100 Alexandre Ghiti <aghiti@upmem.com> wrote:

> On 11/01/2018 11:06, Michal Hocko wrote:
> > On Thu 11-01-18 09:53:31, Alexandre Ghiti wrote:
> >> The only definition of vmf_insert_pfn_pud depends on
> >> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD being defined. Then its declaration in
> >> include/linux/huge_mm.h should have the same restriction so that we do
> >> not expose this function if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is
> >> not defined.
> > Why is this a problem? Compiler should simply throw away any
> > declarations which are not used?
> It is not a big problem but surrounding the declaration with the #ifdef 
> makes the compilation of external modules fail with an "error: implicit 
> declaration of function vmf_insert_pfn_pud" if 
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is not defined. I think it is 
> cleaner than generating a .ko which would not load anyway.

Disagree.  We'd have to put an absolutely vast amount of complex and
hard-to-maintain ifdefs in headers if we were to ensure that such
errors were to be detected at compile time.

Whereas if we defer the detection of the errors until link time (or
depmod or modprobe time) then yes, a handful of people will detect
their mistake a minute or three later but that's a small cost compared
to permanently and badly messing up the header files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
