Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85D658E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:56:09 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id o132so1119522vsd.11
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:56:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z17sor10222570uao.49.2019.01.23.10.56.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 10:56:08 -0800 (PST)
Received: from mail-ua1-f41.google.com (mail-ua1-f41.google.com. [209.85.222.41])
        by smtp.gmail.com with ESMTPSA id l13sm98292054vka.16.2019.01.23.10.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 10:56:05 -0800 (PST)
Received: by mail-ua1-f41.google.com with SMTP id v24so1072089uap.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:56:05 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com>
 <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net> <87va2f1int.fsf@intel.com>
In-Reply-To: <87va2f1int.fsf@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 24 Jan 2019 07:55:51 +1300
Message-ID: <CAGXu5jJUxHtFq0rBJ9FwzMcZDWnusPUauC_=MaOz7H0_PF25jQ@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Edwin Zimmerman <edwin@211mainstreet.net>, Greg KH <gregkh@linuxfoundation.org>, dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Network Development <netdev@vger.kernel.org>, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux-MM <linux-mm@kvack.org>, linux-security-module <linux-security-module@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, intel-wired-lan@lists.osuosl.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Laura Abbott <labbott@redhat.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Alexander Popov <alex.popov@linux.com>

On Thu, Jan 24, 2019 at 4:44 AM Jani Nikula <jani.nikula@linux.intel.com> w=
rote:
>
> On Wed, 23 Jan 2019, Edwin Zimmerman <edwin@211mainstreet.net> wrote:
> > On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> >> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
> >> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> >> >> Variables declared in a switch statement before any case statements
> >> >> cannot be initialized, so move all instances out of the switches.
> >> >> After this, future always-initialized stack variables will work
> >> >> and not throw warnings like this:
> >> >>
> >> >> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> >> >> fs/fcntl.c:738:13: warning: statement will never be executed [-Wswi=
tch-unreachable]
> >> >>    siginfo_t si;
> >> >>              ^~
> >> >
> >> > That's a pain, so this means we can't have any new variables in { }
> >> > scope except for at the top of a function?

Just in case this wasn't clear: no, it's just the switch statement
before the first "case". I cannot imagine how bad it would be if we
couldn't have block-scoped variables! Heh. :)

> >> >
> >> > That's going to be a hard thing to keep from happening over time, as
> >> > this is valid C :(
> >>
> >> Not all valid C is meant to be used! ;)
> >
> > Very true.  The other thing to keep in mind is the burden of enforcing
> > a prohibition on a valid C construct like this.  It seems to me that
> > patch reviewers and maintainers have enough to do without forcing them
> > to watch for variable declarations in switch statements.  Automating
> > this prohibition, should it be accepted, seems like a good idea to me.
>
> Considering that the treewide diffstat to fix this is:
>
>  18 files changed, 45 insertions(+), 46 deletions(-)
>
> and using the gcc plugin in question will trigger the switch-unreachable
> warning, I think we're good. There'll probably be the occasional
> declarations that pass through, and will get fixed afterwards.

Yeah, that was my thinking as well: it's a rare use, and we get a
warning when it comes up.

Thanks!

--=20
Kees Cook
