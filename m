Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E31D26B02B9
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 15:27:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 90-v6so6082951pla.18
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:27:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h12-v6si8299975plt.240.2018.10.25.12.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Oct 2018 12:27:04 -0700 (PDT)
Date: Thu, 25 Oct 2018 12:27:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/page_owner: use vmalloc instead of kmalloc
Message-ID: <20181025192701.GK25444@bombadil.infradead.org>
References: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Matthias Brugger <matthias.bgg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Fri, Oct 26, 2018 at 02:34:41AM +0800, miles.chen@mediatek.com wrote:
> The kbuf used by page owner is allocated by kmalloc(),
> which means it can use only normal memory and there might
> be a "out of memory" issue when we're out of normal memory.
> 
> Use vmalloc() so we can also allocate kbuf from highmem
> on 32bit kernel.

... hang on, there's a bigger problem here.

static const struct file_operations proc_page_owner_operations = {
        .read           = read_page_owner,
};

read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
...
                return print_page_owner(buf, count, pfn, page,
                                page_owner, handle);
}

static ssize_t
print_page_owner(char __user *buf, size_t count, unsigned long pfn,
                struct page *page, struct page_owner *page_owner,
                depot_stack_handle_t handle)
{
...
      kbuf = kmalloc(count, GFP_KERNEL);

So I can force the kernel to make an arbitrary size allocation, triggering
OOMs and forcing swapping if I can get a file handle to this file.
The only saving grace is that (a) this is a debugfs file and (b) it's
root-only (mode 0400).  Nevertheless, I feel some clamping is called
for here.  Do we really need to output more than 4kB worth of text here?
