Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58ECF6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:52:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so13457041plm.12
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:52:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i75si5360791pgd.399.2018.04.05.09.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 09:52:50 -0700 (PDT)
Date: Thu, 5 Apr 2018 09:52:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] include: mm: Adding new inline function vmf_error
Message-ID: <20180405165248.GG28128@bombadil.infradead.org>
References: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Apr 05, 2018 at 09:52:25PM +0530, Souptick Joarder wrote:
> Many places in drivers/ file systems error was handled
> like below -
> ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
> 
> This new inline function vmf_error() will replace this
> and return vm_fault_t type err.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

To elaborate a little more on the changelog above, a lot of drivers and
filesystems currently have a rather complex mapping of errno-to-VM_FAULT
code.  We've been able to eliminate a lot of it by just returning VM_FAULT
codes directly from functions which are called exclusively from the
fault handling path.

Some functions can be called both from the fault handler and other context
which are expecting an errno, so they have to continue to return an errno.
Some users still need to choose different behaviour for different errnos,
but vmf_error() captures the essential error translation that's common
to all users, and those that need to handle additional errors can handle
them first.

We'd like to get this into -rc1 so we can start trickling driver chanages
that depend on it into the maintainer trees.
