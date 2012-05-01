Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5796E6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 10:32:05 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2637084ghr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 07:32:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335778207-6511-1-git-send-email-jack@suse.cz>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 May 2012 10:31:44 -0400
Message-ID: <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>, npiggin@gmail.com

On Mon, Apr 30, 2012 at 5:30 AM, Jan Kara <jack@suse.cz> wrote:
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

Hello,

Thank you revisit this. But as far as my remember is correct, this issue is=
 NOT
unaligned access issue. It's just get_user_pages(_fast) vs fork race issue.=
 i.e.
DIRECT_IO w/ multi thread process should not use fork().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
