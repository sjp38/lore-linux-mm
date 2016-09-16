Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56B8F6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 13:47:01 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 20so80777886itx.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:47:01 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id r5si5249535oig.238.2016.09.16.10.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 10:47:00 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id r126so120462511oib.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 10:47:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Sep 2016 10:46:59 -0700
Message-ID: <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Sam Varshavchik <mrsam@courier-mta.com>, Brent <fix@bitrealm.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 16, 2016 at 8:16 AM, Laura Abbott <labbott@redhat.com> wrote:
>
> Fedora received a bug report[1] after pushing 4.7.2 that named
> was segfaulting with named-chroot. With some help (thank you
> tibbs!), it was noted that on older kernels named was spitting
> out
>
> mmap: named (671): VmData 27566080 exceed data ulimit 23068672.
> Will be forbidden soon.
>
> and with f4fcd55841fc ("mm: enable RLIMIT_DATA by default with
> workaround for valgrind") it now spits out
>
> mmap: named (593): VmData 27566080 exceed data ulimit 20971520.
> Update limits or use boot option ignore_rlimit_data.

Ok, we can certainly revert, but before we do that I'd like to
understand a few more things.

For example, where the data limit came from, and how likely this is to
hit others that have a much harder time fixing it. Adding Sam
Varshavchik and Brent to the participants list...

In particular, this is clearly trivially fixable as noted by Brent in
that bugzilla entry:

  'remove the "datasize 20M;" directive in named.conf'

along with the (much worse) option of "use boot option
ignore_rlimit_data" that the kernel dmesg itself suggests as an
option.

So for example, if that "datasize 20M;" is coming from just the Fedora
named package, it would be much nicer to just get that fixed instead.
Because RLIMIT_DATA the old way was just meaningless noise.

We definitely don't want to break peoples existing setups, but as this
is *so* easy to fix in other ways (even at runtime without even
updating a kernel), and since this commit is already four months old
by now with this single bugzilla being the only report since then that
I'm aware of, my reaction is just that there are better ways to fix it
than reverting a commit that can be worked around trivially.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
