Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E17426B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 06:05:37 -0500 (EST)
Received: by wmeg8 with SMTP id g8so57230715wme.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 03:05:37 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id v125si21128230wme.91.2015.11.02.03.05.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 03:05:36 -0800 (PST)
Received: by wmeg8 with SMTP id g8so55793779wme.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 03:05:35 -0800 (PST)
Message-ID: <5637437C.4070306@electrozaur.com>
Date: Mon, 02 Nov 2015 13:05:32 +0200
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for uptodate
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1511011513240.11427@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

On 11/02/2015 01:39 AM, Hugh Dickins wrote:
<>
>> This patch is not correct!
> 
> I think you have actually confirmed that the patch is correct:
> why bother to test PageDirty or PageWriteback when PageUptodate
> already tells you what you need?
> 
> Or do these filesystems do something unusual with PageUptodate
> when PageDirty is set?  I didn't find it.
> 

This is kind of delicate stuff. It took me a while to get it right
when I did it. I don't remember all the details.

But consider this option:

exofs_write_begin on a full PAGE_CACHE_SIZE, the page is instantiated
new in page-cache is that PageUptodate(page) then? I thought not.
(exofs does not set that)

Now that page I do not want to read in. The latest data is in memory.
(Same when this page is in writeback, dirty-bit is cleared)

So for sure if page is dirty or writeback then we surly do not need a read.
only if not then we need to consider the  PageUptodate(page) state.

Do you think the code is actually wrong as is?

BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page

> Thanks,
> Hugh
> 
<>

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
