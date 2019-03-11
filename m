Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D603C10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 03:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 978AF2084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 03:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 978AF2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA3898E0003; Sun, 10 Mar 2019 23:58:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E51B88E0002; Sun, 10 Mar 2019 23:58:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D406D8E0003; Sun, 10 Mar 2019 23:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A62D8E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 23:58:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i59so1474259edi.15
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 20:58:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vfLiQuP9XhvIH0aIML08yoKeEJ3gcCmEumXqcsC09Q4=;
        b=RFb4+pPdrNLIyjVw3G5O+eDIsv0edUjT9TIvB6RalIHLEKnVWp9Jq4UshRcmNltZvQ
         a5Kx5HbF2cIBnfK2TgqcuajGd2W4/FYbdRX/m0+RP1xSqQS+tj+8FdP3QkBXKu85IBUd
         CubWESK9TtnRibCPicURI2Ol08fIHGacglC6OzezfjjgdTckKbknFl2b//8JkusioCyM
         8NaKQ+nfNF0JnFq6rVEsDOXDU+jcshw+dcR4YOFZOmBntPx+NQyPWolVuyYf3o2SoSTV
         4ElM5aFS+sLC+lQzGv0hrTxiAPAVH/4JyttPe5RxzkpbvQss4zkyDtSDRmhTkvOGqZy0
         CS3g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVDa40LNqHg/9K83aMwvFN6bch2OL/m9rKpssl2ld3gnsBk+4gl
	4+C4AO43OwZiWIyh0TPN/dbmR/EBwhsReptyfP82pvnxSJBt6Kt84LdOuJ0DAAuLQoNlgemu8XK
	7+4a0E7sd7SBO/gxhQmOr+muNsjPq8JUHVoTOApH08CKUs9fh3DdUx9Ex2WXengc=
X-Received: by 2002:a50:aef1:: with SMTP id f46mr42433968edd.184.1552276703927;
        Sun, 10 Mar 2019 20:58:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy56xkJG/NKBy8yt1CJHOb3WSc7PAqkGrNFypwjyTJx6tRtdnX3cqBo/k5vDM4hTYGq77v+
X-Received: by 2002:a50:aef1:: with SMTP id f46mr42433927edd.184.1552276702966;
        Sun, 10 Mar 2019 20:58:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552276702; cv=none;
        d=google.com; s=arc-20160816;
        b=duIH7abGAJZlmqk75fAnU7uy7N+6FvMxa00C4wiC76R2gi6H4wyFqiXtid4vkgMOdo
         ZgNZtJJd/pe3lIPXrBptcPQf9ICAw3Fe0hsv1G/3tOzR7Q/jq6Vvoi5+Rk4MCA+rNQeN
         PGeyW8hPjipVPquQ+r1W/ZCMV2yxEPkC35NNWSwpYr9GrA9bz17qHaXdFV79DV93UpW3
         ZyCdDSqITgjkWgNtyXla/om5G16W0K3/OwKvRatyRQgArbuQReT6uwjoc8UWAKUO6uXW
         6cPJMU8zBjVQHNroGRWdCKH63w4zqvnoUKLCjsiMoTSu1AkLiykd0yYOJ/FBcefwwCGq
         378w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=vfLiQuP9XhvIH0aIML08yoKeEJ3gcCmEumXqcsC09Q4=;
        b=g3OZ6N24wrEN7P3GfxBA41rSuvEJQayOpm4hVPFnPiZ3xJDgQuGHbaYWbAF3VhVSDy
         VnvMCWGAQE0l3Xsoa97oMd/gExlD2X0dFbRp/CMBUFaUZ8bE4IU+5ZACuZuEApWcjIba
         atFgaC4KzVIjaANlxK2F859bEaf44Nu3uHebdx3XP+VzusuUpeQ8OUbyLsVOo+xc0W9e
         hOnjl/CdB/JhWO6eEiy5TKQMg7ida6vT67NkVjy4ihdaz7V4XBFYJTCUuR2ELJYp9vwV
         D4jAYzQ6Vr9EgX5fLSFQriWoC47b8CtWw5A2eZGXHOXp9chLlB9bsx/nJVOZbaAl4Ud2
         Rwfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z37si239872edd.282.2019.03.10.20.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 20:58:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F110BACA8;
	Mon, 11 Mar 2019 03:58:21 +0000 (UTC)
Date: Sun, 10 Mar 2019 20:58:15 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, jgg@mellanox.com, arnd@arndb.de,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
Mail-Followup-To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org,
	jgg@mellanox.com, arnd@arndb.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
References: <20190310183051.87303-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190310183051.87303-1-cai@lca.pw>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Mar 2019, Qian Cai wrote:

>atomic64_read() on ppc64le returns "long int", so fix the same way as
>the commit d549f545e690 ("drm/virtio: use %llu format string form
>atomic64_t") by adding a cast to u64, which makes it work on all arches.
>
>In file included from ./include/linux/printk.h:7,
>                 from ./include/linux/kernel.h:15,
>                 from mm/debug.c:9:
>mm/debug.c: In function 'dump_mm':
>./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
>argument of type 'long long unsigned int', but argument 19 has type
>'long int' [-Wformat=]
> #define KERN_SOH "\001"  /* ASCII Start Of Header */
>                  ^~~~~~
>./include/linux/kern_levels.h:8:20: note: in expansion of macro
>'KERN_SOH'
> #define KERN_EMERG KERN_SOH "0" /* system is unusable */
>                    ^~~~~~~~
>./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
>  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
>         ^~~~~~~~~~
>mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
>  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
>  ^~~~~~~~
>mm/debug.c:140:17: note: format string is defined here
>   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
>              ~~~^
>              %lx
>
>Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
>Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Davidlohr Bueso <dbueso@suse.de>

