Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4720C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:29:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AABA2166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:29:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hi9T44Hc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AABA2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 498BD8E00E7; Thu, 11 Jul 2019 11:29:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 422498E00DB; Thu, 11 Jul 2019 11:29:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30FC98E00E7; Thu, 11 Jul 2019 11:29:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B34C8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:29:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id r67so5335030ywg.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:29:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5sCdnmzsl1yenTFWhrojlM/D/t4ITTwRJQe377tVKgo=;
        b=TOaqecg58DK7oPZcTgfObXqS/7v2Al3QnfkM40xIjI7xjJ7kx41HG4NPnrJ6bDw0pl
         eVmmGUvp6zqO0SVHWkSf5Tz75bkMB9wADeWB/IIecyjW9zisCO8aYM9WeKqbJSyipUGR
         ocWmVW71OPLN4lcvQevdjIbVwP6WQTXgEqbrVfoUS2GX36RF+tlkxc1S/U58VVa8IMTb
         7CLzs01yBreSa8EVfNiaubVSoKfRWVBLhwksINqI59RD3A6AFAv9Hq4RFlg0G3FUldrp
         PJGlrKfpVkPM6T47IH4wQJ8EuF1BMUvfFvTpDvAtIGhMWjZBrcYO77O4reg6sCnkW8A7
         c17g==
X-Gm-Message-State: APjAAAUbGyV44gmCHTp8RvXUNjm2vT0X1RyUXdWYs6SGkGDgEzWtOLAI
	psh3Va4bc7jsF+sNe1CczySzQsFMWqZcVpws/xc76vu5//p9Ph+7FGZuuHPK5dJvscrHI9y9gDp
	XaW8chTbWH+lMylUC5nPG/IVo0XWFDTR1N+vhFl2oyF4cRq/Ip/xKRE98z/rvjKpa5A==
X-Received: by 2002:a25:aa44:: with SMTP id s62mr2814230ybi.146.1562858945758;
        Thu, 11 Jul 2019 08:29:05 -0700 (PDT)
X-Received: by 2002:a25:aa44:: with SMTP id s62mr2814189ybi.146.1562858945185;
        Thu, 11 Jul 2019 08:29:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562858945; cv=none;
        d=google.com; s=arc-20160816;
        b=Ww8NoGCF+nNW0XSNRVCbjnUfrW3BDVngXih09ce6Y56HQ6vmFq53HTTFx/gO7XG5eW
         Ot0+tIdSjgtq9x84ZfjC75NatiEssnaGF1PhbcH7sEDlnt6pC9CZ5Lbgv5mw/bBfHALc
         OgWK2KToh27jMajtusX7ZHKoooYTGg+Cks3MvLccvaxN+O+wO6OuFQwdveiI/QRbmlHu
         Pmfjz9SNDI6JXrSOc6PJBri0sA0Sw7NJmtV8jsjAOZRnhs0OQwo7J7YWU7EKIvgtx/Vz
         khy+NlwCR/WaAejFOR/0b8mv+meOtUe2Y4qtWduvXBSUsHEJ5A7jpWfeFBP7BHT9zhMe
         AkOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5sCdnmzsl1yenTFWhrojlM/D/t4ITTwRJQe377tVKgo=;
        b=xzStsPIVOL8PkmvIVxmk4sbbwCkwPRWwXlJtMNVPaANL0spn1/hfWoWXZUdmI7xTbw
         0uml59kbL+I/RIQDWIZcLWUS28qC3sS1DPg47v+v57eaV8a8Za8kPQPeWQMBzx7NqLKy
         DSj9oeVaGCX7P/o518W10iNeFkAO/S7cCNRnG33GLj76LkiyMAreMVeUgvHWPNlf3gPG
         Xc9S/PHZP+0sEdGa5C84wNDbIg6N9E3c+M7fyDeWxAXd2HfQwIfUsUiHtmtAPpk2Lrme
         TTOCeg1mcJ2f1NHxpDqnmL/LngT8MAEgjxOtNtLDoWciYx/lrhRVgAUQZaompItlDzzX
         5jtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hi9T44Hc;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k192sor3152491ywe.69.2019.07.11.08.29.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 08:29:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hi9T44Hc;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5sCdnmzsl1yenTFWhrojlM/D/t4ITTwRJQe377tVKgo=;
        b=hi9T44Hc/U1WaGxNK3YRIgCTIIMDaPwvl08nParEY8MDt275bPklFMyJJTW43mNamt
         1qo4XRN0biXSUMcH2yqLN0HgB5YbXFc56yN1Pf1NMq32lD3W9NrXaBtmcH72iHw7x+L2
         vXnEIqXq7MfEny31h8UAFF6rQ4BwQeStOx1fQ38NgYtozQ4mDWEAjHBi+XK998rvhPgQ
         5QBNL+gP6hoNbFaLt/tcnUQ47WfNCnoxyNk7RdurbvFgmUsyASqT7WCf2sCofGQ2OfNe
         Tm9isExHWRfS57q5NgooDQDb9TbkkKP/oorSth2cpRexa+BL+FbpiBsxrNUG18SetE5i
         dTBA==
