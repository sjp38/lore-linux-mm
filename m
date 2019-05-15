Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25E00C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:05:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD5E20881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:05:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fe53eolI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD5E20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653BA6B0008; Wed, 15 May 2019 05:05:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604326B000A; Wed, 15 May 2019 05:05:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F3076B000C; Wed, 15 May 2019 05:05:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDB186B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 05:05:21 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id u6so452156lfi.5
        for <linux-mm@kvack.org>; Wed, 15 May 2019 02:05:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dsiZB9nVEVR8ihY/V7TPcVlkfDTLZU7ZnIyB9Kdlm0s=;
        b=eiB5YUdYa3DloiKXm50u2qEkHS9lVhXcEggYMoyCEXEO2rM3ocdOhY/ET/J5LcL93i
         4TmMif1HF1B4LICWfby4zmKlgWZiHEBCT+wOxpofxidAZNtEw7PEAn3Jta+QlD1Btb2G
         Wg6Am9v9WYiGKXL2fUkyUEmEYQA0VZGbFJUn9EF0Y30xQFeGWNX+XfmsQsuw2HMTDM4U
         eyk4vBjSioxxKALq2ZYikCh63ye2LhJoxnkl+TY1xqIKdSb5s4wYT44f6QqBD2hSUpKi
         sCHn80XfagLzU+g92xhQ7snwGh6DKyC+C9VrS8O6nfM6juFQ7qx1kjXm+JaS7IOF9nfp
         2kNQ==
X-Gm-Message-State: APjAAAVQrJtIe5cehK7OidW5bDM9eYk6u2+Z6npoSODQ5iA2x08omNWD
	M9LIy17HlP73Ck7p90lU8DQNDZ6Zbi9jUPamMr21eqyQhmB4p4j977w/OBlNKMpbDR/D/qQqngO
	DNIeyENWTNVcPi7XM8zmlZx4V7Y2KNSpDl/Siwl12CJmIXqCBZY6CUXJgEKG1GMLykg==
X-Received: by 2002:a2e:5d49:: with SMTP id r70mr20913014ljb.102.1557911121179;
        Wed, 15 May 2019 02:05:21 -0700 (PDT)
X-Received: by 2002:a2e:5d49:: with SMTP id r70mr20912964ljb.102.1557911120239;
        Wed, 15 May 2019 02:05:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557911120; cv=none;
        d=google.com; s=arc-20160816;
        b=AGvD0m5/87kTx0mIeWQW3PDVezY0BlqOLrVrxgIDHapH73rocO/WukMs8+8kb7BjI4
         VKNULKjCMO4hN62dw+2F1KRmuV7qX2t5AFE+PEGW/pFceg3Wo5WejN1Bnh6c7xYoaFtF
         wVS/UZIylzqLUpgVA/56KeHglegr95X16uckC2aZNqLa+Inzv4nSG39EOZe+5PbKLHWZ
         pcLB+9tQoYSB+5V7/LjZ5r1o3E0H8JIEn40aoe/U4Nlf8j7vfwjpcF+9BAbLuN0HBqIM
         oOGP2K/xH2z3JWvsVFh3FETRH9L7XNYobD1PZdIed5eImpfzmHbekHJQcdax7fQoKecF
         nsKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dsiZB9nVEVR8ihY/V7TPcVlkfDTLZU7ZnIyB9Kdlm0s=;
        b=DmAyiY5ArzkNHIKmo1byY9KKq8ukKcDV7JLOzhh/TbBe0IwkgXbY03aNSmJip5BqYI
         U9fdZ1nGMnmhHte6LYwvv37/Un7Q6w0hMpG9QqOT6hZnDabPFWfuPMbt3yvQeoM4dCTJ
         9C5NGakc/crMDzcfeN8cAJeY/GYsSoVQp7GRTPqUXvmGNpHJhiEvP5oDP75Ut3STK8dL
         4O+nurBy5fgNdM0dC7YVE/i8USUip8sWvPsKx7xyUgbReyqCXNiycXUOC8RjBrSsjWmJ
         e4supXDJeZhAUuhu43j+/SzpmNNnbRXdyMlBXBsuQwGR5QKdzpSDKV2ObKLFuVB+JZ9K
         OGjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fe53eolI;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y14sor408109lfe.65.2019.05.15.02.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 02:05:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fe53eolI;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dsiZB9nVEVR8ihY/V7TPcVlkfDTLZU7ZnIyB9Kdlm0s=;
        b=fe53eolIL/3iYiMnsq+1fXzykGVvwxyKevubcWnZKt5EOSxiBQCaqTTbU78kF7PCXa
         +wvCfluF3bI+I5OUGCPYwR+gay2dlzf3EpA7is3C+xg78U4Pqkq7xLZzxfpfk9lHHCJy
         0SyuK1T0jYk4EsY4slOaWmzfR1U8cFZoZisIiYr4DgnAonBW8ltQIGkSPq5QxQa7d3tS
         D6oohPDjEAy9t/Z4APcbjRMzuXxiNWlEewbgc+fLtQM8MIQI7oeuAHZ65SbYeQnzru/U
         tx+dU3PcZ10l8JzPDzWlmj/y2BXvWX5DVtSnGknVSVfo3/FX0vfTIIAqxPAs+oNHOv8W
         IxmQ==
X-Google-Smtp-Source: APXvYqxk8AMzC4DKr6czDtY/cExV67S3F3wZiIOy6PKstKBlhndOD4EYhMZcM28Xe2C1SIWv1DsFKQ==
X-Received: by 2002:a19:711e:: with SMTP id m30mr17636859lfc.106.1557911119589;
        Wed, 15 May 2019 02:05:19 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id f11sm272370lfa.48.2019.05.15.02.05.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 02:05:18 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 807AD460442; Wed, 15 May 2019 12:05:16 +0300 (MSK)
Date: Wed, 15 May 2019 12:05:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 1/5] proc: use down_read_killable for /proc/pid/maps
Message-ID: <20190515090516.GB2952@uranus.lan>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 11:41:12AM +0300, Konstantin Khlebnikov wrote:
> Do not stuck forever if something wrong.
> This function also used for /proc/pid/smaps.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

All patches in series look ok to me (actually I thought if there
is a scenario where might_sleep may trigger a warning, and didn't
find one, so should be safe).

Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

