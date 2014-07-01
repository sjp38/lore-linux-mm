Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 87AC86B0035
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:52:12 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so8603625wib.6
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:52:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v8si29632134wjq.85.2014.07.01.14.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 14:52:11 -0700 (PDT)
Date: Tue, 1 Jul 2014 17:51:56 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 11/13] mempolicy: apply page table walker on
 queue_pages_range()
Message-ID: <20140701215156.GA21032@nhori.bos.redhat.com>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <53B32170.1040707@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53B32170.1040707@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, Jet Chen <jet.chen@intel.com>

On Tue, Jul 01, 2014 at 02:00:32PM -0700, Dave Hansen wrote:
> On 07/01/2014 10:07 AM, Naoya Horiguchi wrote:
> > queue_pages_range() does page table walking in its own way now, but there
> > is some code duplicate. This patch applies page table walker to reduce
> > lines of code.
> > 
> > queue_pages_range() has to do some precheck to determine whether we really
> > walk over the vma or just skip it. Now we have test_walk() callback in
> > mm_walk for this purpose, so we can do this replacement cleanly.
> > queue_pages_test_walk() depends on not only the current vma but also the
> > previous one, so queue_pages->prev is introduced to remember it.
> 
> Hi Naoya,
> 
> The previous version of this patch caused a performance regression which
> was reported to you:
> 
> 	http://marc.info/?l=linux-kernel&m=140375975525069&w=2
> 
> Has that been dealt with in this version somehow?

I believe so, in previous version we called ->pte_entry() callback
for each pte entries, but in this version I stop doing this and
most of works are done in ->pmd_entry() callback, so the number
of function calls are reduced by about 1/512. And rather than that,
I just cleaned up queue_pages_* without major behavioral changes, so
the visible regression should be solved.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
