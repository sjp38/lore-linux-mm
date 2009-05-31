Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EBEA66B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 02:24:01 -0400 (EDT)
Received: by bwz21 with SMTP id 21so9275735bwz.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 23:24:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
References: <20090531015537.GA8941@oblivion.subreption.com>
	 <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
Date: Sun, 31 May 2009 09:24:22 +0300
Message-ID: <84144f020905302324r5e342f2dlfd711241ecfc8374@mail.gmail.com>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
	sanitization
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi Linus,

On Sat, 30 May 2009, Larry H. wrote:
>>
>> This patch doesn't affect fastpaths.

On Sun, May 31, 2009 at 5:04 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> This patch is ugly as hell.
>
> You already know the size of the data to clear.
>
> If we actually wanted this (and I am in _no_way_ saying we do), the only
> sane thing to do is to just do
>
> =A0 =A0 =A0 =A0memset(buf->data, 0, N_TTY_BUF_SIZE);
> =A0 =A0 =A0 =A0if (PAGE_SIZE !=3D N_TTY_BUF_SIZE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(...)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_page(...)
>
>
> but quite frankly, I'm not convinced about these patches at all.

I wonder why the tty code has that N_TTY_BUF_SIZE special casing in
the first place? I think we can probably just get rid of it and thus
we can use kzfree() here if we want to.

                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
