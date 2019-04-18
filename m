Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A2A4C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:09:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE73D21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:09:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JyY+dwTc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE73D21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 535C36B0005; Thu, 18 Apr 2019 10:09:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BDFA6B0007; Thu, 18 Apr 2019 10:09:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3625A6B000C; Thu, 18 Apr 2019 10:09:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFEB56B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:09:55 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id d17so409583lfb.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:09:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=M5siCfHP6BRRv+5HIBdrYDPCmhboYZvbHLTv7FcSa9I=;
        b=bE1N4zMdrfh4DTrv2Wm5nUcx9PxysX1A2ubrU/tX2+spUjTRNAbvBBcbgVIQxCYUwx
         CjQL6uXfau1E2HLx8Kat6kjDMMXSr0whLts5u1vXQDI5Oidcct74cMmmXkMLQvG668QB
         luMmtPdq42YzcteT1VDizA9qY7B9+upXycnPnHt4Dihc7N8SKCUwxQR/lvbdV2yjvl/n
         77JCQQNNE5bGDR7BQljEvyNv3tr1Y2TI4UoiVCspN16N9Y4iRT5i9jfqrJoMrpTM3mKF
         cq7XvhbuQXXU5n0UZEW2YtbQn7hqa0WkfyTDbcSQiySyAS5MIax6dY2edzVaRc/VgIqC
         n8wQ==
X-Gm-Message-State: APjAAAWPeJXWO7aiO0dphAWGOD07CZcpRVxQhSl5hUxibgg+pLvzrHSN
	kQFoklPYry8x/IfC+nqlhOEaDQzFQ2UhZTxtnRvYp2X18R2/ETAj+bIRQifqjMZHqZxmSmuOaOp
	i3MOMfq9uacEpbFZ1bEZmOezAjNhETEWj9tTr8cYEsCW211s+J83+vYmKMaiSvhvpOw==
X-Received: by 2002:ac2:5222:: with SMTP id i2mr16569551lfl.68.1555596594821;
        Thu, 18 Apr 2019 07:09:54 -0700 (PDT)
X-Received: by 2002:ac2:5222:: with SMTP id i2mr16569512lfl.68.1555596593894;
        Thu, 18 Apr 2019 07:09:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555596593; cv=none;
        d=google.com; s=arc-20160816;
        b=GnDwtY4kIXRVZEPSCgiFNCUDDs+axky8DW0FJfheygr427VFN/n1N3FXJeNwiErMmN
         Zr7mXAuWYtP0Jv4OFcvktmD1V/+i2z1foT0bEtAuI+GzxN/Try6TI0WYcCypVUjYNjVt
         JbYbMiZ1hw4czvQRFHr0yqbNIFlp/7J0DwZdFFu0z9OZMNwXF5DX9X91qSBTZLiWZIkR
         Z0Z17z/LCRZoeogpREJ43a7cb0W61mZYxV9qKWO1ip/nCsaS2MUmg4neJXOWlFsnbW0H
         iKH13SND4eQqO4gE7DaRu7BoUvF5fFyoB8C6uWqm5bPnxBVmVDIOJSx5nXjC1MRMl5pJ
         LIUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=M5siCfHP6BRRv+5HIBdrYDPCmhboYZvbHLTv7FcSa9I=;
        b=XVH2lggQOd3y4JhQWal9XopTE48ClpCiJqctqWuvGlJ7/xSEgwHlYKGTV9Ihanq18k
         yQr+k6WnMnGoZdZ3W9PiN9/lFZJx2hBtDcN4CGFUIAHRVvQndPeM+C0rSOPcMnQ/vzNp
         E68p0jjUq7FhJj7aldntxSEEY2ZrSpasA3ioc8+Qhu3FiSCIJSZXD6XddSuQ6R/sYUvA
         Itp4JcBgWkmWFivLmtza4C2wlil50AqSdeaKqk2Yh5EA+ItR4PrLGKtq+JaFVFkwGCxU
         Tf0G9lXAq93ykZ1VE672nqWNBGjMDR0WVg2A6BfsWVpOUvM4akpmWrorcVlMphRRapUg
         erxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JyY+dwTc;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w26sor615799lfe.67.2019.04.18.07.09.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 07:09:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JyY+dwTc;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=M5siCfHP6BRRv+5HIBdrYDPCmhboYZvbHLTv7FcSa9I=;
        b=JyY+dwTc08oWjbHxleqxC0ncbbwBF4oMaUwb7ZCNU2WOmjt/quOO1tXrYYzyCyutWC
         MkvSFQRQoEJiuaxY+6kKHQ2sPvWcr/lTFjEAPqtPCCw6/sdbzvAQtu3yULUJXzxjtibv
         8k+Bw0sQElny79mVcnmTijLpGjhiWs5PBh+zGVPdwy55UvoYI8pQh9iz4EHXM7qIkVQ4
         BP2CMdn13gGWO3tBbgNChg+k4K5HlKLv9mwaxLirITdao27RB6hCdgcr46bV/al1mi3c
         OFJDIPBad2L1bYlzkHvi0VOYFEe+orW4Z6SP+qxgZvI6KDeMcCsUYeO+dTau1Y0x0oCx
         vcfg==
X-Google-Smtp-Source: APXvYqzrj4shwzX3in9UPpImegqkTdLb+e4i4bJgo5k2iLRrydA3y8BLZAB2Obk207TGMdal3y75qQ==
X-Received: by 2002:a19:f001:: with SMTP id p1mr9821667lfc.27.1555596593484;
        Thu, 18 Apr 2019 07:09:53 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id 30sm471858lfr.22.2019.04.18.07.09.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 07:09:52 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 06858460E0B; Thu, 18 Apr 2019 17:09:52 +0300 (MSK)
Date: Thu, 18 Apr 2019 17:09:51 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, arunks@codeaurora.org,
	brgl@bgdev.pl, geert+renesas@glider.be,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	rppt@linux.ibm.com, vbabka@suse.cz,
	Laurent Dufour <ldufour@linux.ibm.com>
Subject: Re: [PATCH] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190418140951.GH3040@uranus.lan>
References: <20190417145548.GN5878@dhcp22.suse.cz>
 <20190418135039.19987-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418135039.19987-1-mkoutny@suse.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 03:50:39PM +0200, Michal Koutný wrote:
> I learnt, it's, alas, too late to drop the non PRCTL_SET_MM_MAP calls
> [1], so at least downgrade the write acquisition of mmap_sem as in the
> patch below (that should be stacked on the previous one or squashed).
> 
> Cyrill, you mentioned lock changes in [1] but the link seems empty. Is
> it supposed to be [2]? That could be an alternative to this patch after
> some refreshments and clarifications.

Yes, seems so. From a glance the patch shold be ok. Michal will review
it more carefully today. Thanks!

