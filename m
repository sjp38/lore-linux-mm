Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 300E5C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:37:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC8BE214AE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:37:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC8BE214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C3EC8E0003; Mon, 11 Mar 2019 19:37:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7738E8E0002; Mon, 11 Mar 2019 19:37:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6898E8E0003; Mon, 11 Mar 2019 19:37:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2825D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:37:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o67so831381pfa.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:37:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qWJKVOAo/EUnfM6Zia287NPknw/tzBf4sCn4h32UQKQ=;
        b=k8Rn5IpfR4b5s9WMv+ReIraMq1ZcPEUbpd48zDhhoMHDCdRzLR5FqxKOIp2jNMQ+RE
         +2KPliQz6pt42jf1k8yCB4C6o5irtWKvueFTGl9jz26firVryKCmFabHhdRHSVe6Qw/i
         /ITsit3PnIva8/6Bfmml33+Z93JCpX8GmXZYn7c0XPf1+qccDGiQYcRSKvr4iB411gRr
         HdVqIwxRFUVFV0Jr2UWgSsuJccOMFkE0Xq/X/BEf+khFYObQmLf5DmuQRNoM3KPOHSnw
         20SaSSyQ53ki2jYAQL4TWaEe4M7yaum8E29sUc2dTNXrpjBeL++90xbSCdxhyF6BVF++
         51RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV9BXn4syh4RO8TzvFdFvGiJ5rj+4bstYnMXURHGGTKO1I3SzMB
	8BFk418RbiNtypmAOVQp3uZpUt5p1hFChlEnRwZHcm3JoX1kFdyL9qSDDQvI1HK7GxyBsJJJ5UZ
	4fOXMcVyJmRI+H3MGKzLTavcCzOHuNb0EbyO24wb8fqzoN0Czqhqs6DC6KdaVIM0IXQ==
X-Received: by 2002:a63:1b4f:: with SMTP id b15mr13292290pgm.83.1552347471861;
        Mon, 11 Mar 2019 16:37:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwucm3Yc1Krz0pmSssXXfmOOO/GAt/sLOUv7cdR1BisvPacmWiRoUlHzTXFo1fBVjd54tYE
X-Received: by 2002:a63:1b4f:: with SMTP id b15mr13292224pgm.83.1552347470417;
        Mon, 11 Mar 2019 16:37:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552347470; cv=none;
        d=google.com; s=arc-20160816;
        b=F9ED482/uza8baankCuuus5cZ57sxeMhA9QWS33Yf2dhv6JljoM3dMU1MhNr7K36Ai
         2JpaaoRaIKzOhviXdkxmphyctj53G6OPX82r60eIUWiCRD+J4U+DSugd4ErbEbY42kOl
         DvCBAFQAa/kvpUgVVGP89Eiu7H2sXQx1tE1jXvmc5efq4G4FHop+FeYBjGOlZJAsmzep
         zp7UIfZQopChopWhHd0u8zgZIrzuxrqIsnJrXjl5NgJD7JbM6/7U4jzXoY/FTvhij84Z
         +PhmDHR4/trhp/CpQohA/MtNo7c/DKhDXFn7SFX/AdFz3UuXi/9Amcyme+HIy67E3dtw
         tzFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=qWJKVOAo/EUnfM6Zia287NPknw/tzBf4sCn4h32UQKQ=;
        b=egqAF3zZWb9xPB+mp5erORZAn1F5hl22duwTy6RowKxiwc+WjaxVF5ZsTqNNX6gPAH
         NN0/TcbJxG08nUxKY7hSvBbQ706dCuUVUsPUQlR7mh5pr24dWGdEpSpDrSB8HipfJFie
         ECJmk5cMEbpyT13joDfGBtsGu2SlM2XlkpnxAV58t0jn1S+F8nCFDBlB5E5WAiZ7ehvI
         8BUt4T+r8G96BToQ3IZgYL8B6kUxvRE43WKm9d6sRjCAnPNvsJgs8d916PJz0X1PiIbY
         gAHmAo21qZmGBsgbOzOHui6spxBSMxAs77hT0yW8slBf/gTRzIDiRzk9GD7BEpNq24G0
         DszA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 17si3037851pgy.154.2019.03.11.16.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 16:37:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 6555AD2E;
	Mon, 11 Mar 2019 23:37:49 +0000 (UTC)
Date: Mon, 11 Mar 2019 16:37:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org,
 mhocko@suse.com, sfr@canb.auug.org.au, shakeelb@google.com,
 syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-Id: <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
In-Reply-To: <0000000000001fd5780583d1433f@google.com>
References: <0000000000001fd5780583d1433f@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:

> syzbot has bisected this bug to:
> 
> commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> Author: Shakeel Butt <shakeelb@google.com>
> Date:   Wed Jan 9 22:02:21 2019 +0000
> 
>      memcg: schedule high reclaim for remote memcgs on high_work
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> git tree:       linux-next
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> userspace arch: amd64
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> 
> Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on  
> high_work")

The following patch
memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
might have fixed this.  Was it applied?

