Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B26F6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:16:16 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id n21so270248752yba.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:16:16 -0800 (PST)
Received: from elasmtp-banded.atl.sa.earthlink.net (elasmtp-banded.atl.sa.earthlink.net. [209.86.89.70])
        by mx.google.com with ESMTPS id n128si1134078ybn.105.2017.01.25.15.16.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 15:16:15 -0800 (PST)
From: "Frank Filz" <ffilzlnx@mindspring.com>
References: <cover.1485377903.git.luto@kernel.org> <9318903980969a0e378dab2de4d803397adcd3cc.1485377903.git.luto@kernel.org> <1485380634.2998.161.camel@decadent.org.uk> <CALCETrUyWGF7WWVxv5e1tznkdV07YCrOcUeoJE8wUn-qCZMAKw@mail.gmail.com>
In-Reply-To: <CALCETrUyWGF7WWVxv5e1tznkdV07YCrOcUeoJE8wUn-qCZMAKw@mail.gmail.com>
Subject: RE: [PATCH 1/2] fs: Check f_cred instead of current's creds in should_remove_suid()
Date: Wed, 25 Jan 2017 15:15:16 -0800
Message-ID: <014301d27760$e4d8b9a0$ae8a2ce0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andy Lutomirski' <luto@amacapital.net>, 'Ben Hutchings' <ben@decadent.org.uk>
Cc: 'Andy Lutomirski' <luto@kernel.org>, security@kernel.org, 'Konstantin Khlebnikov' <koct9i@gmail.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, 'Kees Cook' <keescook@chromium.org>, 'Willy Tarreau' <w@1wt.eu>, linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'yalin wang' <yalin.wang2010@gmail.com>, 'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>, 'Jan Kara' <jack@suse.cz>, 'Linux FS Devel' <linux-fsdevel@vger.kernel.org>, 'stable' <stable@vger.kernel.org>

> On Wed, Jan 25, 2017 at 1:43 PM, Ben Hutchings <ben@decadent.org.uk>
> wrote:
> > On Wed, 2017-01-25 at 13:06 -0800, Andy Lutomirski wrote:
> >> If an unprivileged program opens a setgid file for write and passes
> >> the fd to a privileged program and the privileged program writes to
> >> it, we currently fail to clear the setgid bit.  Fix it by checking
> >> f_cred instead of current's creds whenever a struct file is involved.
> > [...]
> >
> > What if, instead, a privileged program passes the fd to an un
> > unprivileged program?  It sounds like a bad idea to start with, but at
> > least currently the unprivileged program is going to clear the setgid
> > bit when it writes.  This change would make that behaviour more
> > dangerous.
> 
> Hmm.  Although, if a privileged program does something like:
> 
> (sudo -u nobody echo blah) >setuid_program
> 
> presumably it wanted to make the change.

I'm not following all the intricacies here, though I need to...

What about a privileged program that drops privilege for certain operations=
?

Specifically the Ganesha user space NFS server runs as root, but sets fsuid=
/fsgid for specific threads performing I/O operations on behalf of NFS clie=
nts.

I want to make sure setgid bit handling is proper for these cases.

Ganesha does some permission checking, but this is one area I want to defer=
 to the underlying  filesystem because it's not easy for Ganesha to get it =
right.

> > Perhaps there should be a capability check on both the current
> > credentials and file credentials?  (I realise that we've considered
> > file credential checks to be sufficient elsewhere, but those cases
> > involved virtual files with special semantics, where it's clearer that
> > a privileged process should not pass them to an unprivileged process.)
> >
> 
> I could go either way.
> 
> What I really want to do is to write a third patch that isn't for -stable=
 that just
> removes the capable() check entirely.  I'm reasonably confident it won't
> break things for a silly reason: because it's capable() and not ns_capabl=
e(),
> anything it would break would also be broken in an unprivileged container=
,
> and I haven't seen any reports of package managers or similar breaking fo=
r
> this reason.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
