Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B326C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:15:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D418D20665
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KJwYtNp1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D418D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65A786B0007; Fri, 24 May 2019 10:15:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60AEB6B000A; Fri, 24 May 2019 10:15:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52BD76B0007; Fri, 24 May 2019 10:15:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31A986B0007
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:15:56 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so2638308iod.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:15:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vdyE1IbAdrPQM5ovOiRyFmLzasbQZYXuZYfheCMJqbw=;
        b=i2LQkV6eBq8YZghaw6ataoESnrQrqnt8jFx7HWXU2D+u7XAEszu+NVlzoHmbtf5wTd
         MFo7TvE1+94or3NlA88EpbNBfmK/mAV3OpW29wwel6iFlBkjgBXn027GjM1wVZ4Qogor
         HddOt1QxVjsu50amEneoe6h6fH2oT6vSPaptZCGpTyon2Y8dGEE8znRFM9e4WBD0cOQA
         0sbaTC17hFcm1b6F5Y7e/MXsID/IHNNh7QfCzEnWtCb4e+ifVB7MG2pGQKssdayvrIjs
         8V5JcquLdVRlBhbrzpdj/Y/dcQsx2DMUurOKTAhORZFArfvuURfhDEy1/dLmxYFX5xRU
         zm0g==
X-Gm-Message-State: APjAAAXKVq4upc4QbHfVzumXb3bOYaNpx1a5Qyta5EU9eRJia48cw4DH
	uJQuXvM3zRMwsivVqUQhsqNtwabAE29pASs75rRHNx/9nevb5g7v0ZWH+TVxCg0Fs2y7z5NGgP7
	t1m/XVcRH0Gow8LzFAVgSuX75mg8gk+cnDcrt0OYtROy3+3WlgCdRXv0GPFyTAyuaug==
X-Received: by 2002:a5d:8acf:: with SMTP id e15mr28676543iot.50.1558707355823;
        Fri, 24 May 2019 07:15:55 -0700 (PDT)
X-Received: by 2002:a5d:8acf:: with SMTP id e15mr28676494iot.50.1558707355256;
        Fri, 24 May 2019 07:15:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558707355; cv=none;
        d=google.com; s=arc-20160816;
        b=Jch9WQWjC29pWiG2p8JeKT+Oa4z1BIm5RixTKkOoeiK+L+nUOJ3KFZFLvPOiRU200V
         C5K3b9RWsWPLVREfSCs5jvafhWtVQY4NmsqaQ0BvFFhe239cFgUuRS4rfgBzW70xQJkY
         uS1N7k1xwGLPgWPm/j/fIzKQBT8e1qiyqdoEA7HzS2Y6qNzpOdiuahBH1HPhkZX5kvEd
         YqQ6Akr5GbI2pp1Udgq62rrKTuNDxb6fYHTaK2dCoe+davqAvZpI02OFtgJG+NtzjH2T
         Ph97WO9zeu3U/qeyv2Wnh5pdUWtv/jOPP+P/uGCSrrBr/6pwzCWMj2oiYHrB1OWO5Vxb
         PFCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vdyE1IbAdrPQM5ovOiRyFmLzasbQZYXuZYfheCMJqbw=;
        b=EtWPgRn8/H6wMJ8WAl8ZoUHryBa/AUOhTf3RK6k7T38q05qtr7VGOyHd75Z1WkyLRU
         qZ4hjl8pBAamGshg5KdynZ4JBhs2S5XKh4991Ui6GNbzLjf5rXLMrGnjUGF9fijYJYOi
         07TLpRqJU2fS68DAEWh5AQaIxDB5er3pUEPe3oq6YyE+VrzUQ7T8rt2AUyT7KWgnM2CN
         sQqC2rTkX5xOGi5Vx5SEfMgKZjvRhYfd2DSJFx+0ekN+boOOf3dw81nyrho9UAdFCqqp
         zaUqgFBXsOmjSgfQIwg3P8kn9hOlKF27Rfd/ezSZbX/qvLUX6rRGJosiWUMDktnNubbs
         QJYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KJwYtNp1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor1456544iol.64.2019.05.24.07.15.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 07:15:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KJwYtNp1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vdyE1IbAdrPQM5ovOiRyFmLzasbQZYXuZYfheCMJqbw=;
        b=KJwYtNp1/BjIMkX4VKbEUgHdFouFvetXHPDJveI0b3Ib6xzsuqTxF7PIjCxLpW7Eap
         WJSX4UCRckSN6zNL9IiwbPkAxAj2w61Cr43tKha13ZNT0+RlQ0FwaQ9+BZABAibmQfi8
         Dw9uEq4qglSsKbNnuhTEqJsLqSkk7cH4r1Keb9LBHTQMb8d/AfpW/HqPukaEuCVscPqJ
         ro9FPkBbsEubuT6G+y2WWlnvvupvpzXnrxmfnJQ4e+HzywUy2V45iy48CI/2DeT2KY+8
         3avOHiHazJ4D37WP/HvjykI8fp+vdUi1pUI80k87kUdA7PN9fIcWPPKUYN/oyP+ZpUtW
         p3iw==
X-Google-Smtp-Source: APXvYqzpEWaLmKIMamOmdtVUD7pEBYTszZG6g/0fHHGhV7wMzP5pF53sXIxPRicBhiro3YKd2HguOWMfSzMieT9khdc=
X-Received: by 2002:a5d:870e:: with SMTP id u14mr5195204iom.44.1558707355030;
 Fri, 24 May 2019 07:15:55 -0700 (PDT)
MIME-Version: 1.0
References: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
In-Reply-To: <1558685161-860-1-git-send-email-stummala@codeaurora.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 24 May 2019 22:15:18 +0800
Message-ID: <CALOAHbCGhRymJhKLbSXzwHszUtBexE9iD=MuywEEdROvXCrh+Q@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan.c: drop all inode/dentry cache from LRU
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	linux-fscrypt@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 4:06 PM Sahitya Tummala <stummala@codeaurora.org> wrote:
>
> This is important for the scenario where FBE (file based encryption)
> is enabled. With FBE, the encryption context needed to en/decrypt a file
> will be stored in inode and any inode that is left in the cache after
> drop_caches is done will be a problem. For ex, in Android, drop_caches
> will be used when switching work profiles.
>
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d96c547..b48926f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -730,7 +730,7 @@ void drop_slab_node(int nid)
>                 do {
>                         freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
>                 } while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
> -       } while (freed > 10);
> +       } while (freed != 0);
>  }

Perhaps that is not enough, because the shrink may stop when scan
count is less than SHRINK_BATCH.
Pls. see do_shrink_slab.

What about set shrinker->batch to 1 in this case ?

Thanks
Yafang

