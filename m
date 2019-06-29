Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38D8BC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 07:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD792214AF
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 07:05:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gfu5Pz78"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD792214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C23A6B0003; Sat, 29 Jun 2019 03:05:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34C108E0003; Sat, 29 Jun 2019 03:05:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ED9E8E0002; Sat, 29 Jun 2019 03:05:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f80.google.com (mail-yw1-f80.google.com [209.85.161.80])
	by kanga.kvack.org (Postfix) with ESMTP id EDC0D6B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 03:05:02 -0400 (EDT)
Received: by mail-yw1-f80.google.com with SMTP id p76so11242168ywg.5
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 00:05:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xM/xcvkzohmQdtVDVPIgTFxuHjb4HOBVLFjrfhylohA=;
        b=MdF/NpM+HLMts/MB9HlD6YaW4atkc1dbFp3eHbUV8+VrSFq4JEbX61sgaqf+E4lURw
         UTEM03p34ipDNfKlGJaJHJZPyGaqqjl4eOr5xDkUgDkX+kj7UfPHfjQTdCl0ovBcqrgT
         nEUBjUdUCblbCNQekCJRImPKs1hzuVUHjOZA5314dcXZGiiLFC+U209sES+hSABVHLHc
         tOVTd8wJMiIDzQD6n2Hv+w5z5R3rUA0KySKr4/f9WQM/VODoN4ybzQOSJckwljb5DQ+P
         oX8xqpJ7qJ09oDzq/lymoooom+yzdWQIQ82I3sJ8A6zglUtVtEaid+3BS12h4ANjh3uR
         acnw==
X-Gm-Message-State: APjAAAXmGNorNk2XZ6ig/zX0JmKkXl5GhBjQJl7BqudYr9TtpKSIbZSQ
	jDgNwiMgDmX8NWfmrJEZAN6SrF3YEqIvYX3DWIB8pWHFxaRu/98wG2xIs3hVIFptiwM2iAFx0HT
	Os/HxalQJWISV8zXJDD1+uvH3RGcxxsK8B4eAjsdPlHuMnX/FPwL6J/d8Xqs2xZFBvQ==
X-Received: by 2002:a81:5f82:: with SMTP id t124mr8430036ywb.344.1561791902551;
        Sat, 29 Jun 2019 00:05:02 -0700 (PDT)
X-Received: by 2002:a81:5f82:: with SMTP id t124mr8430000ywb.344.1561791901680;
        Sat, 29 Jun 2019 00:05:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561791901; cv=none;
        d=google.com; s=arc-20160816;
        b=NCjh3kPWQUB/gpnIVFj/k8r4n3GF3v636G6Mr7CnSruWdVVcbmgoxmiz0tafJvxuf5
         rX7QSUtAQb5TN0z2ofixrLuVl69qcyHxQiPLF/0236y4vkjcbqOCd8Ar4JnRH324W6sa
         qGKtFt+9ey30nypW8M8oKCkAgGiRj4AEckL9cbHX1bdXR/iVY8hO87fwz94GjrfkuU3q
         nvDyWn1eXva+wJj9I8RAVobOR4LxIewvwFpU28APgEl7cnYtK26BaXWbEVjjexEaSfvc
         9/by+Kfftrqm7e/Xyr6huXlEa7ahwEsMEI+jbQiDWlKZeEQbkzwAeyaWJ5pLOAyyvluW
         xFig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xM/xcvkzohmQdtVDVPIgTFxuHjb4HOBVLFjrfhylohA=;
        b=OfxfMZJW0LY/7/MgmrnGBtTvNeojMbpILwcpM2yeG8vEquIXshzcScm/rJFPkvHHgX
         AfSfcRYMR9j/oo4Oy1U5VpY81hubk/9bL9h0vD7rjijxMBToD9KtzqMN+UkWs2iST/vd
         w3vdFOC33KPp5O46/sFSTduzs/LwIeJSoyiluc+38mmDvFfeH6VLagtV6senEt3jX9Ul
         ICA8gxzUGqPLV3XdVo+F9gmFvp1iIWfWPpCPvbe0LQL0Km2tZHGIEd3mioQ1gDwSyHZP
         Q3k95X7YZ10rTT1tl5D6zscyYmh8DB+KDXiw29XU4NSUiSmeeTZnvqC7FbWRM7+WH7CO
         C8uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gfu5Pz78;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor2482568ybm.197.2019.06.29.00.05.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Jun 2019 00:05:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gfu5Pz78;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xM/xcvkzohmQdtVDVPIgTFxuHjb4HOBVLFjrfhylohA=;
        b=Gfu5Pz78tLVKvI8Q9WtRwxoZiso9oqghADUZOQqtlF6a4PF4ZC24i4bhdxEFOWT9mb
         ogpxVnV34CUKT9Hp3X/zqMkMMajHb+ZB117iqrYsimXsLjh5l46Ev8rT8yc8cIX3yIvp
         pPvNValE4fvXkmuBjtLVOlUXgnPgouNfZrFrcwZJP2fDEoyBu6UDZfe0+vDH3DvWwhm2
         zDFMbFYJkqZlfRqwPcIjOiXLiRHvuGtOYey5wWMnlJCELzFsocHIwB5e56zebm7P/vZi
         S6f79kvT8PuUPJTo2r7gwPTQl2Z6a4vDBem6y6JYpyyoLzjF+dqkakkpoHJf+XnufEOL
         I8qA==
