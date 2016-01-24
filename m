Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 20DC86B0009
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 04:03:51 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id u188so31984278wmu.1
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 01:03:51 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id y126si16705571wmd.120.2016.01.24.01.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 01:03:49 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id b14so5713716wmb.1
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 01:03:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <100D68C7BA14664A8938383216E40DE0421657C5@fmsmsx111.amr.corp.intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
	<CA+ZsKJ7LgOjuZ091d-ikhuoA+ZrCny4xBGVupv0oai8yB5OqFQ@mail.gmail.com>
	<100D68C7BA14664A8938383216E40DE0421657C5@fmsmsx111.amr.corp.intel.com>
Date: Sun, 24 Jan 2016 01:03:49 -0800
Message-ID: <CA+ZsKJ4EMKRgdFQzUjRJOE48=tTJzHf66-60PnVRj7pxvmNgVg@mail.gmail.com>
Subject: Re: [PATCH v12 10/20] dax: Replace XIP documentation with DAX documentation
From: Jared Hulbert <jaredeh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Chris Brandt <Chris.Brandt@renesas.com>

I our defense we didn't know we were sinning at the time.

Can you walk me through the cache flushing hole?  How is it okay on
X86 but not VIVT archs?  I'm missing something obvious here.

I thought earlier that vm_insert_mixed() handled the necessary
flushing.  Is that even the part you are worried about?

vm_insert_mixed()->insert_pfn()->update_mmu_cache() _should_ handle
the flush.  Except of course now that I look at the ARM code it looks
like it isn't doing anything if !pfn_valid().  <sigh>  I need to spend
some more time looking at this again.

What flushing functions would you call if you did have a cache page.
There are all kinds of cache flushing functions that work without a
struct page. If nothing else the specialized ASM instructions that do
the various flushes don't use struct page as a parameter.  This isn't
the first I've run into the lack of a sane cache API.  Grep for
inval_cache in the mtd drivers, should have been much easier.  Isn't
the proper solution to fix update_mmu_cache() or build out a pageless
cache flushing API?

I don't get the explicit mapping solution.  What are you mapping
where?  What addresses would be SHMLBA?  Phys, kernel, userspace?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
