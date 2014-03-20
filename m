Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 144646B019A
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 04:07:27 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id hl1so1368600igb.1
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 01:07:26 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id ub6si33005350igb.52.2014.03.20.01.07.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 01:07:25 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so487746ier.13
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 01:07:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyNORiS2XidhWoDBVyO6foZuPJTg_BOP3aLtvVhY1R6mw@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<CA+55aFyNORiS2XidhWoDBVyO6foZuPJTg_BOP3aLtvVhY1R6mw@mail.gmail.com>
Date: Thu, 20 Mar 2014 09:07:06 +0100
Message-ID: <CANq1E4TuiU6_J=N0WoPav=0AxOJ9G1w+FGvO15kmGP76i+-caw@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?ISO-8859-1?Q?Kristian_H=F8gsberg?= <krh@bitplanet.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

Hi

On Thu, Mar 20, 2014 at 4:49 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Is there really any use-case where the sealer isn't also the same
> thing that *created* the file in the first place? Because I would be a
> ton happier with the notion that you can only seal things that you
> yourself created. At that point, the exclusive reference isn't such a
> big deal any more, but more importantly, you can't play random
> denial-of-service games on files that aren't really yours.

My first idea was to add MFD_ALLOW_SEALING as memfd_create() flag,
which enables the sealing-API for that file. Then I looked at POSIX
mandatory locking and noticed that it provides similar restrictions on
_all_ files. Mandatory locks can be more easily removed, but an
attacker could just re-apply them in a loop, so that's not really an
argument. Furthermore, sealing requires _write_ access so I wonder
what kind of DoS attacks are possible with sealing that are not
already possible with write access? And sealing is only possible if no
writable, shared mapping exists. So even if an attacker seals a file,
all that happens is EPERM, not SIGBUS (still a possible
denial-of-service scenario).

But I understand that it is quite hard to review all the possible
scenarios. So I'm fine with checking inode-ownership permissions for
SET_SEALS. We could also make sealing a one-shot operation. Given that
in a no-trust situation there is never a guarantee that the other side
drops its references, re-using a sealed file is usually not possible.
However, in sane environments, this could be a nice optimization in
case the other side plays along. The one-shot semantics would allow
dropping reference-checks entirely. The inode-ownership semantics
would still require it.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
