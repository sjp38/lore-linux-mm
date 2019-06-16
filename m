Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 347F5C46477
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 04:07:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04575216FD
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 04:07:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04575216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9139A6B0005; Sun, 16 Jun 2019 00:07:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C4846B0006; Sun, 16 Jun 2019 00:07:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B3638E0001; Sun, 16 Jun 2019 00:07:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 414326B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 00:07:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v62so5091425pgb.0
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 21:07:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=YajrpOLG+izSNYS14BIVQuiISX7C9SAYhDSJen+cHMc=;
        b=VcnWJ/8aRavjtHQWoX+eyY1G7zl0HBoP8kish4qtaX+n+OWQROZaOptll6vZY9JvBl
         l57hrOOBgmrC78AHM1WgJoHV3ZuO804HVhAcsNgPbZOH9Hon6sPvEgWovPmLeDRp/7mS
         8UsVq/3D+8nAtOql+WRWA8x0MPE6JBWJTPs7oPFLcfeoMz/SnNgC5fASBjlm1J1nQ3jh
         REEi1wxJ9NUIHXeYiETgfSq/wy9CYv2gsEM3l+cxMGhtQ7L93Rv0EYaxEuG422gwAem6
         KpLumak2L2KS2nG8/WvQLtg6Dj65V8S52atqvT6dlL3ylcBpK2jS+xTxV0hLw5LT0hW2
         0mNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVEbT3/6ei5HyROqrKwTiE6lbV8txtl3XVSNAO1mBqMRn7dqeiJ
	IchY9IO071uBNYUejZG9lF+LoneyI5g0tueEOF4SlIBpDEcDjUFT7xp4jhztgcLDtzttNR8IMO0
	vdagXPNAtRr5Ph28+yB8wIqFGMlMKntwWnTEmU9oZ1YFIRZ1+IY73bc12bHSDJju/sQ==
X-Received: by 2002:a17:90a:3787:: with SMTP id v7mr19345864pjb.33.1560658068781;
        Sat, 15 Jun 2019 21:07:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPFmQZv2KoQB4wc4Wcy1sHuJCE/1Irpr084eyp4bz6Gjy+TXSW7jZ+wz+wrWh4Q/kCButc
X-Received: by 2002:a17:90a:3787:: with SMTP id v7mr19345823pjb.33.1560658068084;
        Sat, 15 Jun 2019 21:07:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560658068; cv=none;
        d=google.com; s=arc-20160816;
        b=xr+bzfzaFGU+cmKsPYUAa2RQrFVDS4b5MvEFuHtS/zOEoqdxHVKBcgQ9KMGNN07nUD
         th3y5f8j7N4wrm5+TfNORmJhtqntOlBrSjvNIaOTgSPwFGCzVNM6R5gtMpGy0TGWLqH8
         pr8JSdjyH6KNgkJjqL7iG+klonNuRIA3VFZYiu3LaIDbHdjOsoqRs7K0XPO4NYDkmNhi
         hoJy5FEIR0XnTSmSh/IO+KGtC2GfkrxokhqOl+5MNRxY3W0ZawV/xGN7oUsd6wW6F//L
         PRAJ4ZNraAJ2Px8fkWPFVq66shlRi/as8QUR5a2zPhaKJfHD/+2viYbLgTENQMxvvdyl
         Lo0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject:reply-to;
        bh=YajrpOLG+izSNYS14BIVQuiISX7C9SAYhDSJen+cHMc=;
        b=fwjlr2m6uEQ38bv3MIiQU+00wSrFj4dSTXPgCkfo0NfgA0O2PlS4LTcKCOye4wifLr
         Q4Xq/UIiVjxVj9/lNaxovHzQB3eFJpGdD6fihBHKwaA80VRtGVLsMUkpcyTFlUhMX0QO
         m38xQt8PDOH66u/xDF8OIY04cNXaf9jrA5yLjL+RRfMxiW0KF1o+OZm36clP9YpyEijM
         6tB6/PPXi5mij3M9kbpcMeCJtR557znYFhT/pNpG8d2lJav9/JtoUR2foCDe5Ib3Gmtg
         +oxwCod/X8xrJYrCjmyEiDd1p+laPUMI1SJcOCaS15s/Q1cI1xAhzFmuhmjBagqNVUCF
         dxwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id w8si6773892pgr.258.2019.06.15.21.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 21:07:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R501e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=xlpang@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TUHzmZd_1560658064;
Received: from xunleideMacBook-Pro.local(mailfrom:xlpang@linux.alibaba.com fp:SMTPD_---0TUHzmZd_1560658064)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sun, 16 Jun 2019 12:07:45 +0800
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH] psi: Don't account force reclaim as memory pressure
To: Chris Down <chris@chrisdown.name>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190615120644.26743-1-xlpang@linux.alibaba.com>
 <20190615155831.GA1307@chrisdown.name>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <130aca9c-4d73-49ed-e78a-534ce2100ff8@linux.alibaba.com>
Date: Sun, 16 Jun 2019 12:07:44 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190615155831.GA1307@chrisdown.name>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chris,

On 2019/6/15 PM 11:58, Chris Down wrote:
> Hi Xunlei,
> 
> Xunlei Pang writes:
>> There're several cases like resize and force_empty that don't
>> need to account to psi, otherwise is misleading.
> 
> I'm afraid I'm quite confused by this patch. Why do you think accounting
> for force reclaim in PSI is misleading? I completely expect that force
> reclaim should still be accounted for as memory pressure, can you
> present some reason why it shouldn't be?

We expect psi stands for negative factors to applications
which affect their response time, but force reclaims are
behaviours triggered on purpose like "/proc/sys/vm/drop_caches",
not the real negative pressure.

e.g. my module force reclaims the dead memcgs, there's no
application attached to it, and its memory(page caches) is
usually useless, force reclaiming them doesn't mean the
system or parent memcg is under memory pressure, while
actually the whole system or the parent memcg has plenty
of free memory. If the force reclaim causes further memory
pressure like hot page cache miss, then the workingset
refault psi will catch that.

