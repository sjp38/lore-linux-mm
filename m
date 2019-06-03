Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B76EFC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73FAA275BA
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:17:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZYfS3VNX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73FAA275BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0482A6B0008; Mon,  3 Jun 2019 12:17:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3A6B6B000A; Mon,  3 Jun 2019 12:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E793B6B000C; Mon,  3 Jun 2019 12:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C96C46B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:17:11 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q188so17201022ywc.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4vwn4Z2ztJedleCGX20UEn2VsU1XB4LmwboMJgUz2yo=;
        b=S3ANmd3ebeyNd49+YaYtbedUO4cul6MEhE7aimhEgy92WT62IAb7lEAoUORmkdHnbg
         FcLm1lSzao8F6eVwFD5mnJ2gEaDvp5v+7ZIHbcOJRErydxHvH35n34AgeJisMAnhmAgQ
         F6vIJV+WeXRBvcMC/5shPnqHiXfp19sAex312LqYYHeZYU6Vu3SAAQTb1mPQOGTk4aDs
         ncmkdwvHTagI73JXRo6Lkgz+P/3nstwPK+F254an1aPoNuy3CDXpfbc7HY3w/9Ut5W4Q
         5HrQozjJYlw98IndQ/D3LlA6dAIjdOhrlCAioo5vqYbavHlkK0tkj781NgYh40cZ0KNp
         BhqA==
X-Gm-Message-State: APjAAAUOvzhtKf7g6f48wMExmslaiS3FX3qfu20yKm7NpK76Pso9Awnc
	k7zJTRQ1AjPzK7wei3swVTC62UMaGR72DFi16+pSxgUyPpWrr1NBy7gzt9DumTJkVPU1n5biPk8
	8bjYraje8d2ovHosoNCtKkNo4Fr0x/Tw+C9JM6FkEzZY31ZE1JOyeaPGxr27m0ZGG9A==
X-Received: by 2002:a25:e04a:: with SMTP id x71mr12310725ybg.468.1559578631579;
        Mon, 03 Jun 2019 09:17:11 -0700 (PDT)
X-Received: by 2002:a25:e04a:: with SMTP id x71mr12310689ybg.468.1559578630887;
        Mon, 03 Jun 2019 09:17:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559578630; cv=none;
        d=google.com; s=arc-20160816;
        b=fFn9TiyINNN8C2YLFTHCo92yJuqS/Ds+rEtyQ0+E175cB6Gh1DeXr/H/fJO79BVPLL
         ZMCFei/a95BIvx56bGJCvC7zOGqQn+YeLL/VD9VRktxm8oGQwg9eJ9+oDBl+MRLkg/5+
         xNHALsI7mtt1Jub/T1G6EMZMDbSqsVV+KqyEGpS0RpkdjLlkQS9XiiD8KLc189Cz4RHR
         yV1EclpKgvkRRB16ml6e60QnEYUpIOLNLluKoycsIqH96AVaGTNQdE6AyEThaV7OUqht
         fxU6yEte6cV/FeHPgmb0ZlTUUj5Lvfz0qL6UC5NbZyKgWTxMj1fjPVVHihMtd/Jns3A3
         O5Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4vwn4Z2ztJedleCGX20UEn2VsU1XB4LmwboMJgUz2yo=;
        b=uDcsEw0b0mw/qjYuR6Sfg8mHpmVOpQY9kdrPuaKbLNJ5H1Ut5JQictFumGMlzCY74w
         uAoNB96vyeeFyPCOeC7xVNo5tC8MAnnfbiCyz0ns+QBdXRRI/2O6CP5I1YEulUiWA7VK
         PjHGCmZfB9YqCo/IHU/27hu0K/E/pqj+LpyPe+VaTDWUMJ837v66Z0wqQXknLCPAdWTw
         sOwcTLq+V0MeQOK1imQ8IZmJ9Y7sWWb4BUyoL4Q/5MaIR5QNHIUdRjriA1/OdGk38xWF
         EM2x8AGKvHz6oVqXNk4F7bVhnfaBJ2YlKx8mb1aXOvEBmv2FMdL8hpz7LO1BIXBfKyA/
         H/qA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZYfS3VNX;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d137sor6616571ybh.162.2019.06.03.09.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZYfS3VNX;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4vwn4Z2ztJedleCGX20UEn2VsU1XB4LmwboMJgUz2yo=;
        b=ZYfS3VNXXEWUABUMQJ/TjINAkdSdp8IBPmagt/GdfF5JqK+Zi0NVsDaQkTM+Qn39aW
         3Uev1K7wpMO5U5evuaMrhyvOPZHe752h5As+ux1Vd4u6PF2498pnWSsqcWkKcy2QHvMF
         hNLui/nEQmRzaEpCyBloAWoL/8erPZgPQkjfxkGe+FhidgGF2X61TLK+83xLubiTNJ2A
         ceMOtBkUuL3GDLyZ9AyTOL8iYPEFv/t8BXfHE0etnqoEfLo1rVXDZ2MpNALp3bVurE9w
         AnbpReb3sA6vYuD9LWL9davHbsLR3yZBBVqbQw1c5nUfTJ1zUSJozYm+J+fyTmAU8rZN
         trBg==
