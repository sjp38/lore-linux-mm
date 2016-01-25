Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 60F756B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:38:39 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id zv1so20686270obb.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:38:39 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id z186si18408008oig.87.2016.01.25.09.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 09:38:38 -0800 (PST)
Received: by mail-oi0-x230.google.com with SMTP id w75so91795484oie.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:38:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com> <1453742717-10326-4-git-send-email-matthew.r.wilcox@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Jan 2016 09:38:19 -0800
Message-ID: <CALCETrWuPa2SoUcMCtDiv1UDodNqKcQzsZV5PxQx5Xhb524f7w@mail.gmail.com>
Subject: Re: [PATCH 3/3] dax: Handle write faults more efficiently
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> When we handle a write-fault on a DAX mapping, we currently insert a
> read-only mapping and then take the page fault again to convert it to
> a writable mapping.  This is necessary for the case where we cover a
> hole with a read-only zero page, but when we have a data block already
> allocated, it is inefficient.
>
> Use the recently added vmf_insert_pfn_prot() to insert a writable mapping,
> even though the default VM flags say to use a read-only mapping.

Conceptually, I like this.  Do you need to make sure to do all the
do_wp_page work, though?  (E.g. we currently update mtime in there.
Some day I'll fix that, but it'll be replaced with a set_bit to force
a deferred mtime update.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
