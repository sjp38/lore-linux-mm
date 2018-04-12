Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB68E6B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:01:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18so2995310wri.9
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 06:01:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i58sor2954778ede.52.2018.04.12.06.01.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 06:01:09 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20171101153648.30166-20-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz> <20171101153648.30166-20-jack@suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 12 Apr 2018 15:00:49 +0200
Message-ID: <CAKgNAkhsFrcdkXNA2cw3o0gJV0uLRtBg9ybaCe5xy1QBC2PgqA@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and MAP_SYNC
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Ext4 Developers List <linux-ext4@vger.kernel.org>, xfs <linux-xfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>

Hello Jan,

I have applied your patch, and tweaked the text a little, and pushed
the result to the git repo.

On 1 November 2017 at 16:36, Jan Kara <jack@suse.cz> wrote:
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

I have a question below.

> ---
>  man2/mmap.2 | 35 ++++++++++++++++++++++++++++++++++-
>  1 file changed, 34 insertions(+), 1 deletion(-)
>
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 47c3148653be..b38ee6809327 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -125,6 +125,21 @@ are carried through to the underlying file.
>  to the underlying file requires the use of
>  .BR msync (2).)
>  .TP
> +.BR MAP_SHARED_VALIDATE " (since Linux 4.15)"
> +The same as
> +.B MAP_SHARED
> +except that
> +.B MAP_SHARED
> +mappings ignore unknown flags in
> +.IR flags .
> +In contrast when creating mapping of
> +.B MAP_SHARED_VALIDATE
> +mapping type, the kernel verifies all passed flags are known and fails the
> +mapping with
> +.BR EOPNOTSUPP
> +otherwise. This mapping type is also required to be able to use some mapping
> +flags.
> +.TP
>  .B MAP_PRIVATE
>  Create a private copy-on-write mapping.
>  Updates to the mapping are not visible to other processes
> @@ -134,7 +149,10 @@ It is unspecified whether changes made to the file after the
>  .BR mmap ()
>  call are visible in the mapped region.
>  .PP
> -Both of these flags are described in POSIX.1-2001 and POSIX.1-2008.
> +.B MAP_SHARED
> +and
> +.B MAP_PRIVATE
> +are described in POSIX.1-2001 and POSIX.1-2008.
>  .PP
>  In addition, zero or more of the following values can be ORed in
>  .IR flags :
> @@ -352,6 +370,21 @@ option.
>  Because of the security implications,
>  that option is normally enabled only on embedded devices
>  (i.e., devices where one has complete control of the contents of user memory).
> +.TP
> +.BR MAP_SYNC " (since Linux 4.15)"
> +This flags is available only with
> +.B MAP_SHARED_VALIDATE
> +mapping type. Mappings of
> +.B MAP_SHARED
> +type will silently ignore this flag.
> +This flag is supported only for files supporting DAX (direct mapping of persistent
> +memory). For other files, creating mapping with this flag results in
> +.B EOPNOTSUPP
> +error. Shared file mappings with this flag provide the guarantee that while
> +some memory is writeably mapped in the address space of the process, it will
> +be visible in the same file at the same offset even after the system crashes or
> +is rebooted. This allows users of such mappings to make data modifications
> +persistent in a more efficient way using appropriate CPU instructions.

It feels like there's a word missing/unclear wording in the previous
line, before "using". Without that word, the sentence feels a bit
ambiguous.

Should it be:

persistent in a more efficient way *through the use of* appropriate
CPU instructions.

or:

persistent in a more efficient way *than using* appropriate CPU instructions.

?

Is suspect the first is correct, but need to check.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
