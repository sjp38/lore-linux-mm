Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93C9C6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 15:26:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so21159231lfi.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:26:31 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id q20si1063847lfg.373.2016.07.26.12.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 12:26:30 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id 33so902740lfw.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:26:30 -0700 (PDT)
Date: Tue, 26 Jul 2016 22:26:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Message-ID: <20160726192627.GB11776@node.shutemov.name>
References: <1469557631-5752-1-git-send-email-william.c.roberts@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469557631-5752-1-git-send-email-william.c.roberts@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: william.c.roberts@intel.com
Cc: linux-mm@kvack.org

On Tue, Jul 26, 2016 at 11:27:11AM -0700, william.c.roberts@intel.com wrote:
> From: William Roberts <william.c.roberts@intel.com>
> 
> This patch introduces the ability randomize mmap locations where the
> address is not requested, for instance when ld is allocating pages for
> shared libraries. It chooses to randomize based on the current
> personality for ASLR.
> 
> Currently, allocations are done sequentially within unmapped address
> space gaps. This may happen top down or bottom up depending on scheme.
> 
> For instance these mmap calls produce contiguous mappings:
> int size = getpagesize();
> mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40026000
> mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40027000
> 
> Note no gap between.
> 
> After patches:
> int size = getpagesize();
> mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x400b4000
> mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40055000
> 
> Note gap between.

And why is it good?

> Using the test program mentioned here, that allocates fixed sized blocks
> till exhaustion: https://www.linux-mips.org/archives/linux-mips/2011-05/msg00252.html,
> no difference was noticed in the number of allocations. Most varied from
> run to run, but were always within a few allocations of one another
> between patched and un-patched runs.
> 
> Performance Measurements:
> Using strace with -T option and filtering for mmap on the program
> ls shows a slowdown of approximate 3.7%

NAK.

It's just too costly. And no obvious benefits.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
