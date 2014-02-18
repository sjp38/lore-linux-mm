Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 62B0C6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:38:41 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so17352752pab.37
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:38:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id kr1si6326304pbc.325.2014.02.18.14.38.40
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 14:38:40 -0800 (PST)
Date: Tue, 18 Feb 2014 14:38:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
Message-Id: <20140218143838.aee7a4f0c94ab28b3b04c1e4@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1402181421590.20772@chino.kir.corp.google.com>
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402181421590.20772@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Feb 2014 14:23:44 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Tue, 18 Feb 2014, Raghavendra K T wrote:
> 
> > Currently max_sane_readahead() returns zero on the cpu having no local memory node
> > which leads to readahead failure. Fix the readahead failure by returning
> > minimum of (requested pages, 512). Users running application on a memory-less cpu
> > which needs readahead such as streaming application see considerable boost in the
> > performance.
> > 
> > Result:
> > fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
> > with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
> > 
> > fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> > 32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
> > NUMA cases w/ patch.
> > 
> > Kernel     Avg  Stddev
> > base	7.4975	3.92%
> > patched	7.4174  3.26%
> > 
> > Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> > [Andrew: making return value PAGE_SIZE independent]
> > Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> 
> So this replaces 
> mm-readaheadc-fix-readahead-fail-for-no-local-memory-and-limit-readahead-pages.patch 
> in -mm correct?

yup.

> >  Changes in V6:
> >   - Just limit the readahead to 2MB on 4k pages system as suggested by Linus.
> >  and make it independent of PAGE_SIZE. 
> > 
> 
> I'm not sure I understand why we want to be independent of PAGE_SIZE since 
> we're still relying on PAGE_CACHE_SIZE.  Don't you mean to do
> 
> #define MAX_READAHEAD	((512*PAGE_SIZE)/PAGE_CACHE_SIZE)

MAX_READAHEAD is in units of "pages".

This:

+#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)

means "two megabytes", and is implemented in a way to ensure that
MAX_READAHEAD=2mb on 4k pagesize as well as on 64k pagesize.  Because
we don't want variations in PAGE_SIZE to cause alterations in readahead
behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
