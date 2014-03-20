Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 17EBE6B0209
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 10:42:02 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id mx12so79917bkb.29
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 07:42:02 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id nr7si1023299bkb.159.2014.03.20.07.42.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Mar 2014 07:42:01 -0700 (PDT)
Date: Thu, 20 Mar 2014 14:41:27 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140320144127.1d411f26@alan.etchedpixels.co.uk>
In-Reply-To: <CANq1E4TuiU6_J=N0WoPav=0AxOJ9G1w+FGvO15kmGP76i+-caw@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<CA+55aFyNORiS2XidhWoDBVyO6foZuPJTg_BOP3aLtvVhY1R6mw@mail.gmail.com>
	<CANq1E4TuiU6_J=N0WoPav=0AxOJ9G1w+FGvO15kmGP76i+-caw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian =?UTF-8?B?SMO4Z3NiZXJn?= <krh@bitplanet.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael
 Kerrisk (man-pages)" <mtk.manpages@gmail.com>

> My first idea was to add MFD_ALLOW_SEALING as memfd_create() flag,
> which enables the sealing-API for that file. Then I looked at POSIX

This actually seems the most sensible to me. The reason being that if I
have some existing used object there is no way on earth I can be sure who
has existing references to it, and we don't have revoke() to fix that.

So it pretty much has to be a new object in a sane programming model.

> mandatory locking and noticed that it provides similar restrictions on
> _all_ files. Mandatory locks can be more easily removed, but an

The fact someone got it past a standards body doesn't make it a good idea.

> attacker could just re-apply them in a loop, so that's not really an
> argument. Furthermore, sealing requires _write_ access so I wonder
> what kind of DoS attacks are possible with sealing that are not
> already possible with write access? And sealing is only possible if no
> writable, shared mapping exists. So even if an attacker seals a file,
> all that happens is EPERM, not SIGBUS (still a possible
> denial-of-service scenario).

I think you want two things at minimum

owner to seal
root can always override

I would query the name too. Right now your assumption is 'shmem only' but
that might change with other future use cases or types (eg some driver
file handles) so SHMEM_ in the fcntl might become misleading.

Whether you want some way to undo a seal without an exclusive reference as
the file owner is another question.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
