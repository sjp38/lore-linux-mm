Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B8E9C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0604A206C0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:36:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="bf3T75IX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0604A206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A634D8E0002; Wed, 13 Feb 2019 10:36:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A110C8E0001; Wed, 13 Feb 2019 10:36:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926638E0002; Wed, 13 Feb 2019 10:36:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66F648E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:36:53 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so2563357qtp.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:36:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=/wJ/1+0IfXImQLXSkFuPezPDsOxJHo73pRzAKlG1VuE=;
        b=CvBfxTQXKQ9EZ3Zu8QCbVOoYPZ8r71Y7OsS/P+AUEVKNS0M9H4j8yZwS8HLXtkR6ez
         Vx9WYfYMQNHcn7hp8nKb8ZW6zTW6L8sANzbZ58NvHHElVfH8gC1eEEPLrWKxiXg+I0+S
         6IwrfuhyXyWe9m3SUPhLTGWoYM2szWQRSdlCafV83P6PdRAU/94FJh9U4ktnxUb9pg10
         Za4db4+ZE4q/qCc7TzxjZlb+BHjGtzAYEqAlbSvIIyNu+yLlcf/DOeJJz0+bmSPBSjMa
         huQIeBAg57SPnLRrqKS9OX5l/exSDJXZvtN8pZLEs8a9qkvdjSJlpIgFeLMIGepXriRr
         r3HQ==
X-Gm-Message-State: AHQUAuYXflmt5cM+4aUp302YXkwdASEwyWAeOl2QCn2ctlDji1FWGRoc
	TiySRInbnrrWL/zIB1tWvgOJET8x8hPaqy4zXD5uaaWAnzJf4If53oviNzIt+Rfd52G4RigYpNY
	1/gHS5vhJR4F15m70JrG5BMwjwakobXtNRh8JfdbNudDC7KN1ZvCuYyV7eTxZErzHvRJY24mq+c
	iNBoeUTmkoc/ZXIGNB8G7P2Lkmzh+70B5aenEc3gTAzjTYlGry0JG4ktAu6r+CT2ywQ0fzHXx8Q
	qmZt/b/CSe/J7pRy3E0t8/tapFQgD1R5wF3e9b1lGz/amboV9X2YMivFjYZDyP0JTnV8BCyRIRS
	XKPpKSXrMIkiZOXMbkcKedYLpfuNATsrSAaTZpACWfN02fpDHhxufkn5xogemzkuFYKLpvg08b/
	f
X-Received: by 2002:ac8:1bf7:: with SMTP id m52mr938583qtk.200.1550072213118;
        Wed, 13 Feb 2019 07:36:53 -0800 (PST)
X-Received: by 2002:ac8:1bf7:: with SMTP id m52mr938553qtk.200.1550072212657;
        Wed, 13 Feb 2019 07:36:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550072212; cv=none;
        d=google.com; s=arc-20160816;
        b=GpqHiK4KiY4E7vVjuxvAAAup5SOd4aKGWc0Ocfw3egt1lMmNBD/s3zj6ATI/Nt2Sba
         zIVvWLeRgB6TpBgFIwAvfcbZUChQ2nabZ+8P/EMI1O0U/9Xa1gk5qbUkWhDCEcpmi32f
         kLTIfAgC5ARGA9tGhOevypGr8Rd2V8s9ucNKprBrXU/VCuXs1yjjc+GpfXMHy/xi7XWm
         CYr52cnjMpAfdqiXId2+OcTvqR3itGOqIbCbdAHtH6Sd/pwRllv47vM2LuGtY7uGxSZn
         F4uIZ8yY+e+COtAMjroRSUO8Fa6Hc0ygIZnisQ6QSsCchCxjR4e6pQf1cgjIO58/3Gx1
         ZcvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=/wJ/1+0IfXImQLXSkFuPezPDsOxJHo73pRzAKlG1VuE=;
        b=sV7V0+vewO3jPPlO5cKIg7SQhBKjL5xNsJrH+Oe7e/H0anEeBLV89T9G//sCzHa8xV
         O3kvjMRP3SQVl9MYo8hi3MeI5MrxtsOQI6AzGCGnLdG4oz3PNV6Rmwbja7NHhoJxROqa
         o8RLT7skySOG0ffXioP6uSarbSb8puzC22e5rWqOTb3m+DrPd1wRUyneLQLwoRU7GsVL
         GVZmVd2qX4hT4nqY//ycg90a1mA6J+67gbyyJTa4BWV5KvxnQkqSZ4XsWeBLTN7fV21H
         HteN02vh3RCKP5E36FYL2Dse4P9kTeIGXxCMVuAurNfr/oZiK/APpOMVyvJTQP1wGhro
         Fsww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bf3T75IX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g185sor10231837qkf.66.2019.02.13.07.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 07:36:52 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bf3T75IX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=/wJ/1+0IfXImQLXSkFuPezPDsOxJHo73pRzAKlG1VuE=;
        b=bf3T75IX3Vc0FTdcrcpk1Qi6F+xpQrpNcEiyMakuj/c6LJI4n8SEnOqM4Q3xR8Xhg2
         44oIN1bay94X9D7kN4FOgcO3MLJorYxF2/Ysgp9bQ3C3YbNIyKXUuhfKrDxCDcM3VPqx
         PifNWnUs2yA1TORyDGBF+N4lMCdWa9myRne9kbiNdHFyf505uKPXRVNxBqeACtlj50OX
         oulNWva5sjLWc9A+HoFIGiG81zUOemIzhmpy5qRBXZ+sJOctg9GNpsTB79niN/ZdLpZ+
         hGR2M1kRx1VjQeVVK5utjQFfo3dj1zktZdggh2p+Yyj6tEGka7vkYG4orLL7bC5Dvpku
         DZzw==
X-Google-Smtp-Source: AHgI3Ia0WyEybXefqqkxuAMhJAMaAQuwapaIVg65W5L7u9GdCaBkKYSU/7AhbbaG+oGvq9oa2ypvmg==
X-Received: by 2002:ae9:dd84:: with SMTP id r126mr818066qkf.217.1550072212365;
        Wed, 13 Feb 2019 07:36:52 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id v124sm18898827qkh.46.2019.02.13.07.36.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 07:36:51 -0800 (PST)
Message-ID: <1550072210.6911.28.camel@lca.pw>
Subject: Re: [PATCH v2 3/5] kmemleak: account for tagged pointers when
 calculating pointer range
From: Qian Cai <cai@lca.pw>
To: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry
 Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>, Kostya Serebryany
	 <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
Date: Wed, 13 Feb 2019 10:36:50 -0500
In-Reply-To: <16e887d442986ab87fe87a755815ad92fa431a5f.1550066133.git.andreyknvl@google.com>
References: <cover.1550066133.git.andreyknvl@google.com>
	 <16e887d442986ab87fe87a755815ad92fa431a5f.1550066133.git.andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-02-13 at 14:58 +0100, Andrey Konovalov wrote:
> kmemleak keeps two global variables, min_addr and max_addr, which store
> the range of valid (encountered by kmemleak) pointer values, which it
> later uses to speed up pointer lookup when scanning blocks.
> 
> With tagged pointers this range will get bigger than it needs to be.
> This patch makes kmemleak untag pointers before saving them to min_addr
> and max_addr and when performing a lookup.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Tested-by: Qian Cai <cai@lca.pw>

