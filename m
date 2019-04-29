Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83579C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A1952075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A1952075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB3D76B0003; Mon, 29 Apr 2019 18:09:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63F96B0005; Mon, 29 Apr 2019 18:09:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7A3E6B0007; Mon, 29 Apr 2019 18:09:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3DCD6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:09:44 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so11621132qtz.14
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:09:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=y2LLRr55rR5hKb1ApyqxI8Pgjml+ojJFgSzmMrLVeBk=;
        b=N+LWqviDb6X1+7/GeNPN7R1zkImNsvJ5dMotnwQoHq6MChUMPfw+xzzayQeAAz8egQ
         xWYHptqyvyrCZbBO52ejZ8IZhyBhrTpPrayEKNHhnTbTVFppB7ttP/t7D12E1z4ljnxn
         GU4IOncLRrL2xWLdLlA4MHiA+zl8c9lLURFu5gXjk7trCMViBv3ZKYtnETdERsnLtZpC
         TdvWN/jZHA0dJo8ogri+BhwSAHN4EJmsYEv0rHURA45aDmPB3UPDHvmjCl+Uhvis2NOX
         BfN3qoOnqU2H0Wowm0sysHLIjsm+SWi3yHJ/KZM+4iGsuoa5Bt1redsGn3YlS9MZPG8q
         Gu+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX8Jt8pvsxyo5Pvz0/oAPaFu+Dv8lzu0qMtDYKawdwvy0Wd1t0x
	uejNZWOMzsmvNy2FjeMRDOD/RIekECfwQMFUQIaMFr/pzCS1CyNibwW+vXwozf2KQ7WU05GnL2L
	kWG+Qbsj/9efw5+3XXxgHQ/WLSIIbdjpFZJtOTYFDTtct+HJCLW+wmoanCZS60ogChQ==
X-Received: by 2002:a37:a285:: with SMTP id l127mr15913743qke.109.1556575784434;
        Mon, 29 Apr 2019 15:09:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzt4yZyxJ55Cc1P1R3IAqLDLbsU4g4X4ogq+euwbvUS5n4nnWJMUzTycQaOYA8HNE5DXNx
X-Received: by 2002:a37:a285:: with SMTP id l127mr15913699qke.109.1556575783718;
        Mon, 29 Apr 2019 15:09:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556575783; cv=none;
        d=google.com; s=arc-20160816;
        b=YCwr9caXdKsvBXTJO4WRSpBnvP9bm+w9/cnlAk2RXcF2ZCUFY3Uq+Ypr46G3TZvUra
         vo1bDPbK44/xFrjbcfxD82RtYGYNqCEft0x7BQSijOflA3lXcXQRr9FFyQGzMJYRuggx
         mrzb5Ve2EfbNHMYKG199+wiGZ6zMFAdfD/wOFJk3/NrfWLvHKq23JUM2nn7ZcLhnXtPK
         01YgMawZNRXiSJj/r+vCKcc7W2T6Aq3X4hR09UzWnCxwOLwrmYoocpMhjOh7hRKbNors
         1GkqhRdwtb7gzSf2kv/dSU9V9SddDpEsDqQ+iyAx2clRfAoFJDg7JR1mVVqVacneD2Iv
         iwIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=y2LLRr55rR5hKb1ApyqxI8Pgjml+ojJFgSzmMrLVeBk=;
        b=tNFr3OvV759rNR0Zseds3WR6oCdzrO5nmBr5uYXYZj/T91vQUN/shlcjBbHuYs+6jo
         LjtDJgCvGTsC35ki1nkARmexACnyUzo/uPtbnC8KF80leEJQE+lJuRUcitfaaVutCQmH
         EEcpqGq0kg4F71ShLgpeuxW14m/iQw9H9WYa/K5YPPMjbFacCxZCnruja7vRyEFI0fN/
         /gZY8P4GFMVR81KvOoVyVYEo4mdEZ4MHqDEXBAeuk+ktjizkaLbCgeFuyMbz4ep6HRIY
         1M2JLPryje0nCpTrVHWYDHk/Tm4BvY9W6zTH1kOwDJm9Vu2Smg9Wj9a65QFiWe3x/poh
         G5kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a15si3369895qkk.169.2019.04.29.15.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 15:09:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DA8C520260;
	Mon, 29 Apr 2019 22:09:42 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EA30517CCB;
	Mon, 29 Apr 2019 22:09:36 +0000 (UTC)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: cluster-devel@redhat.com,
	"Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	=?UTF-8?q?Edwin=20T=C3=B6r=C3=B6k?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v7 0/5] iomap and gfs2 fixes
Date: Tue, 30 Apr 2019 00:09:29 +0200
Message-Id: <20190429220934.10415-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 29 Apr 2019 22:09:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here's another update of this patch queue, hopefully with all wrinkles
ironed out now.

Darrick, I think Linus would be unhappy seeing the first four patches in
the gfs2 tree; could you put them into the xfs tree instead like we did
some time ago already?

Thanks,
Andreas

Andreas Gruenbacher (4):
  fs: Turn __generic_write_end into a void function
  iomap: Fix use-after-free error in page_done callback
  iomap: Add a page_prepare callback
  gfs2: Fix iomap write page reclaim deadlock

Christoph Hellwig (1):
  iomap: Clean up __generic_write_end calling

 fs/buffer.c           |   8 ++--
 fs/gfs2/aops.c        |  14 ++++--
 fs/gfs2/bmap.c        | 101 ++++++++++++++++++++++++------------------
 fs/internal.h         |   2 +-
 fs/iomap.c            |  55 ++++++++++++++---------
 include/linux/iomap.h |  22 ++++++---
 6 files changed, 124 insertions(+), 78 deletions(-)

-- 
2.20.1

