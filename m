Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16D0A6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 17:27:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so107513600pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 14:27:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dt12si11673778pac.0.2016.04.27.14.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 14:27:50 -0700 (PDT)
Date: Wed, 27 Apr 2016 14:27:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: Real pagecache iterators
Message-Id: <20160427142749.5b77d723a0b97164f04a91f3@linux-foundation.org>
In-Reply-To: <1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
References: <20160401023510.GA28762@kmo-pixel>
	<1459478291-29982-1-git-send-email-kent.overstreet@gmail.com>
	<1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Mar 2016 18:38:11 -0800 Kent Overstreet <kent.overstreet@gmail.com> wrote:

> Introduce for_each_pagecache_page() and related macros, with the goal of
> replacing most/all uses of pagevec_lookup().
> 
> For the most part this shouldn't be a functional change. The one functional
> difference with the new macros is that they now take an @end parameter, so we're
> able to avoid grabbing pages in __find_get_pages() that we'll never use.
> 
> This patch only does some of the conversions, the ones I was able to easily test
> myself - the conversions are mechanical but tricky enough they generally warrent
> testing.
> 
> Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/ext4/inode.c         | 261 ++++++++++++++++++++----------------------------
>  include/linux/pagevec.h |  67 ++++++++++++-
>  mm/filemap.c            |  76 +++++++++-----
>  mm/page-writeback.c     | 148 +++++++++++----------------
>  mm/swap.c               |  33 +-----
>  mm/truncate.c           | 259 +++++++++++++++++------------------------------
>  6 files changed, 380 insertions(+), 464 deletions(-)

hm, it's a lot of churn in sensitive areas for an 80 line saving.  What
do others think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
