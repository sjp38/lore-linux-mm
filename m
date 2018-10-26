Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C13686B026E
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 06:57:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b95-v6so388172plb.10
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 03:57:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6-v6si10380180pls.174.2018.10.26.03.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 03:57:00 -0700 (PDT)
Date: Fri, 26 Oct 2018 12:56:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_owner: use vmalloc instead of kmalloc
Message-ID: <20181026085410.GA8277@dhcp22.suse.cz>
References: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
 <20181025192701.GK25444@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025192701.GK25444@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: miles.chen@mediatek.com, Matthias Brugger <matthias.bgg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Thu 25-10-18 12:27:01, Matthew Wilcox wrote:
> On Fri, Oct 26, 2018 at 02:34:41AM +0800, miles.chen@mediatek.com wrote:
> > The kbuf used by page owner is allocated by kmalloc(),
> > which means it can use only normal memory and there might
> > be a "out of memory" issue when we're out of normal memory.
> > 
> > Use vmalloc() so we can also allocate kbuf from highmem
> > on 32bit kernel.
> 
> ... hang on, there's a bigger problem here.
> 
> static const struct file_operations proc_page_owner_operations = {
>         .read           = read_page_owner,
> };
> 
> read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
> {
> ...
>                 return print_page_owner(buf, count, pfn, page,
>                                 page_owner, handle);
> }
> 
> static ssize_t
> print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>                 struct page *page, struct page_owner *page_owner,
>                 depot_stack_handle_t handle)
> {
> ...
>       kbuf = kmalloc(count, GFP_KERNEL);
> 
> So I can force the kernel to make an arbitrary size allocation, triggering
> OOMs and forcing swapping if I can get a file handle to this file.
> The only saving grace is that (a) this is a debugfs file and (b) it's
> root-only (mode 0400).  Nevertheless, I feel some clamping is called
> for here.  Do we really need to output more than 4kB worth of text here?

Completely agreed. Let's just clamp it to a single page. Userspace can
easily loop around the syscall.

-- 
Michal Hocko
SUSE Labs
