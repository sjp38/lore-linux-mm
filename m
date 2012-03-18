Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 58ACC6B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 18:01:30 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so522091wgb.26
        for <linux-mm@kvack.org>; Sun, 18 Mar 2012 15:01:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120318190744.GA6589@ZenIV.linux.org.uk>
References: <20120318190744.GA6589@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 18 Mar 2012 15:01:08 -0700
Message-ID: <CA+55aFwBEoD167oD=X9d6jR+wn6Tb-QFgZR+wGwdej4qakCMgg@mail.gmail.com>
Subject: Re: [rfc][patches] fix for munmap/truncate races
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 18, 2012 at 12:07 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> - =A0 =A0 =A0 tlb_finish_mmu(&tlb, 0, end);
> + =A0 =A0 =A0 tlb_finish_mmu(&tlb, 0, -1);

Hmm. The fact that you drop the end pointer means that some
architectures that optimize the TLB flushing for ranges now
effectively can't do it any more.

Now, I think it's only ia64 that really is affected, but it *might* matter.

In particular, ia64 has some logic for "if you only flush one single
region, you can optimize it", and the region sizes are in the
terabytes. And I'm pretty sure you broke that - I'm just not entirely
sure how much we care.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
