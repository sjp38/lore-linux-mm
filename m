Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA7A3C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6344E218D3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:45:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ljt+A0id"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6344E218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01F9F8E0009; Thu, 20 Dec 2018 14:45:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEA198E0001; Thu, 20 Dec 2018 14:45:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB3BD8E0009; Thu, 20 Dec 2018 14:45:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABE128E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:45:11 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so3052184qte.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:45:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HKmYRYZ8i9OtQjopx4/zRiXjDlfBrbzkMJTi5+z4kig=;
        b=LH4TJiWVt12KqZCkMq6XzgDxP7yTrgJuOG7cnsCUFe3oEFNGlrX3+cY2kGsKWUgkLH
         ifBHcrAnVqPGtYUejR24Vv4X4QrPrbEq5UI/4QrpETYrhgUB7zM9715oReSa4YxKyXiy
         6rM5vw3ecJAniMRfk2SoRIKAexzepaZi9uUvObSnEgQaDvYdHCCM1QSI/AJzol1EReen
         vGiUAgNy3y1CsXsMAbGRsp05wYuXlitWBPKQjKD4HGJr54edjticwo5XxnO9Ldo1UdaO
         GYpU6qVrcY07F3eSg57PM4z71thbjtLj+YJRsON4FzVHe88VnNir1exPWZnHFaNRPKgs
         QyEg==
X-Gm-Message-State: AA+aEWYFDWTq/f0Yl8fNCC+pM9enPrDlI/zsDaWl3OaNz0qzVBqs1I0J
	y3xmGFF5s1ur9nTTqXqYYSQf0MP88KnBUW2LHdgePksR/fCHGuVfQvjpOY12MBvBY9cE/Xg7Gp1
	fsHLNGpajg34mrOBloS1/sRda/DTdS5pTmd9NqsTVQQ4hcLQyuM07jAmqQ4Ze7NBoFQ86NO/fvL
	4eC/LgnRPgB4+JExbRgAC42Doe2bcN9Arww0rcWBemPoCoOK0X+UDoF3ccwyfRWyf3Xmpn2UCgm
	hqJN8dEY1qUPyK38PAdDG6OFsv1Gn35QqjHd4Tie1Xo/6ntnGsEFfYU4/92D4AUI6PX+InssuZE
	WWSSxzHS/kLHzluam1SLkZLRUIMWNJgmSpnPmP63+l2aE36QCShW9W/KI4WHOpI2HxZmglvlNRP
	U
X-Received: by 2002:ac8:668c:: with SMTP id d12mr26530769qtp.242.1545335111407;
        Thu, 20 Dec 2018 11:45:11 -0800 (PST)
X-Received: by 2002:ac8:668c:: with SMTP id d12mr26530728qtp.242.1545335110464;
        Thu, 20 Dec 2018 11:45:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545335110; cv=none;
        d=google.com; s=arc-20160816;
        b=rkz1HVz1+zBPyUmQiOEW7F0WhgLUDSIjb3lpjcEOqUd3py2n+EssfC86uI+sNjd2cY
         qvGpuWDmlUGE2dAiNllUu8WL/D/bJ8Ka67w5KDfawiWMvORNJ3zNJC/g/fQ4rKDvDeyK
         9ISSRoNPnIuZz8YtjWFL64iRYOLk+SBGQJXFm9ACMeCxDBiqwSdqBWsVbwDkF2fMvi7c
         YIBiCmlmGmy6GchAsSKzJ6jS8ssFHU/to8lUYk+9n65jQTsuiuTEZzYQp/Z1lE+gmKce
         VTjcCT5R5o18jxaUmLSvd1SSd7B0RUFIvwKDNfHD2UFIp22D3FeL2uU0A6q2uM75iVT5
         35jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HKmYRYZ8i9OtQjopx4/zRiXjDlfBrbzkMJTi5+z4kig=;
        b=yKFPc8k6YhFm1eu1xP6E1znHMD+j7QcC+FR1qNpjMsKuPVrSR61YHQXFWWbZBt2RcG
         8szERfTC2ZdLihUxpk/5qLfR/5RQKHn8s10bvwqtNMzHVG7hZ2GtBxrKEFGy/G95SBP0
         5ZxMqiwt06qkxNUd4q4t6KM6ZYF5UMhvYwvCI6R8aiZfyFNpw8itj4FGDNkdrn+i9loN
         N13A6c6SZTAZ67TgugeVOwevr1DA6jJ1YKjmGcPrvZG3EoKsprFK9Zj3mF94ML7XmI+Y
         thmQm+Qg3AH2tZKGMifpVf/8F6/wba/YYtxzS07TfZJG28P6o/q2evpZMn9kUurgLUZj
         ld0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ljt+A0id;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r93sor4290647qkr.27.2018.12.20.11.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 11:45:10 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ljt+A0id;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HKmYRYZ8i9OtQjopx4/zRiXjDlfBrbzkMJTi5+z4kig=;
        b=Ljt+A0idXUEnF5LAnsQXnAhP2HjkaChKUTxbo/ITBVf0Jccx9GjxWhOyo3Oax+61Mr
         gDkiiHqNDoWVakbxfq1VL6G8+xFb/bGUk/5rmfrK8hebHu9k25Sa7BJ4nASHnAnVsGv9
         jvIo/5a+WqNhYcdSIozXUg8h3w+Gx4M4iV5tb66MnVNGerWOE63a3NCELEElZqvsJpyz
         JdjLLiXgjxVsV3r2PwKro5VErhPpvsEZcceRkjH4/JiOrRMK4Yqn3EAl4ZtjAUa1J1Fd
         4LMgDchFZrhvWxro7Dx0XWvrrhrOr3u+1pYTIHuELQHdIelUUVD/Zq5exBEN5leeaxFE
         NFUw==
