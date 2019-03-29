Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95FFBC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:42:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D22742183F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:42:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D22742183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 595FC6B0010; Fri, 29 Mar 2019 10:42:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 546176B0269; Fri, 29 Mar 2019 10:42:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 436A06B026A; Fri, 29 Mar 2019 10:42:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E52106B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:42:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so1197103eda.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:42:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JSSOOKEgCbEQq3UMekWc/5t5ssMZAy8jnG6oQrmZrTA=;
        b=hrAc1lvctT32cq0ZOx0qDDaItkQh99HCideg2uFKNu05tvBZsHvq7i4wD+s7pBb45C
         hSC4/lCCXqVoRxCdW6p5Imec452BZGVXX+HDP+MORnTDUVLmoEVT6VeDWLnRo3MNm2QI
         RsrrK2SU9ol9cHuuY9jyjM5iTsxF6Bq6rcZdMZckH0oaeVszJyntbUaiDqRskeGd5Vly
         KK62mngYsw4lyL7N271D0v6OpdjFS2Qy0AzVa/kp68n9sCCIm4Rysvfw5bZRtrDD2aIO
         HP1Vrv5f7F85Op8fHRhnePjLF6SVIdhiMZJmDinjEkoZqOtnCKmfafpPcdYM02wQy4/2
         W86A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXFik8Lyf1wrqptI0wUhYoph9OOcFcz6aBLK5xtlMV6xjsGU8AQ
	lW0ti0QYoO7EwaNiXwGD+QoVHKVOeEE2hF3141d6MUl0S6cjXaT48CWwEOn1BoTXqsmUayUCWv+
	AM/0abMK1zRg6xW5oZQ2y8luaJ/sUq/VwyOMME61SwWXk3lDG05h3y2q/Q2S9tc4=
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr28061144ejc.238.1553870524457;
        Fri, 29 Mar 2019 07:42:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxDZHM1b6eQQkd1aU8dh9RZHiDVKGRxk/pG8hf07OTS5BtuN7b+UiTuZ5zw2cIG0L6Q4eb
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr28061093ejc.238.1553870523526;
        Fri, 29 Mar 2019 07:42:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553870523; cv=none;
        d=google.com; s=arc-20160816;
        b=E3BuCqIxbHytCb6aciueYMh+RacZKJqAVvqvCK6BfT+nT4tm20QPuyZ3TqA/KBgGIz
         h98KjqLiVOBq32ZeJ/2ItWWkO/F+h06ZLvZvJ0z0WhkYzaRLvNvBx11ww5z5GwvJ3f7k
         pZHDLcynDItg97W1saVdk9+pw0kq6TpRxCIl7bg7ca3tQuoKbjGuc6NRUEhPpLFXK+9N
         kjvYt5Q+5w+9JXPfyZgqiBFkRQhzjldDvN536nzhvwUWhd4fPJMiEOzQRfCtrrSc8QZK
         50ssE/8RY3qU2CQN8Sfvfs9NZLx00Q0FkrSLS4kdXUIa8ReewqQIR6YOmuy2FE9p5JNO
         9soA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JSSOOKEgCbEQq3UMekWc/5t5ssMZAy8jnG6oQrmZrTA=;
        b=Im7SaMBhfCQVmyUDGxfhsIzq0QRCeajtCz0WAu3MColueb9iT5xdVpjT8Aj84P7JDA
         d9ov7vC7Dm8bBFVkFRpkxtvSt014j2bMkBVFn/+BNxqoqn1h7qlWc3aE5U9h9T0IrhZo
         9P7N/TU23BJv2b2pe0lvwvFPSnZ2FY9Wypd4TGeCg0cjTkfHv3RMnb9lPZ8yjj0hG/zM
         M1MsvaqbOdlkuZlAU+nLAddgp7H4Xja3s9xfkYMAgcJm7DMpujJpUh/xlD5aeSiQIQR2
         rtkALCu0eQ+Gmp/vZWmUhAlhalyMCjmyfQK5Aa2j7di23jc3tpGFC61p1gMkRzLIZbyE
         6IfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id b11si868402ejd.231.2019.03.29.07.42.03
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 07:42:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 1B094474E; Fri, 29 Mar 2019 15:42:01 +0100 (CET)
Date: Fri, 29 Mar 2019 15:42:01 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Alex Ghiti <alex@ghiti.fr>,
	Jing Xiangfeng <jingxiangfeng@huawei.com>
Subject: Re: [PATCH REBASED] hugetlbfs: fix potential over/underflow setting
 node specific nr_hugepages
Message-ID: <20190329144158.d55gn24qzrdfykvb@d104.suse.de>
References: <20190328220533.19884-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328220533.19884-1-mike.kravetz@oracle.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:05:33PM -0700, Mike Kravetz wrote:
> The number of node specific huge pages can be set via a file such as:
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
> When a node specific value is specified, the global number of huge
> pages must also be adjusted.  This adjustment is calculated as the
> specified node specific value + (global value - current node value).
> If the node specific value provided by the user is large enough, this
> calculation could overflow an unsigned long leading to a smaller
> than expected number of huge pages.
> 
> To fix, check the calculation for overflow.  If overflow is detected,
> use ULONG_MAX as the requested value.  This is inline with the user
> request to allocate as many huge pages as possible.
> 
> It was also noticed that the above calculation was done outside the
> hugetlb_lock.  Therefore, the values could be inconsistent and result
> in underflow.  To fix, the calculation is moved within the routine
> set_max_huge_pages() where the lock is held.
> 
> In addition, the code in __nr_hugepages_store_common() which tries to
> handle the case of not being able to allocate a node mask would likely
> result in incorrect behavior.  Luckily, it is very unlikely we will
> ever take this path.  If we do, simply return ENOMEM.
> 
> Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

