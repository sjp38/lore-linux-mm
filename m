Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38E85C74A4B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00CDD206B8
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:43:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00CDD206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EC418E00AF; Thu, 11 Jul 2019 05:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59C498E0032; Thu, 11 Jul 2019 05:43:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 465548E00AF; Thu, 11 Jul 2019 05:43:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 101B38E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 05:43:27 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q2so2303359wrr.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 02:43:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tN+aJAlcO20Lsqhzl5mSnGRV4uENNmV/oGnG33vw0kc=;
        b=UPVVnPkc4HNV/H3ZBUbuGrAlALxc2eHopjF8ayX/459gXvZe0cPdyKRsd7TmtixWJU
         rp9GPL941sEv+EGb5ttTPQtzJGRlPwwCvjaE0JlY+mT6jRK1+QdrmHSrb5sXDfoA9e5o
         nh85bIciXIO9hJtD4jI6t2yQYNo2roJOHYKJmYyB5yDnIeZyc/ORpMm189M5AHDGQOEk
         VHE1dVigc9zFeH3thSUQGtrlpYxxTVxx5UkuGKkmGN/WdTraAIqv/dkjzjPjBEKcMYvK
         ljoFjjW7wyVUoaHt1Dd2uCuZPtxbu3zcASd6r+4abQ802azHcrqlRxN2wBuVKL9XjgdR
         FRaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAUfnsv+9JlQpJoXNOOIHFSC1qWQ6zJPIi4SaJB/41x1H9ppdUaB
	yOB7q/ebMJ2mhE/jaDxYMXYAKeepO0ssA4/OsMjcOqFfCDA4rg/GNDuFfEhzeAt9uBlKmjGS0EX
	MZCcLTB2+iY3OEgXbd8uZats1RdSgCXQhx8SmxB0U++rlz4fbRXpBZe2PTZ2TMSCMRA==
X-Received: by 2002:a7b:c356:: with SMTP id l22mr3254222wmj.97.1562838206592;
        Thu, 11 Jul 2019 02:43:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws+Xhk0WDAqxoVLlbGxN2P9vgaIVV5hoynhUeiM+mG50lFN3qZAivVL9RCc3BSGe06ZhoC
X-Received: by 2002:a7b:c356:: with SMTP id l22mr3254146wmj.97.1562838205879;
        Thu, 11 Jul 2019 02:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562838205; cv=none;
        d=google.com; s=arc-20160816;
        b=UUna2AXpBCaACmk/KArIoE9XPzuy4QJKWjTBheLhqM46SuuO2cYadvURvUYmTaiWfD
         6ld7er4uuZ8y0gD7f7kEjzLBvMrdnaNn/TBo23CU5ZPM1Qbc2q6EJDHQCspGPk6bUhAb
         j5DuiFiUdBxsHYT+mHWxySvkYNNag/8ShrvI7M+IHD3Wg/5xfN/G4xW3G1Rtvegfqx0e
         rZO1KWRoMtQbstVdpJZiOG710rczoboXYoJ4cPA7/lL/ZqTW51cFjloAED403RCeh416
         Yx7J8mRWG7r43OL4GIMo0RCbPJeQTxbW+uKs1HFUwY8Uq3oO9tM/8wfuqKydCTqiStrK
         r/4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=tN+aJAlcO20Lsqhzl5mSnGRV4uENNmV/oGnG33vw0kc=;
        b=dzwQRCKMipgyAK1P28VS+RYl+GOoPoRzv2rMtyA4XsfJvBC8FowxurcOent4p/EJZp
         vozVrWI5bhiTT7EO+me8JSkWQJ5w4jDpowT/mCMBCiaQG7BlxrenROupXvcnJfvxaCm3
         WTfoLo2P3iUB/zY8gk5JhdhYuHfg6zaJudsdp2NfKYWia9PjnUtz6Gq9oZsz0hQpsAlB
         g8g/WkBd95XQaC9MF2ZjKsIhNmCaBoN2GgroxlY9wedXTiCjFuzQO3JFSaWYMwLWNAO1
         YMT73TtoFdqUsRzI3P1JdVdRSC8phqMDawKkeh8rpBYSPA7YsK4gNWHJe8qCz35HVDqz
         /9Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id g16si4953641wrp.111.2019.07.11.02.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 02:43:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hlVbo-00033U-OS; Thu, 11 Jul 2019 11:43:24 +0200
Date: Thu, 11 Jul 2019 11:43:24 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Yang Shi <shy828301@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Memory compaction and mlockall()
Message-ID: <20190711094324.ninnmarx5r3amz4p@linutronix.de>
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
 <CAHbLzkpME1oT2=-TNPm9S_iZ2nkGsY6AXo7iVgDUhg8WysDpZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CAHbLzkpME1oT2=-TNPm9S_iZ2nkGsY6AXo7iVgDUhg8WysDpZw@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-10 11:21:19 [-0700], Yang Shi wrote:
>=20
> compaction should not isolate unevictable pages unless you have
> /proc/sys/vm/compact_unevictable_allowed set.

Thank you. This is enabled by default. The documentation for this says
| =E2=80=A6 compaction is allowed to examine the unevictable lru (mlocked p=
ages) for
| pages to compact.=E2=80=A6

so it is actually clear once you know where to look.
If I read this correct, the default behavior was to ignore mlock()ed
pages for compaction then commit
  5bbe3547aa3ba ("mm: allow compaction of unevictable pages")

came along in v4.1-rc1 and changed that behaviour. Is it too late to
flip it back?

Sebastian

