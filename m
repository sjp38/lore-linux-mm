Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6956B025B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:12:25 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so289285351pac.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:12:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dy5si77650234pab.142.2016.01.08.15.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:12:24 -0800 (PST)
Date: Fri, 8 Jan 2016 15:12:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm/page_alloc.c: introduce kernelcore=mirror
 option
Message-Id: <20160108151223.a9b7e9099de69dbe6309d159@linux-foundation.org>
In-Reply-To: <568FEBAF.9040405@arm.com>
References: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1452241613-19680-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<568FEBAF.9040405@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, arnd@arndb.de, steve.capper@linaro.org

On Fri, 8 Jan 2016 17:02:39 +0000 Sudeep Holla <sudeep.holla@arm.com> wrote:

> > +
> > +			/*
> > +			 * if not mirrored_kernelcore and ZONE_MOVABLE exists,
> > +			 * range from zone_movable_pfn[nid] to end of each node
> > +			 * should be ZONE_MOVABLE not ZONE_NORMAL. skip it.
> > +			 */
> > +			if (!mirrored_kernelcore && zone_movable_pfn[nid])
> > +				if (zone == ZONE_NORMAL &&
> > +				    pfn >= zone_movable_pfn[nid])
> > +					continue;
> > +
> 
> I tried this with today's -next, the above lines gave compilation error.
> Moved them below into HAVE_MEMBLOCK_NODE_MAP and tested it on ARM64.
> I don't see the previous backtraces. Let me know if that's correct or
> you can post a version that compiles correctly and I can give a try.

Thanks.   I'll include the below and shall add your tested-by:, OK?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-page_allocc-introduce-kernelcore=mirror-option-fix

fix build with CONFIG_HAVE_MEMBLOCK_NODE_MAP=n

Reported-by: Sudeep Holla <sudeep.holla@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Steve Capper <steve.capper@linaro.org>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN Documentation/kernel-parameters.txt~mm-page_allocc-introduce-kernelcore=mirror-option-fix Documentation/kernel-parameters.txt
diff -puN mm/page_alloc.c~mm-page_allocc-introduce-kernelcore=mirror-option-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_allocc-introduce-kernelcore=mirror-option-fix
+++ a/mm/page_alloc.c
@@ -4627,6 +4627,7 @@ void __meminit memmap_init_zone(unsigned
 						&nr_initialised))
 				break;
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 			/*
 			 * if not mirrored_kernelcore and ZONE_MOVABLE exists,
 			 * range from zone_movable_pfn[nid] to end of each node
@@ -4637,7 +4638,6 @@ void __meminit memmap_init_zone(unsigned
 				    pfn >= zone_movable_pfn[nid])
 					continue;
 
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 			/*
 			 * check given memblock attribute by firmware which
 			 * can affect kernel memory layout.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
