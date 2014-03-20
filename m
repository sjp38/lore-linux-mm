Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8254F6B018C
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 23:49:29 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id la4so298240vcb.3
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 20:49:29 -0700 (PDT)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id tz5si151922vdc.151.2014.03.19.20.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 20:49:28 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id im17so290660vcb.23
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 20:49:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Date: Wed, 19 Mar 2014 20:49:28 -0700
Message-ID: <CA+55aFyNORiS2XidhWoDBVyO6foZuPJTg_BOP3aLtvVhY1R6mw@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?Q?Kristian_H=C3=B8gsberg?= <krh@bitplanet.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Wed, Mar 19, 2014 at 12:06 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>
> Unlike existing techniques that provide similar protection, sealing allows
> file-sharing without any trust-relationship. This is enforced by rejecting seal
> modifications if you don't own an exclusive reference to the given file.

I like the concept, but I really hate that "exclusive reference"
approach. I see why you did it, but I also worry that it means that
people can open random shm files that are *not* expected to be sealed,
and screw up applications that don't expect it.

Is there really any use-case where the sealer isn't also the same
thing that *created* the file in the first place? Because I would be a
ton happier with the notion that you can only seal things that you
yourself created. At that point, the exclusive reference isn't such a
big deal any more, but more importantly, you can't play random
denial-of-service games on files that aren't really yours.

The fact that you bring up the races involved with the exclusive
reference approach also just makes me go "Is that really the correct
security model"?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