X-Google-Smtp-Source: APXvYqzqL+1Lx2eYJaPhlgbT9M0UeUWaXHu/OpxdA4VNRqNEaWRPgs9CCWtY53KomQTg4/HQKPv5CsrZvecAtsm0Uw8=
X-Received: by 2002:a05:6902:4c3:: with SMTP id v3mr12322868ybs.144.1559578630535;
 Mon, 03 Jun 2019 09:17:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190603132155.20600-1-jack@suse.cz> <20190603132155.20600-2-jack@suse.cz>
In-Reply-To: <20190603132155.20600-2-jack@suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 3 Jun 2019 19:16:59 +0300
Message-ID: <CAOQ4uxibr6_k2T_0BeC7XAOnuX1PHmEmBjFwfzkVJVh17YAqrw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Add readahead file operation
To: Jan Kara <jack@suse.cz>
Cc: Ext4 <linux-ext4@vger.kernel.org>, Ted Tso <tytso@mit.edu>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	stable <stable@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 4:22 PM Jan Kara <jack@suse.cz> wrote:
>
> Some filesystems need to acquire locks before pages are read into page
> cache to protect from races with hole punching. The lock generally
> cannot be acquired within readpage as it ranks above page lock so we are
> left with acquiring the lock within filesystem's ->read_iter
> implementation for normal reads and ->fault implementation during page
> faults. That however does not cover all paths how pages can be
> instantiated within page cache - namely explicitely requested readahead.
> Add new ->readahead file operation which filesystem can use for this.
>
> CC: stable@vger.kernel.org # Needed by following ext4 fix
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/fs.h |  5 +++++
>  include/linux/mm.h |  3 ---
>  mm/fadvise.c       | 12 +-----------
>  mm/madvise.c       |  3 ++-
>  mm/readahead.c     | 26 ++++++++++++++++++++++++--
>  5 files changed, 32 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f7fdfe93e25d..9968abcd06ea 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1828,6 +1828,7 @@ struct file_operations {
>                                    struct file *file_out, loff_t pos_out,
>                                    loff_t len, unsigned int remap_flags);
>         int (*fadvise)(struct file *, loff_t, loff_t, int);
> +       int (*readahead)(struct file *, loff_t, loff_t);

The new method is redundant, because it is a subset of fadvise.
When overlayfs needed to implement both methods, Miklos
suggested that we unite them into one, hence:
3d8f7615319b vfs: implement readahead(2) using POSIX_FADV_WILLNEED

So you can accomplish the ext4 fix without the new method.
All you need extra is implementing madvise_willneed() with vfs_fadvise().

Thanks,
Amir.

