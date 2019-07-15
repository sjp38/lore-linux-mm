Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED89C742D2
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 00:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10823214DA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 00:30:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hvOB55/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10823214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AAC86B0003; Sun, 14 Jul 2019 20:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85BF36B0006; Sun, 14 Jul 2019 20:30:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 771026B0007; Sun, 14 Jul 2019 20:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5526B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 20:30:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so9446006pfb.13
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 17:30:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=0fqNd+lFEsH6JE6dMAEzhoDPhAsSRGcUhBcnEGmBVgc=;
        b=H4pnXJ0LsTQvQ3Cm9P0mbJ877a0ZCHhbUDkI1fTF4QG7AnIBmyR9BCzeuW5VvYud6b
         IiMyLEv0FChC2/mYi/CHF/ei70vXAif9f00ryOqByGLeZCawgmkZI/hk0ooh9ycOazfy
         t/CD3zLjXqIo15ir5kUS+pfIXmX2JTDnWGevV58oRg0e9YYj8eZ1YXit3bjKjOU3xCky
         YDMZLoDwx6w6YAIo2QGYytB0QFQEBsPoAAeLXsAGnqivsn7FI66jU2WbkKSMLrNeUNoc
         Te4oSzjFzweFNHZdWS953eABlGkDBLs05aRgNfRJBA3OgQ9CJzs1xV0ajgK6+ZQ9NgoN
         VzSQ==
X-Gm-Message-State: APjAAAWLHx+1vWU4SjEX1yHGCSs0HC3jEM6ee636nojLxkKmV9NN31yM
	d5dgWwfJ0YWuOsJgfSrC6JKLk4agJG63i21scw2K4OyXCChgP+j15yfCPxJOkptgcTjBf3wDYdH
	5U3krybknA7Sb92TPRT90FdZZDXyL2M5XvROLjz4x0HXcKNz/v8spJJL5C7eO8Fq+Cw==
X-Received: by 2002:a63:f304:: with SMTP id l4mr23768143pgh.66.1563150615866;
        Sun, 14 Jul 2019 17:30:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUssAvK3wR3ceaffb45DUan64plXDthK/evtrLnirWX+2h4wouzbzNTQ3lw53GAu8WVufd
X-Received: by 2002:a63:f304:: with SMTP id l4mr23768053pgh.66.1563150614822;
        Sun, 14 Jul 2019 17:30:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563150614; cv=none;
        d=google.com; s=arc-20160816;
        b=LsAgA9/GhsyfI/y1OKF6OB47hkEE1xi27Jb3B0jS0V/XLOFCWm2RLpe7eVdF5ZewkV
         HvH447RNK9n8YK00E0EHYBM7149IQrsjHz117sLwJ6goJIxasYvlU1v7jEyF6QgarU0I
         25A96eAn9RGdXzczueALDekP5uwXMADUYZWSdOO9HYIHhKB1xxCiTtLxsdeaxgrhgYDi
         llKm0XnDlDvAFC6+oc0lb2qjAid9vn7I1muyp68dZMi2vMOEZs7CP9fO+bh/YLa0nplO
         H9L6ixT87RuQsL3OOekUmpkNa0IbfEdZ95VMo4Qkg0TD5hovq/01VbckD6TPACy9HGrm
         2pbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=0fqNd+lFEsH6JE6dMAEzhoDPhAsSRGcUhBcnEGmBVgc=;
        b=nlFBrBS30JuSN6xd5lQEB5wBRjBTtUVxpXXwx3+Exd1V9GBiHhf6oETBwJRWMtiFRa
         pb7TiE4n4IYUV5CZryT4ky3+hcZMt+4VJB+eaaNi9hxsLnfJ3F/UvbLXAQ5CL+GP2ZWz
         0Mm2Erlj8OjpIh9Zj2mEeCTQNg0ezlhcLNmF+4O+DUMiYW5IJfRBJbf0SWL5X+mwDU3H
         HANzio4t2MRWNP9ux2e72bHzOBPkKXRBc6xI0yopjy/032WJ4kbCr3g1PVC7xjT49cDW
         G+6gip28BBmHmgckvQyLKUHKd0XI1dwSLb+64WN6KB+4rfTbyEu/Ovm+A95IWq96vhzZ
         KU1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="hvOB55/C";
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t18si13673116plo.328.2019.07.14.17.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 17:30:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="hvOB55/C";
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] percpu changes for v5.3-rc1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563150614;
	bh=Zqe3Bif38VGdfHqkGKyP909Nfkdoz56H/UBLyahcrJ8=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=hvOB55/C04tQafjYWj3gJsQ8aO7yD1S0r+kIUCVnWtNB1C3gfLopID8RIjI29phbH
	 2pv4Ln9NhZW2fcVKgw4aRxdfj8z4cr6e/zkyvmDxfu4efopp5MFLZvWcPW+7SUAikf
	 RQTubiplG9QphF2z6bM8IYzqtvv+iK3nmlawXyDs=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190713041733.GA80860@dennisz-mbp.dhcp.thefacebook.com>
References: <20190713041733.GA80860@dennisz-mbp.dhcp.thefacebook.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190713041733.GA80860@dennisz-mbp.dhcp.thefacebook.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.3
X-PR-Tracked-Commit-Id: 7d9ab9b6adffd9c474c1274acb5f6208f9a09cf3
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: a1240cf74e8228f7c80d44af17914c0ffc5633fb
Message-Id: <156315061441.32091.1681296873427251250.pr-tracker-bot@kernel.org>
Date: Mon, 15 Jul 2019 00:30:14 +0000
To: Dennis Zhou <dennis@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
 Christoph Lameter <cl@linux.com>, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Sat, 13 Jul 2019 00:17:33 -0400:

> git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/a1240cf74e8228f7c80d44af17914c0ffc5633fb

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

