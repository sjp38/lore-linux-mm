Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id DF7136B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 23:40:09 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so564285qeb.31
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:40:09 -0800 (PST)
Received: from mail-vb0-x22f.google.com (mail-vb0-x22f.google.com [2607:f8b0:400c:c02::22f])
        by mx.google.com with ESMTPS id q6si1829674qag.120.2013.12.18.20.40.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 20:40:08 -0800 (PST)
Received: by mail-vb0-f47.google.com with SMTP id q12so340666vbe.20
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:40:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131219040738.GA10316@redhat.com>
References: <20131219040738.GA10316@redhat.com>
Date: Wed, 18 Dec 2013 20:40:07 -0800
Message-ID: <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
Subject: Re: bad page state in 3.13-rc4
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>

On Wed, Dec 18, 2013 at 8:07 PM, Dave Jones <davej@redhat.com> wrote:
> Just hit this while fuzzing with lots of child processes.
> (trinity -C128)

Ok, there's a BUG_ON() in the middle, the "bad page" part is just this:

> BUG: Bad page state in process trinity-c93  pfn:100499
> page:ffffea0004012640 count:0 mapcount:0 mapping:          (null) index:0x389
> page flags: 0x2000000000000c(referenced|uptodate)
> Call Trace:
>  [<ffffffff816db2f5>] dump_stack+0x4e/0x7a
>  [<ffffffff816d8b05>] bad_page.part.71+0xcf/0xe8
>  [<ffffffff8113a645>] free_pages_prepare+0x185/0x190
>  [<ffffffff8113b085>] free_hot_cold_page+0x35/0x180
>  [<ffffffff811403f3>] __put_single_page+0x23/0x30
>  [<ffffffff81140665>] put_page+0x35/0x50
>  [<ffffffff811e8705>] aio_free_ring+0x55/0xf0
>  [<ffffffff811e9c5a>] SyS_io_setup+0x59a/0xbe0
>  [<ffffffff816edb24>] tracesys+0xdd/0xe2

at free_pages() time, and I don't see anything bad in the printout wrt
the page counts of flags.

Which makes me wonder if this is mem_cgroup_bad_page_check()
triggering. Of course, if it's a race, it may be that by the time we
print out the counts they all look good, even if they weren't good at
the time we did that bad_page() *check*.

And the fact that we do have a concurrent BUG_ON() triggering with a
zero page count obviously does look suspicious. Looks like a possible
race with memory compaction happening at the same time aio_free_ring()
frees the page.

Somebody who knows the migration code needs to look at this. ChristophL?

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
