Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62AA26B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 07:15:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s25-v6so2028815wmh.1
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 04:15:14 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id b129-v6si1050975wmg.216.2018.07.20.04.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 04:15:12 -0700 (PDT)
Date: Fri, 20 Jul 2018 12:15:09 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs/seq_file: remove kmalloc(ops) for single_open seqfiles
Message-ID: <20180720111509.GB30522@ZenIV.linux.org.uk>
References: <20180720102952.30935-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720102952.30935-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>

On Fri, Jul 20, 2018 at 12:29:52PM +0200, Vlastimil Babka wrote:
> single_open() currently allocates seq_operations with kmalloc(). This is
> suboptimal, because that's four pointers, of which three are constant, and
> only the 'show' op differs. We also have to be careful to use single_release()
> to avoid leaking the ops structure.
> 
> Instead of this we can have a fixed single_show() function and constant ops
> structure for these seq_files. We can store the pointer to the 'show' op as
> a new field of struct seq_file. That's also not terribly elegant, because the
> field is there also for non-single_open() seq files, but it's a single pointer
> in an already existing (and already relatively large) structure instead of
> an extra kmalloc of four pointers, so the tradeoff is OK.

... except that piling indirect calls is costly and ->show() is called a lot more
than open() is.
