Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6795DC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28379214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:13:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28379214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3B78E0005; Tue, 12 Feb 2019 10:13:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92A7A8E0001; Tue, 12 Feb 2019 10:13:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81A5E8E0005; Tue, 12 Feb 2019 10:13:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31AC58E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:13:59 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id u73-v6so929096lja.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:13:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=A2Q/8CiPDU/Nkydp/L3q9yjGepXT7fNBvwQ7TM2rdOE=;
        b=SFZ4fTKYIIVjF7w/pfOJ4mqXIs45Vz9ysLK3R54iYxeOjWz66DeR1KdfdoVIhfu1sp
         jkK+iDt4nXxyaUotZlXf85t3o7FLf6R1w4rbgeK5nxMr7PPnLnIHB7zSG0SnS8WoMn5l
         IOvfIoXlC6eJVqUhkS0xGgep8hopad7o4Gj3fZj92vbTMLuWXr9IG4X0fo7Z/6GiaZhy
         NptfiRnKUza9sPVIBHvfCmZBsifbsPO1E7bwQXE2D2tX+jAOgbB4bYRSa7GnE7k0MvrF
         4HOw8LXvAjZuEohGq7cYItdnS1G94iJnbhfateCU8iwM53ySxNAZS+/RWu/S42nGeWZ9
         S0Ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuY+KxUnkD5EJro9tf98dQ7QCBmdWkaA7z1CtT1LnNuB+zcPd+1i
	R3Qzwj6cuUFfl05MaKCzYxngkz3Kjd5Cd7ge8Jr8FZvq53QREs3CFtfCxWfK4kqF/B5bdJTCOEW
	4NQtx7+t0g6dbqYeYJX2HuLaQWFY+12WByt7noJtA4nvgE1jcoiA5lP7UP41oh6NBSQ==
X-Received: by 2002:a19:2d44:: with SMTP id t4mr2608948lft.90.1549984438505;
        Tue, 12 Feb 2019 07:13:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ2nJaOmtLBVh0UCkEioqV/XiL6Hh1z+OweqhUFSv1LirSf8NIFRuAlcMYjraTXVEP3M36e
X-Received: by 2002:a19:2d44:: with SMTP id t4mr2608900lft.90.1549984437516;
        Tue, 12 Feb 2019 07:13:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984437; cv=none;
        d=google.com; s=arc-20160816;
        b=ZuFEXz4esiwJ5f3evei9L0t4cLRhjorN9Oe50KPvMvDrtT3OxtBxbH/zedmNO+KWKm
         0LCUOoYQTuP2FJbVwY8z/2CAfI2YI05+fcIoIdwYW5Ala0SCAvQKtANjtD6sELPOnDw3
         +qrb/l3urWx+cJFDXs2h8tTyJzJm+urAXqZtAiCrz/bD33l3A7ICaBHmG1VIcTrOqVib
         s5+qxXsx1OttJGNeqOxG4FGeSJV+l+8eZmc5fJuu2IroVsGxR4gg4NbOfk01PTKS7okg
         mbJWLZi5gJ5qOEE8SZ+TRCP68q5uV0Vm6q6e6s7cpJw6cTZMw8zTqbdlVv3KUB50sfpS
         mEFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=A2Q/8CiPDU/Nkydp/L3q9yjGepXT7fNBvwQ7TM2rdOE=;
        b=oyUFY0x+lUIPZyczLPS/qk957BzYD1NfCZlligqGo9ZCyBVf14YGTSWXzA1cees/oU
         E2WU4NTI20y8Dyxom52HVRWyqiJcKp8TgA9lq3mAWqnytYEziwxh3RWQCwZim0gIJD3c
         b/BvTX68Qj8y8b+tw3Ux7JlpOH7+vjTGrgU7lD4vBGIG+WqjENZPQvNSwyB1ER1tFqTw
         8QxIEw9zKaSNcHp6gQMlp6okV+dINalEznqJ6VAO+9J15dC5/MAO9fN+Qxy1onEwsjQv
         tg+dqo0XjZZMxUpyqZjLCww8WAdurXVdhc7JFk3a6x6lxwj+5o7Ia3DZ12h/zMrI8Rag
         sTmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r66-v6si12404698ljb.144.2019.02.12.07.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:13:57 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gtZkx-0001Yf-DX; Tue, 12 Feb 2019 18:13:55 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH 0/4] mm: Generalize putback functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 12 Feb 2019 18:13:53 +0300
Message-ID: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Functions putback_inactive_pages() and move_active_pages_to_lru()
are almost similar, so this patchset merges them in only function.

---

Kirill Tkhai (4):
      mm: Move recent_rotated pages calculation to shrink_inactive_list()
      mm: Move nr_deactivate accounting to shrink_active_list()
      mm: Remove pages_to_free argument of move_active_pages_to_lru()
      mm: Generalize putback scan functions


 include/linux/vmstat.h |    2 -
 mm/vmscan.c            |  150 ++++++++++++++++++------------------------------
 2 files changed, 57 insertions(+), 95 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

