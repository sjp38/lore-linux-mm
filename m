Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05E696B0010
	for <linux-mm@kvack.org>; Mon, 14 May 2018 20:44:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u10-v6so6911667pgp.8
        for <linux-mm@kvack.org>; Mon, 14 May 2018 17:44:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x11-v6si11260833plo.41.2018.05.14.17.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 May 2018 17:44:09 -0700 (PDT)
Date: Mon, 14 May 2018 17:44:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515004406.GB5168@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514144901.0fe99d240ff8a53047dd512e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180514144901.0fe99d240ff8a53047dd512e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Boaz Harrosh <boazh@netapp.com>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Mon, May 14, 2018 at 02:49:01PM -0700, Andrew Morton wrote:
> On Mon, 14 May 2018 20:28:01 +0300 Boaz Harrosh <boazh@netapp.com> wrote:
> > In this project we utilize a per-core server thread so everything
> > is kept local. If we use the regular zap_ptes() API All CPU's
> > are scheduled for the unmap, though in our case we know that we
> > have only used a single core. The regular zap_ptes adds a very big
> > latency on every operation and mostly kills the concurrency of the
> > over all system. Because it imposes a serialization between all cores
> 
> I'd have thought that in this situation, only the local CPU's bit is
> set in the vma's mm_cpumask() and the remote invalidations are not
> performed.  Is that a misunderstanding, or is all that stuff not working
> correctly?

I think you misunderstand Boaz's architecture.  He has one thread per CPU,
so every bit will be set in the mm's (not vma's) mm_cpumask.
