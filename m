Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8F8882F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:19:06 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id x93so23331293ybh.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 22:19:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o3si11712422ywc.111.2016.08.29.22.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 22:19:06 -0700 (PDT)
Date: Mon, 29 Aug 2016 22:19:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
Message-Id: <20160829221903.3c32b4fd884c97b6a15a4bbb@linux-foundation.org>
In-Reply-To: <57C5162D.80405@linux.vnet.ibm.com>
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
	<20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
	<57C5162D.80405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Aaron Lu <aaron.lu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2016 10:44:21 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> On 08/30/2016 04:20 AM, Andrew Morton wrote:
> > On Mon, 29 Aug 2016 14:31:20 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> > 
> >> > 
> >> > The global zero page is used to satisfy an anonymous read fault. If
> >> > THP(Transparent HugePage) is enabled then the global huge zero page is used.
> >> > The global huge zero page uses an atomic counter for reference counting
> >> > and is allocated/freed dynamically according to its counter value.
> >> > 
> >> > CPU time spent on that counter will greatly increase if there are
> >> > a lot of processes doing anonymous read faults. This patch proposes a
> >> > way to reduce the access to the global counter so that the CPU load
> >> > can be reduced accordingly.
> >> > 
> >> > To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
> >> > With this flag, the process only need to touch the global counter in
> >> > two cases:
> >> > 1 The first time it uses the global huge zero page;
> >> > 2 The time when mm_user of its mm_struct reaches zero.
> >> > 
> >> > Note that right now, the huge zero page is eligible to be freed as soon
> >> > as its last use goes away.  With this patch, the page will not be
> >> > eligible to be freed until the exit of the last process from which it
> >> > was ever used.
> >> > 
> >> > And with the use of mm_user, the kthread is not eligible to use huge
> >> > zero page either. Since no kthread is using huge zero page today, there
> >> > is no difference after applying this patch. But if that is not desired,
> >> > I can change it to when mm_count reaches zero.
> 
> > I suppose we could simply never free the zero huge page - if some
> > process has used it in the past, others will probably use it in the
> > future.  One wonders how useful this optimization is...
> 
> Yeah, what prevents us from doing away with this lock altogether and
> keep one zero filled huge page (after a process has used it once) for
> ever to be mapped across all the read faults ? A 16MB / 2MB huge page
> is too much of memory loss on a THP enabled system ? We can also save
> on allocation time.

Sounds OK to me.  But only if it makes a useful performance benefit to
something that someone cares about!

otoh, that patch is simple enough...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