X-Google-Smtp-Source: APXvYqybRjoMmoZeVATYSR5xajAV3WU3UTAp1AnSQg+8j0SLgEeFQbs8LxY7VQh36U8PWceOifdD0jQhCXZdcPRaZcg=
X-Received: by 2002:a81:3c12:: with SMTP id j18mr2694969ywa.294.1562858944848;
 Thu, 11 Jul 2019 08:29:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190711140012.1671-1-jack@suse.cz> <20190711140012.1671-4-jack@suse.cz>
In-Reply-To: <20190711140012.1671-4-jack@suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 11 Jul 2019 18:28:54 +0300
Message-ID: <CAOQ4uxh-xpwgF-wQf1ozaZ3yg8nWuBvSyLr_ZFQpkA=coW1dxA@mail.gmail.com>
Subject: Re: [PATCH 3/3] xfs: Fix stale data exposure when readahead races
 with hole punch
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-xfs <linux-xfs@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, 
	stable <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 5:00 PM Jan Kara <jack@suse.cz> wrote:
>
> Hole puching currently evicts pages from page cache and then goes on to
> remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
> and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
> racing reads or page faults. However there is currently nothing that
> prevents readahead triggered by fadvise() or madvise() from racing with
> the hole punch and instantiating page cache page after hole punching has
> evicted page cache in xfs_flush_unmap_range() but before it has removed
> blocks from the inode. This page cache page will be mapping soon to be
> freed block and that can lead to returning stale data to userspace or
> even filesystem corruption.
>
> Fix the problem by protecting handling of readahead requests by
> XFS_IOLOCK_SHARED similarly as we protect reads.
>
> CC: stable@vger.kernel.org
> Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
> Reported-by: Amir Goldstein <amir73il@gmail.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---

Looks sane. (I'll let xfs developers offer reviewed-by tags)

>  fs/xfs/xfs_file.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 76748255f843..88fe3dbb3ba2 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -33,6 +33,7 @@
>  #include <linux/pagevec.h>
>  #include <linux/backing-dev.h>
>  #include <linux/mman.h>
> +#include <linux/fadvise.h>
>
>  static const struct vm_operations_struct xfs_file_vm_ops;
>
> @@ -939,6 +940,24 @@ xfs_file_fallocate(
>         return error;
>  }
>
> +STATIC int
> +xfs_file_fadvise(
> +       struct file *file,
> +       loff_t start,
> +       loff_t end,
> +       int advice)
> +{
> +       struct xfs_inode *ip = XFS_I(file_inode(file));
> +       int ret;
> +
> +       /* Readahead needs protection from hole punching and similar ops */
> +       if (advice == POSIX_FADV_WILLNEED)
> +               xfs_ilock(ip, XFS_IOLOCK_SHARED);
> +       ret = generic_fadvise(file, start, end, advice);
> +       if (advice == POSIX_FADV_WILLNEED)
> +               xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> +       return ret;
> +}
>
>  STATIC loff_t
>  xfs_file_remap_range(
> @@ -1235,6 +1254,7 @@ const struct file_operations xfs_file_operations = {
>         .fsync          = xfs_file_fsync,
>         .get_unmapped_area = thp_get_unmapped_area,
>         .fallocate      = xfs_file_fallocate,
> +       .fadvise        = xfs_file_fadvise,
>         .remap_file_range = xfs_file_remap_range,
>  };
>
> --
> 2.16.4
>

