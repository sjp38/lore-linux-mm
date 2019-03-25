Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07599C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 18:28:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79E02070D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 18:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79E02070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15D946B0003; Mon, 25 Mar 2019 14:28:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E8D06B0006; Mon, 25 Mar 2019 14:28:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC6E06B0007; Mon, 25 Mar 2019 14:28:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A66556B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 14:28:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 42so427349pld.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 11:28:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N++kpRceu1TrCUh9A0/cWGjt+rsrS+KjvY8q8Tn+5qI=;
        b=AG4mfAuXNuXLtcJTWfHZ4lruM4WeXPtqS+YOPmPPFVCzBsepNkn1WB94dbdx+2rUBB
         BfYbw6yZ7EZ6mnfgvjB+GqCQCOVpJ42kRMv4bR3EHemY+LPuxorWwzqHfOeBerfGUfM3
         3or2MavV10FphWZr6tiC5dlqFKSOJFHa8/3978EOA4tJms8cLWyXggsTxOnHBfXiG51H
         2hiOBEFkYH0XtD0WLr/Ck891B10L3u3vllUmQ9f1wl61SiZhkLF7TCHPLwMtDviMcsRz
         95En+6SoE9tioQ/l62TlfnnaF+O86xaj4Z9HANQVdD6KNwp9QszAEH6THt/ieDKKajU3
         kceg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUeHtIZBFvOBS+VVNdM1fVxG5MjRDH+CLyg9niXo7oIBK0Ia+99
	zcVlHzOGfSjKGnKFUJ7GUfL5k43jfFbXTxXfgtflFKZkcHMmlhwPvgi0V6RgNu4KGS2kWd18MSz
	1T0kRFWxF3YZb8rxFxe2yLtCEKeCTgR32x2w5Zm6vOWB/iDVKb59O9RRNILLonQPPng==
X-Received: by 2002:a62:304:: with SMTP id 4mr5459272pfd.99.1553538500307;
        Mon, 25 Mar 2019 11:28:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywUyyZbcLTn29n4rlRwr0JankmswRYYtpmohqX4tgiLrokgSRB2/SvZZjBQpDpTUWR6wNd
X-Received: by 2002:a62:304:: with SMTP id 4mr5459190pfd.99.1553538499273;
        Mon, 25 Mar 2019 11:28:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553538499; cv=none;
        d=google.com; s=arc-20160816;
        b=TwiNop7BgKhPQ0awGeKxG7BgZIM9SvB0OXIZdqfnQhL5KxXDDvUtvuoOnHWNzxp1Zq
         wWiTjdvfWtEZ9XXXDURKy1r0fIYdASH/6fXk0iCbk0ZmxOufCXeJW1429zpKKq941Asc
         yJJvu/f9YlXw1xnlCFwSNOZOOMQwvpGW82qmOY4JNRq8kcafqYw4J8srrYJPqEQPmXN5
         5gstGlW3Fv4p3BicB6Vkq1BJisd8A/EKFdMc/DIac5s/nuW/bydhAc58fy+XmpM2Ryl5
         0tnND+WyNFu2dhsjtricLxMmENoau1Dh1HYHEYoF+ugg0tRafphuP/q4U2lJ0Y3dKycw
         AdKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N++kpRceu1TrCUh9A0/cWGjt+rsrS+KjvY8q8Tn+5qI=;
        b=xhacgKxl1XO4VoPxwj59d+R6mPbdKci8g7FeLi1p6uVpneH9VomuMW+wgq/eJ+dDmR
         vvot6Ckvew7GliNP534Eh+Uuyalic3jYplmdeYWUumzwf8tTbt+SMyYhfpYMkdxS1WWI
         jKcFmxBLUMhAkSG3nVm3+ha24U9c+LEJza0MMboMqVG5SvPxfuTIxOhFV4zSnWQ8dudD
         GnP8Bd3ndXvbcwy7dO3l/m+rRoQwrwC138foNLLDUMLw7b79H8iKd4QrU+b9y91BP+9G
         ZFLtnp1RLqW7xhiI7XUvGH1z5ghSTrX+6Vav/glVwtmZgTi+ad2nIMH5t/6BgMK3XMv3
         gDKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q29si14637359pfi.98.2019.03.25.11.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 11:28:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 11:28:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="125755489"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 25 Mar 2019 11:28:17 -0700
