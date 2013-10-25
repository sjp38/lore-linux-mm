Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2D75B6B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 04:18:53 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id q10so3623487pdj.41
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 01:18:52 -0700 (PDT)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id jp3si3369057pbc.276.2013.10.25.01.18.51
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 01:18:52 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id c14so830315vea.28
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 01:18:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
Date: Fri, 25 Oct 2013 09:18:49 +0100
Message-ID: <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>

On Fri, Oct 25, 2013 at 8:25 AM, Artem S. Tashkinov <t.artem@lycos.com> wrote:
>
> On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11 kernel
> built for the i686 (with PAE) and x86-64 architectures. What's really troubling me
> is that the x86-64 kernel has the following problem:
>
> When I copy large files to any storage device, be it my HDD with ext4 partitions
> or flash drive with FAT32 partitions, the kernel first caches them in memory entirely
> then flushes them some time later (quite unpredictably though) or immediately upon
> invoking "sync".

Yeah, I think we default to a 10% "dirty background memory" (and
allows up to 20% dirty), so on your 16GB machine, we allow up to 1.6GB
of dirty memory for writeout before we even start writing, and twice
that before we start *waiting* for it.

On 32-bit x86, we only count the memory in the low 1GB (really
actually up to about 890MB), so "10% dirty" really means just about
90MB of buffering (and a "hard limit" of ~180MB of dirty).

And that "up to 3.2GB of dirty memory" is just crazy. Our defaults
come from the old days of less memory (and perhaps servers that don't
much care), and the fact that x86-32 ends up having much lower limits
even if you end up having more memory.

You can easily tune it:

    echo $((16*1024*1024)) > /proc/sys/vm/dirty_background_bytes
    echo $((48*1024*1024)) > /proc/sys/vm/dirty_bytes

or similar. But you're right, we need to make the defaults much saner.

Wu? Andrew? Comments?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