X-Google-Smtp-Source: AFSGD/VBds3C89sGV9++238eDor5qCfEClTVWWva7YtSZqasPDTwvaUnyPK8WL4gMlDVdArK7KM2kSzVi99e2b0vDcU=
X-Received: by 2002:a37:97c1:: with SMTP id z184mr25956590qkd.39.1545335109937;
 Thu, 20 Dec 2018 11:45:09 -0800 (PST)
MIME-Version: 1.0
References: <20181214230310.572-1-mgorman@techsingularity.net> <20181214230310.572-7-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-7-mgorman@techsingularity.net>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 20 Dec 2018 11:44:57 -0800
Message-ID:
 <CAHbLzko6jXSikw-4LQXi6KfNR9=U4XJnB_OaaZ4XcNHUj4NLUQ@mail.gmail.com>
Subject: Re: [PATCH 06/14] mm, migrate: Immediately fail migration of a page
 with no migration handler
To: mgorman@techsingularity.net
Cc: Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, 
	Michal Hocko <mhocko@kernel.org>, Huang Ying <ying.huang@intel.com>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220194457.fGAo2vL272DchFzFxUg00hHnyWshY9vagDxf0MIouFA@z>

On Fri, Dec 14, 2018 at 3:03 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>
> Pages with no migration handler use a fallback hander which sometimes
> works and sometimes persistently fails such as blockdev pages. Migration

A minor correction. The above statement sounds not accurate anymore
since Jan Kara had patch series (blkdev: avoid migration stalls for
blkdev pages) have blockdev use its own migration handler.

Thanks,
Yang

> will retry a number of times on these persistent pages which is wasteful
> during compaction. This patch will fail migration immediately unless the
> caller is in MIGRATE_SYNC mode which indicates the caller is willing to
> wait while being persistent.
>
> This is not expected to help THP allocation success rates but it does
> reduce latencies slightly.
>
> 1-socket thpfioscale
>                                     4.20.0-rc6             4.20.0-rc6
>                                noreserved-v1r4          failfast-v1r4
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      2276.15 (   0.00%)     3867.54 * -69.92%*
> Amean     fault-both-5      4992.20 (   0.00%)     5313.20 (  -6.43%)
> Amean     fault-both-7      7373.30 (   0.00%)     7039.11 (   4.53%)
> Amean     fault-both-12    11911.52 (   0.00%)    11328.29 (   4.90%)
> Amean     fault-both-18    17209.42 (   0.00%)    16455.34 (   4.38%)
> Amean     fault-both-24    20943.71 (   0.00%)    20448.94 (   2.36%)
> Amean     fault-both-30    22703.00 (   0.00%)    21655.07 (   4.62%)
> Amean     fault-both-32    22461.41 (   0.00%)    21415.35 (   4.66%)
>
> The 2-socket results are not materially different. Scan rates are
> similar as expected.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index df17a710e2c7..0e27a10429e2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -885,7 +885,7 @@ static int fallback_migrate_page(struct address_space *mapping,
>          */
>         if (page_has_private(page) &&
>             !try_to_release_page(page, GFP_KERNEL))
> -               return -EAGAIN;
> +               return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
>
>         return migrate_page(mapping, newpage, page, mode);
>  }
> --
> 2.16.4
>