Date: Mon, 25 Mar 2019 03:27:05 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 1/7] mm/gup: Replace get_user_pages_longterm() with
 FOLL_LONGTERM
Message-ID: <20190325102705.GG16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-2-ira.weiny@intel.com>
 <CAA9_cmffz1VBOJ0ykBtcj+hiznn-kbbuotu1uUhPiJtXiFjJXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmffz1VBOJ0ykBtcj+hiznn-kbbuotu1uUhPiJtXiFjJXg@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 02:24:40PM -0700, Dan Williams wrote:
> On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:

[snip]

> > + * __gup_longterm_locked() is a wrapper for __get_uer_pages_locked which
> 
> s/uer/user/
> 
> > + * allows us to process the FOLL_LONGTERM flag if present.
> > + *
> > + * FOLL_LONGTERM Checks for either DAX VMAs or PPC CMA regions and either fails
> > + * the pin or attempts to migrate the page as appropriate.
> > + *
> > + * In the filesystem-dax case mappings are subject to the lifetime enforced by
> > + * the filesystem and we need guarantees that longterm users like RDMA and V4L2
> > + * only establish mappings that have a kernel enforced revocation mechanism.
> > + *
> > + * In the CMA case pages can't be pinned in a CMA region as this would
> > + * unnecessarily fragment that region.  So CMA attempts to migrate the page
> > + * before pinning.
> >   *
> >   * "longterm" == userspace controlled elevated page count lifetime.
> >   * Contrast this to iov_iter_get_pages() usages which are transient.
> 
> Ah, here's the longterm documentation, but if I was a developer
> considering whether to use FOLL_LONGTERM or not I would expect to find
> the documentation at the flag definition site.
> 
> I think it has become more clear since get_user_pages_longterm() was
> initially merged that we need to warn people not to use it, or at
> least seriously reconsider whether they want an interface to support
> indefinite pins.

I will move the comment to the flag definition but...

In reviewing this comment it occurs to me that the addition of special casing
CMA regions via FOLL_LONGTERM has made it less experimental/temporary and now
simply implies intent to the GUP code as to the use of the pages.

As I'm not super familiar with the CMA use case I can't say for certain but it
seems that it is not a temporary solution.

So I'm not going to refrain from a FIXME WRT removing the flag.

New suggested text below.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6831077d126c..5db9d8e894aa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2596,7 +2596,28 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_REMOTE    0x2000  /* we are working on non-current tsk/mm */
 #define FOLL_COW       0x4000  /* internal GUP flag */
 #define FOLL_ANON      0x8000  /* don't do file mappings */
-#define FOLL_LONGTERM  0x10000 /* mapping is intended for a long term pin */
+#define FOLL_LONGTERM  0x10000 /* mapping lifetime is indefinite: see below */
+
+/*
+ * NOTE on FOLL_LONGTERM:
+ *
+ * FOLL_LONGTERM indicates that the page will be held for an indefinite time
+ * period _often_ under userspace control.  This is contrasted with
+ * iov_iter_get_pages() where usages which are transient.
+ *
+ * FIXME: For pages which are part of a filesystem, mappings are subject to the
+ * lifetime enforced by the filesystem and we need guarantees that longterm
+ * users like RDMA and V4L2 only establish mappings which coordinate usage with
+ * the filesystem.  Ideas for this coordination include revoking the longterm
+ * pin, delaying writeback, bounce buffer page writeback, etc.  As FS DAX was
+ * added after the problem with filesystems was found FS DAX VMAs are
+ * specifically failed.  Filesystem pages are still subject to bugs and use of
+ * FOLL_LONGTERM should be avoided on those pages.
+ *
+ * In the CMA case: longterm pins in a CMA region would unnecessarily fragment
+ * that region.  And so CMA attempts to migrate the page before pinning when
+ * FOLL_LONGTERM is specified.
+ */
 
 static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
 {