X-Google-Smtp-Source: APXvYqxU4FPLSq/gM1nVlP+fbK0BmSrMY2hESytnxCDMdjqY3j5BqEk3eirFdcbLmu5rTiIZzzGPOTH2wPbd9PuZuhY=
X-Received: by 2002:a25:8489:: with SMTP id v9mr8918225ybk.144.1561791901221;
 Sat, 29 Jun 2019 00:05:01 -0700 (PDT)
MIME-Version: 1.0
References: <156174687561.1557469.7505651950825460767.stgit@magnolia> <156174690758.1557469.9258105121276292687.stgit@magnolia>
In-Reply-To: <156174690758.1557469.9258105121276292687.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sat, 29 Jun 2019 10:04:50 +0300
Message-ID: <CAOQ4uxgG5Kijx=nzFRB0uFPMghJXDfCqxKEWQoePwKZTGO+NMg@mail.gmail.com>
Subject: Re: [PATCH 4/4] vfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: matthew.garrett@nebula.com, Chao Yu <yuchao0@huawei.com>, 
	Theodore Tso <tytso@mit.edu>, ard.biesheuvel@linaro.org, 
	Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <clm@fb.com>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Al Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.com>, David Sterba <dsterba@suse.com>, Jaegeuk Kim <jaegeuk@kernel.org>, jk@ozlabs.org, 
	reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org, 
	devel@lists.orangefs.org, linux-kernel <linux-kernel@vger.kernel.org>, 
	linux-f2fs-devel@lists.sourceforge.net, linux-xfs <linux-xfs@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nilfs@vger.kernel.org, 
	linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ext4 <linux-ext4@vger.kernel.org>, 
	Linux Btrfs <linux-btrfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 9:37 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> The chattr manpage has this to say about immutable files:
>
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
>
> However, we don't actually check the immutable flag in the setattr code,
> which means that we can update inode flags and project ids and extent
> size hints on supposedly immutable files.  Therefore, reject setflags
> and fssetxattr calls on an immutable file if the file is immutable and
> will remain that way.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/inode.c |   27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
>
>
> diff --git a/fs/inode.c b/fs/inode.c
> index cf07378e5731..4261c709e50e 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2214,6 +2214,14 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
>             !capable(CAP_LINUX_IMMUTABLE))
>                 return -EPERM;
>
> +       /*
> +        * We aren't allowed to change any other flags if the immutable flag is
> +        * already set and is not being unset.
> +        */
> +       if ((oldflags & FS_IMMUTABLE_FL) && (flags & FS_IMMUTABLE_FL) &&
> +           oldflags != flags)
> +               return -EPERM;
> +
>         /*
>          * Now that we're done checking the new flags, flush all pending IO and
>          * dirty mappings before setting S_IMMUTABLE on an inode via
> @@ -2284,6 +2292,25 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
>             !(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
>                 return -EINVAL;
>
> +       /*
> +        * We aren't allowed to change any fields if the immutable flag is
> +        * already set and is not being unset.
> +        */
> +       if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
> +           (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
> +               if (old_fa->fsx_xflags != fa->fsx_xflags)
> +                       return -EPERM;
> +               if (old_fa->fsx_projid != fa->fsx_projid)
> +                       return -EPERM;
> +               if ((fa->fsx_xflags & (FS_XFLAG_EXTSIZE |
> +                                      FS_XFLAG_EXTSZINHERIT)) &&
> +                   old_fa->fsx_extsize != fa->fsx_extsize)
> +                       return -EPERM;
> +               if ((old_fa->fsx_xflags & FS_XFLAG_COWEXTSIZE) &&
> +                   old_fa->fsx_cowextsize != fa->fsx_cowextsize)
> +                       return -EPERM;
> +       }
> +

I would like to reject this for the sheer effort on my eyes, but
I'll try harder to rationalize.

How about memcmp(fa, old_fa, offsetof(struct fsxattr, fsx_pad))?

Would be more robust to future struct fsxattr changes and generally
more easy on the eyes.

Sure, there is the possibility of userspace passing uninitialized
fsx_extsize/fsx_cowextsize without setting the flag, but is that
a real concern for the very few tools that are used to chattr?
Those tools, when asked to set an attribute, will first get
struct fsxattr from fs, then change the requested attr and set the
fsxattr struct. So IMO the chances of this causing any regression
or unexpected behavior are ridiculously low.

Thanks,
Amir.

