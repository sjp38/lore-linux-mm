Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A205C8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:09:40 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w124so951168oif.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:09:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor9518504oia.75.2019.01.23.04.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 04:09:39 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com>
In-Reply-To: <20190123115829.GA31385@kroah.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 23 Jan 2019 13:09:13 +0100
Message-ID: <CAG48ez2vfXkr9dozJiGmze8k49VOXfs=K7M8bv0aQsDDpzrEFQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] treewide: Lift switch variables out of switches
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Kees Cook <keescook@chromium.org>, kernel list <linux-kernel@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Laura Abbott <labbott@redhat.com>, Alexander Popov <alex.popov@linux.com>, xen-devel <xen-devel@lists.xenproject.org>, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org, Network Development <netdev@vger.kernel.org>, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, dev@openvswitch.org, linux-kbuild@vger.kernel.org, linux-security-module <linux-security-module@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Jan 23, 2019 at 1:04 PM Greg KH <gregkh@linuxfoundation.org> wrote:
> On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> > Variables declared in a switch statement before any case statements
> > cannot be initialized, so move all instances out of the switches.
> > After this, future always-initialized stack variables will work
> > and not throw warnings like this:
> >
> > fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> > fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitch-=
unreachable]
> >    siginfo_t si;
> >              ^~
>
> That's a pain, so this means we can't have any new variables in { }
> scope except for at the top of a function?

AFAICS this only applies to switch statements (because they jump to a
case and don't execute stuff at the start of the block), not blocks
after if/while/... .

> That's going to be a hard thing to keep from happening over time, as
> this is valid C :(
