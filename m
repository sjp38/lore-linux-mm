Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E228C742A7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 04:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACA83208E4
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 04:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACA83208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B4928E0007; Sat, 13 Jul 2019 00:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 265418E0003; Sat, 13 Jul 2019 00:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10EF38E0007; Sat, 13 Jul 2019 00:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E05B78E0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 00:17:38 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c79so8699511qkg.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 21:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=IZTj4o3sxVMCsyfX3m8CbohJzz9KCaUXTlmAkCHs5I0=;
        b=F2QpMC0Wu6qA7JzgvbXtrM7KWETy56+i7xnpNBmwZvICOedL6YbeyKoJj12ret8pJN
         C4bxqXQjOLND4XrT/ztedBR4S59vv65IWZR4ev+hq1Hviwe4/7WxexqjSTWAJsqRbrT7
         fCZIf2BFoj8cntj8yNdvYYF4guk3QC3KVbHkMT0xzNOr4d4i/+PUfjrPn2+Wq6GKVp4z
         HZqJn5l87o2/QcjZA81e0YPoGA1d+uF47e6liqrFqzViuiHmZXs+khxc/LhhxkWoLVS0
         P1pYtfwaOs7O6Fpes9EYrcXEJwpABg6gmPPOCAFYl93YSIXHk7Mr5OnfVnspUFLWsD3W
         L3Xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXXKywnsUqaJfTdeHE40bbZYl1vRJtzwTAYzsZilqDecG8huIcB
	LqSCn4YAcRP0zNaHIHnNmXg7bqlrOjHAoGMg9B9dEjIy8xl0erROHkcwKCf5iWg54i8bqxbhFJz
	IWhx5/cumq143NQa2UBUQohclVfS68scItlhFChpRi3aMHMVwfToNjaO4C4jiiCQ=
X-Received: by 2002:ac8:2b49:: with SMTP id 9mr9562007qtv.343.1562991458712;
        Fri, 12 Jul 2019 21:17:38 -0700 (PDT)
X-Received: by 2002:ac8:2b49:: with SMTP id 9mr9561978qtv.343.1562991457940;
        Fri, 12 Jul 2019 21:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562991457; cv=none;
        d=google.com; s=arc-20160816;
        b=Nums16l0z9oWidheXd7mo5+rCjL5OliV0ssPnxEd62vFjWBRGuvYCOIA1A1Rym0ADA
         l3/vDFnA+dS/9Zu/A+PCBKv/oaqV2Rfkvxza+St3TkqGDlyL5PhfYn+cvDzGGbMbeTgY
         eUWU7WIjaGjE4fZz3hAgCi9Bbf/Xnd3Q6Uf0RGsmTy+Oiwmqt7pSID+HUEWS0jgoeQsp
         BG/Vn0QcCt43l349KgAS7GVvqebZ7JXYlWcMtqgHAgD0Nr45xetWK/cM4FU9of11un1S
         RMjp63brarn+g6AGr4zpVjP7mnDvsUK8GGou5qMASztvhvyRbmeTj/x9M8ugEVqixUZY
         QJyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=IZTj4o3sxVMCsyfX3m8CbohJzz9KCaUXTlmAkCHs5I0=;
        b=jb0gXhEwZQIH3T+yYsR5nrkIMK293LJUGcSird6eXl3grjNxXOOUpJUVTfD5Fs4cU+
         IpmOwqfejLMe0KCJIydzwXOgS+De/Tbxi4XRl1bpQtv3ot+ZtVSSSmWCFqLkdJ4afVVE
         xGl7a1A2aFdhFp61NRQ6Y/zrDQ1Fe8mpagckq/YsZdWYyeUcdIrI1MGMpmGnO7cSjPs+
         SoDx8sAqFitp8AuLrxBy9IlJDiLnAFjX0GSbSDVU1y7wNaFybZVxMX/i23GC1CurDE2E
         0VchBfkJeJkuEWrYqXs/hJMSXJr8V4i8gBq7tCWIjw/eUQj3ZgAOpEEcLjgWkpoIEebp
         lEug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s61sor14886669qtd.53.2019.07.12.21.17.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 21:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxF1eYLVsY7QeuSzeHGr+KUu5nGWsxiirKYW9tnKHKk/OymrIHBXCN1OjwFRiJwthcJobLE3Q==
X-Received: by 2002:ac8:27db:: with SMTP id x27mr9635952qtx.4.1562991457525;
        Fri, 12 Jul 2019 21:17:37 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:480::da5d])
        by smtp.gmail.com with ESMTPSA id n18sm4379525qtr.28.2019.07.12.21.17.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 21:17:36 -0700 (PDT)
Date: Sat, 13 Jul 2019 00:17:33 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] percpu changes for v5.3-rc1
Message-ID: <20190713041733.GA80860@dennisz-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

This pull request includes changes to let percpu_ref release the backing
percpu memory earlier after it has been switched to atomic in cases
where the percpu ref is not revived. This will help recycle percpu
memory earlier in cases where the refcounts are pinned for prolonged
periods of time.

Thanks,
Dennis

The following changes since commit e93c9c99a629c61837d5a7fc2120cd2b6c70dbdd:

  Linux 5.1 (2019-05-05 17:42:58 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.3

for you to fetch changes up to 7d9ab9b6adffd9c474c1274acb5f6208f9a09cf3:

  percpu_ref: release percpu memory early without PERCPU_REF_ALLOW_REINIT (2019-05-09 10:51:06 -0700)

----------------------------------------------------------------
Roman Gushchin (4):
      percpu_ref: introduce PERCPU_REF_ALLOW_REINIT flag
      io_uring: initialize percpu refcounters using PERCU_REF_ALLOW_REINIT
      md: initialize percpu refcounters using PERCU_REF_ALLOW_REINIT
      percpu_ref: release percpu memory early without PERCPU_REF_ALLOW_REINIT

 drivers/md/md.c                 |  3 ++-
 fs/io_uring.c                   |  3 ++-
 include/linux/percpu-refcount.h | 10 +++++++++-
 lib/percpu-refcount.c           | 13 +++++++++++--
 4 files changed, 24 insertions(+), 5 deletions(-)

