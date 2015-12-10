Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id F0FB76B026A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 22:25:27 -0500 (EST)
Received: by ioir85 with SMTP id r85so82056699ioi.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 19:25:27 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id f126si17081611ioe.64.2015.12.09.19.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 19:25:27 -0800 (PST)
Received: by iofh3 with SMTP id h3so82104774iof.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 19:25:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210012130.GA17673@infradead.org>
References: <20151209225148.GA14794@www.outflux.net>
	<20151210012130.GA17673@infradead.org>
Date: Wed, 9 Dec 2015 19:25:26 -0800
Message-ID: <CAGXu5jL0Zv6mCoEw6pyZsgHjo8BdcF0B-xM_EkMtp7TRB94dKQ@mail.gmail.com>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 9, 2015 at 5:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>> during the page fault (due to mmap_sem being held during the fault). We
>> could do this during vm_mmap_pgoff, but that would need coverage in
>> mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
>> again. We could clear at open() time, but it's possible things are
>> accidentally opening with O_RDWR and only reading. Better to clear on
>> close and error failures (i.e. an improvement over now, which is not
>> clearing at all).
>>
>> Instead, detect the need to clear the bits during the page fault, and
>> actually remove the bits during final fput. Since the file was open for
>> writing, it wouldn't have been possible to execute it yet.
>
>
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> I think this is the best we can do; everything else is blocked by mmap_sem.
>
> It should be done at mmap time, before even taking mmap_sem.
>
> Adding a new field for this to strut file isn't really acceptable.

I already covered this: there's no way to handle the mprotect case --
checking for MAP_SHARED is under mmap_sem still.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
