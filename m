Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DBBDC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BF9020C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BF9020C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deneb.enyo.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1DB6B0003; Tue,  6 Aug 2019 15:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 362786B0006; Tue,  6 Aug 2019 15:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 278A96B0007; Tue,  6 Aug 2019 15:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98F26B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 15:00:24 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t9so42764142wrx.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 12:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:mime-version;
        bh=06Vxtr2Wc/eDVW5tuEvJPvh+yz73HGZIHg+aJ7zQxXM=;
        b=dGSnYZ2IOlEKWW5NDmagnJsGG5F69IIspyzSb0Ssmk1WZ6G6HYVYx3IomhmxTZgYPS
         qeGW0vE/eAm5hXqAjGZ395SP3rqcB/lr1KOGQ0BKcofHOxTrtjXj+tWHPJqoYDymBhjC
         xkqd2zKarvaprgRW6SGofWPQ2RQrgrhhSYVCnd+LDYduRYmGG968O/TvtrHZmph+FB58
         svxRKWNA4tVOa7mic7ClxCsq4Pr0c6PL+r8hJpEEzDNQ4BPNWU8nw3Y9oET4zaqqfcQZ
         yhsbrzmX2W20a+pT1nqELKRgjJx7/tNYisiIYW8UTxHEtOzEIgjDV0SZoqe1eT5uGBqJ
         95uA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of fw@deneb.enyo.de designates 5.158.152.32 as permitted sender) smtp.mailfrom=fw@deneb.enyo.de
X-Gm-Message-State: APjAAAXdrCO0r9sxEL8fesLEH1je3h7WXuWPXAQ8UOKrJkX8L5J03NIV
	ZMTIGYaUIzrlRAQjhkB3Mmir9jyphqfHZmkDh9HKOiMLqMsv3a+GOX0W5AuRpAywDaXJHqMyVR0
	QFtrAkeM6yLs3LeyySqfbbpMW3zIhQ3hrxEWKyj1abB9oihcJd2C3A0YCcyHeAFCPtQ==
X-Received: by 2002:adf:ec0f:: with SMTP id x15mr6083339wrn.165.1565118024545;
        Tue, 06 Aug 2019 12:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJgunN2nhmUA82iOI5AR1O62VVB/ME9Gr7VNCOdoyte/ItrFADDVwaE+S+dN7zeEUjCQ7g
X-Received: by 2002:adf:ec0f:: with SMTP id x15mr6083307wrn.165.1565118023820;
        Tue, 06 Aug 2019 12:00:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565118023; cv=none;
        d=google.com; s=arc-20160816;
        b=CJaCx0nJogRmTCTuUQkyBuyReRUPMgmKB8L5K7uijtCMLcMLz4MZy2tkDgz5dcfVYg
         K2s3qHgoLA5ySknMJcBRVlzRwYE9qk0D5bLAnzQeBhalMFujgh5Q5IF9M0nX314HC9us
         hTAup6KlaIWc4wTv//XRgRmqXV6Z6yByuMaD6yUk/YE+v5QqVHSPaUz+iQZsqtzoHLm0
         /yEmg6cNIUAp43MXyG3co3hU6WlKMwPupRum4EJoXpBQXTMeVlKuoEpq502iMFbtBw5/
         AV9D7nWhvKXvu+kTh8nyOEsCLiReVsCI2O0Vg6vtJcEsSCD4D98qKnG0UdGixcT839D4
         4T1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:date:references:subject:cc:to
         :from;
        bh=06Vxtr2Wc/eDVW5tuEvJPvh+yz73HGZIHg+aJ7zQxXM=;
        b=bt7vcivenONyMTIRQEh+Zh7Lc3qIlTrncnycvwh4crKxC5FHLOTFHLGdJb6T54MBhp
         BGnMKgxF4lzVt6C6G2j8zf9Bn8lqf/0Y0UQYfZe+j5q96QA47nyaC0vD7S7PTJ+M43Ko
         fFXlug4tNh4gaRCs/0havOcaFD+FaF+QarxxwUk4By0A/7+q+LUNKMB/lxjZf47aA4dC
         v282dO0K9bI0LmRhv1rtvLlGaLXymi1z2udWh0GVEQeh7mlICjz4PGTmGU3oE0lhKbhn
         QbdjJBX5Fvx1VZ7chtcl09q37VZxaTrB111n42CrzCMPiF7P+VrHjZAh7kB4V7X1cCW3
         p9uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of fw@deneb.enyo.de designates 5.158.152.32 as permitted sender) smtp.mailfrom=fw@deneb.enyo.de
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id b194si66245239wme.81.2019.08.06.12.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 12:00:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of fw@deneb.enyo.de designates 5.158.152.32 as permitted sender) client-ip=5.158.152.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of fw@deneb.enyo.de designates 5.158.152.32 as permitted sender) smtp.mailfrom=fw@deneb.enyo.de
Received: from [172.17.203.2] (helo=deneb.enyo.de)
	by albireo.enyo.de with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	id 1hv4h3-0002lu-RA; Tue, 06 Aug 2019 19:00:21 +0000
Received: from fw by deneb.enyo.de with local (Exim 4.92)
	(envelope-from <fw@deneb.enyo.de>)
	id 1hv4h3-0007iX-OO; Tue, 06 Aug 2019 21:00:21 +0200
From: Florian Weimer <fw@deneb.enyo.de>
To: "Artem S. Tashkinov" <aros@gmx.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's inability to gracefully handle low memory pressure
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
Date: Tue, 06 Aug 2019 21:00:21 +0200
In-Reply-To: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com> (Artem
	S. Tashkinov's message of "Sun, 4 Aug 2019 09:23:17 +0000")
Message-ID: <874l2u3yre.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Artem S. Tashkinov:

> There's this bug which has been bugging many people for many years
> already and which is reproducible in less than a few minutes under the
> latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> defaults.
>
> Steps to reproduce:
>
> 1) Boot with mem=4G
> 2) Disable swap to make everything faster (sudo swapoff -a)
> 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> 4) Start opening tabs in either of them and watch your free RAM decrease

Do you see this with Intel graphics?  I think these drivers still use
the GEM shrinker, which effectively bypasses most kernel memory
management heuristics.

