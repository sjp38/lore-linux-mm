Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABA58E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:30:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g18-v6so11472778edg.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a21-v6si11104275edr.179.2018.09.25.11.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 11:30:20 -0700 (PDT)
Date: Tue, 25 Sep 2018 20:30:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Disable movable allocation for TRANSHUGE pages
Message-ID: <20180925183019.GB22630@dhcp22.suse.cz>
References: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
 <20180925115153.z5b5ekijf5jzhzmn@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925115153.z5b5ekijf5jzhzmn@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ashish Mhetre <amhetre@nvidia.com>, linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Tue 25-09-18 14:51:53, Kirill A. Shutemov wrote:
> On Tue, Sep 25, 2018 at 12:55:33PM +0530, Ashish Mhetre wrote:
> > TRANSHUGE pages have no migration support.
> 
> Transparent pages have migration support since v4.14.

This is true but not for all architectures AFAICS. In fact git grep
suggests that only x86 supports the migration. So unless I am missing
something the patch has some merit. But the implementation is simply
wrong. If anything it should be something like

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 76f8db0b0e71..2aff77966d92 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -297,7 +297,14 @@ struct vm_area_struct;
 #define GFP_DMA32	__GFP_DMA32
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
-#define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#define GFP_TRANSHUGE_MOVABLE __GFP_MOVABLE
+#else
+#define GFP_TRANSHUGE_MOVABLE 0
+#endif
+
+#define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER |GFP_TRANSHUGE_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
 #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
 

-- 
Michal Hocko
SUSE Labs
