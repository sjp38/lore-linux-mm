Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id BD6276B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 01:51:05 -0400 (EDT)
Received: by iajr24 with SMTP id r24so7466161iaj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 22:51:05 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1335778207-6511-1-git-send-email-jack@suse.cz>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 1 May 2012 17:50:44 +1200
Message-ID: <CAKgNAkixtqfppFdJAC9mnD5xCEFK1JZEHno1GhwmMHfoz6mGOQ@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>

Jan,

On Mon, Apr 30, 2012 at 9:30 PM, Jan Kara <jack@suse.cz> wrote:
> This is a long standing problem (or a surprising feature) in our implemen=
tation
> of get_user_pages() (used by direct IO). Since several attempts to fix it
> failed (e.g.
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg06542.html, or
> http://lkml.indiana.edu/hypermail/linux/kernel/0903.1/01498.html refused =
in
> http://comments.gmane.org/gmane.linux.kernel.mm/31569) and it's not compl=
etely
> clear whether we really want to fix it given the costs, let's at least do=
cument
> it.
>
> CC: mgorman@suse.de
> CC: Jeff Moyer <jmoyer@redhat.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>
> --- a/man2/open.2 =A0 =A0 =A0 2012-04-27 00:07:51.736883092 +0200
> +++ b/man2/open.2 =A0 =A0 =A0 2012-04-27 00:29:59.489892980 +0200
> @@ -769,7 +769,12 @@
> =A0and the file offset must all be multiples of the logical block size
> =A0of the file system.
> =A0Under Linux 2.6, alignment to 512-byte boundaries
> -suffices.
> +suffices. However, if the user buffer is not page aligned and direct rea=
d
> +runs in parallel with a
> +.BR fork (2)
> +of the reader process, it may happen that the read data is split between
> +pages owned by the original process and its child. Thus effectively read
> +data is corrupted.
> =A0.LP
> =A0The
> =A0.B O_DIRECT

Thanks. I tweaked the patch slightly, and applied as below.

Cheers,

Michael

--- a/man2/open.2
+++ b/man2/open.2
@@ -49,7 +49,7 @@
 .\" FIXME Linux 2.6.33 has O_DSYNC, and a hidden __O_SYNC.
 .\" FIXME: Linux 2.6.39 added O_PATH
 .\"
-.TH OPEN 2 2012-02-27 "Linux" "Linux Programmer's Manual"
+.TH OPEN 2 2012-05-01 "Linux" "Linux Programmer's Manual"
 .SH NAME
 open, creat \- open and possibly create a file or device
 .SH SYNOPSIS
@@ -768,8 +768,13 @@ operation in
 Under Linux 2.4, transfer sizes, and the alignment of the user buffer
 and the file offset must all be multiples of the logical block size
 of the file system.
-Under Linux 2.6, alignment to 512-byte boundaries
-suffices.
+Under Linux 2.6, alignment to 512-byte boundaries suffices.
+However, if the user buffer is not page-aligned and the direct read
+runs in parallel with a
+.BR fork (2)
+of the reader process, it may happen that the read data is split between
+pages owned by the original process and its child.
+Thus the read data is effectively corrupted.
 .LP
 The
 .B O_DIRECT


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
