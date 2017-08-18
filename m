Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0196B04AC
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 17:03:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i66so5635546wmg.12
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 14:03:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o20si4954370wro.120.2017.08.18.14.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 14:03:03 -0700 (PDT)
Date: Fri, 18 Aug 2017 14:03:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-4.12 539/540] mm/compaction.c:469:8: error:
 implicit declaration of function 'pageblock_skip_persistent'
Message-Id: <20170818140300.d97c99cc5bd60c0f924a6e9a@linux-foundation.org>
In-Reply-To: <fac0ae1a-7de3-bb98-53c8-f63f205f5c04@redhat.com>
References: <201708190034.TmrRSDV7%fengguang.wu@intel.com>
	<fac0ae1a-7de3-bb98-53c8-f63f205f5c04@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>

On Fri, 18 Aug 2017 12:57:48 -0400 Waiman Long <longman@redhat.com> wrote:

> On 08/18/2017 12:42 PM, kbuild test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.12
> > head:   ba5e8c23db5729ebdbafad983b07434c829cf5b6
> > commit: 500539d3686a835f6a9740ffc38bed5d74951a64 [539/540] debugobjects: make kmemleak ignore debug objects
> > config: i386-randconfig-s0-08141822 (attached as .config)
> > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > reproduce:
> >         git checkout 500539d3686a835f6a9740ffc38bed5d74951a64
> >         # save the attached .config to linux build tree
> >         make ARCH=i386 
> >
> > All errors (new ones prefixed by >>):
> >
> >    mm/compaction.c: In function 'isolate_freepages_block':
> >>> mm/compaction.c:469:8: error: implicit declaration of function 'pageblock_skip_persistent' [-Werror=implicit-function-declaration]
> >        if (pageblock_skip_persistent(page, order)) {
> >            ^~~~~~~~~~~~~~~~~~~~~~~~~
> >>> mm/compaction.c:470:5: error: implicit declaration of function 'set_pageblock_skip' [-Werror=implicit-function-declaration]
> >         set_pageblock_skip(page);
> >         ^~~~~~~~~~~~~~~~~~
> >    cc1: some warnings being treated as errors
> >
> > vim +/pageblock_skip_persistent +469 mm/compaction.c
> 
> It is not me. My patch doesn't touch any header file and
> mm/compaction.c. So it can't cause this kind of errors.
> 

Yes, that's wrong.  It's David's "mm, compaction: persistently skip
hugetlbfs pageblocks".  I'll do this:


--- a/mm/compaction.c~mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix
+++ a/mm/compaction.c
@@ -327,6 +327,11 @@ static void update_pageblock_skip(struct
 			bool migrate_scanner)
 {
 }
+
+static bool pageblock_skip_persistent(struct page *page, unsigned int order)
+{
+	return false;
+}
 #endif /* CONFIG_COMPACTION */
 
 /*
--- a/include/linux/pageblock-flags.h~mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix
+++ a/include/linux/pageblock-flags.h
@@ -96,6 +96,8 @@ void set_pfnblock_flags_mask(struct page
 #define set_pageblock_skip(page) \
 			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
 							PB_migrate_skip)
+#else
+#define set_pageblock_skip(page) do { } while (0)
 #endif /* CONFIG_COMPACTION */
 
 #endif	/* PAGEBLOCK_FLAGS_H */

Those macros in pageblock-flags.h are obnoxious and reference their
args multiple times.  I'll see what happens if they're turned into C
functions...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
