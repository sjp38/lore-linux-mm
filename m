Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79DD4C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:22:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A2A420828
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:22:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JtErswGh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A2A420828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B81416B0003; Thu, 27 Jun 2019 17:22:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31348E0003; Thu, 27 Jun 2019 17:22:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20B78E0002; Thu, 27 Jun 2019 17:22:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 762556B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:22:55 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id f19so1586434oib.4
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:22:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=x3+/AfxLXuFdTRt+wVJ5N88Fn0d7Jt0QcG3rrM/CFYA=;
        b=W+/S/5iDKUf2TuzBqGmhG6vDDwDbwFS+mmCz5XFSu46+yp8b0UND/e57/mKPqsY/Os
         ENIqQvrqAvOGfTMYtF+2KBtxSeXMzp/TVKrxoYYkWMpczwXwvIvDBqX57HqghSMeBsYU
         o2Wrx6d4gMTb3+FlG8XWtlDaP86X+TDTK/gycQbUmP8CbizoLhIZNxpqCmi9/5DvrXRY
         S3mRYU0Pt7XV1jsvEIBsA1P+KhAGQwLrnyyL06aBzYiARPLmZP2EQSCCduwTJ7Rk5jFr
         fZh5duAtLJhMlIgM0OW5Z1Q08O9lhDEmR44NeLdSAAzSZDc+8iyqJkD4H0wZQpK/q24d
         KEYQ==
X-Gm-Message-State: APjAAAV4oBiVD4nYs4a6+K9Em4fMdNKKEZm56CNCqsBEqHmeug8xQmHP
	oDe9oXaY4q2GU4PL7EuwHb9+kZ7OtKypXOIJxJQpqn03QdHFd/fSJ8Tqx0BbItckodKRmHhqWr8
	DhqJhVwoGzGTpcpOohjjvNFA4jp0ilFNROvgUyjYojQDYb7QF507PuNjJd4WXF8nKag==
X-Received: by 2002:a05:6830:c9:: with SMTP id x9mr5073513oto.332.1561670575080;
        Thu, 27 Jun 2019 14:22:55 -0700 (PDT)
X-Received: by 2002:a05:6830:c9:: with SMTP id x9mr5073462oto.332.1561670574200;
        Thu, 27 Jun 2019 14:22:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561670574; cv=none;
        d=google.com; s=arc-20160816;
        b=f/DmZibHQ/ppAq3ns4zpcj5Y/CrdTDu7PEM8eFARNYvDG25BwRVqsW89HrTL2Bs4Yt
         iTagd8qigRCkzy002r56cGyFpEi0AxnzTaMBAJe+vJQEwB4xdvufnPlJzuQrt7nEfCJ1
         QAqb33i60wieQwA66KMChZDg4qFiOa1491xTk/EOhoWP43duBXKny4R5eV7s5Nezkh28
         OlMHFu4Fpu5knMXGH/dd9/Tpr/nggPKPYKP4CbRfF1gE/l9o2ZUptAAglRnVPpkgrJ/F
         +G7dQbGLnBI3NPmq76Gs3bBr9nTTytfim3/2DZt8mqQmBa+1tmGI5GwNmyZnJVt3ka88
         Pqeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=x3+/AfxLXuFdTRt+wVJ5N88Fn0d7Jt0QcG3rrM/CFYA=;
        b=kqWItYStAJb98VKEWgN+vgpHhzG0p1vyaPWms9JypaNcWbDtcpVFccp5tsYvj1Y54D
         rCLrowXWUOsTEqUhNEvObxrQStOYAlU8/pz0pWMvQwwGli0SD1/Ib5HCHSCfejO0do5f
         WWWuWmndWugJ22N/ETfh3s8nNDtOw/Hbf98mFJiEnGZSVUTxHehqxdLtGcve7igFZYjm
         eFAnHQ+fd7M5zAzbwYj0Gd6N1C9vv9ELRI/EGpI7dodIZhOjMX+udnq0gfMCRAxYA3nf
         cbkIU5Jr4iV5bq88w7qqcpH75OJwiKOeXrOMllUEMPqNK+J4MdxsJTIgSuP5tjhJk/JV
         Dr/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JtErswGh;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h194sor125590oib.133.2019.06.27.14.22.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 14:22:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JtErswGh;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x3+/AfxLXuFdTRt+wVJ5N88Fn0d7Jt0QcG3rrM/CFYA=;
        b=JtErswGhYDCrNfECuAxOCOEYWix8XG5/JXokcc4VzGBzvI/VkBg2osv2Vfd1YgD00G
         zE3E2Ho8y5Rhx0feStd4vbr6fQAxsfG4Nv5BPQm7jBEqo8BCOCXIu/4vhxUCDR29BQ+U
         OLa77XjjP0Pm69hLirNXv/ftJEeFm2u11Pr3wkRrdSGxl28uHh1lWjlkhkChxCFSzuQr
         c5dumHc4sU+K0juZy4Sj6VXj/uQ6kLWl33HbWH9Y5TGQ7rw7vksCHAsfCxblpx1AkLnM
         LPlF8cwYtS1Q06JBzBTUzKidcFSmV8BteXYxDnFcoAX+1FYM8DQl8UDccYpstyCu0Q6d
         /OGQ==
X-Google-Smtp-Source: APXvYqx7n5SoatNrD/f6URkFx2YC8fws4Ygfo/qo5bOAO4OD2enVvoI0R9bsVc0OVj1JFlqOFkvvecYbXNjpEzBEU1w=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr3511395oii.0.1561670572927;
 Thu, 27 Jun 2019 14:22:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190627141953.GC3624@swarm07>
In-Reply-To: <20190627141953.GC3624@swarm07>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 27 Jun 2019 14:22:42 -0700
Message-ID: <CAPcyv4h=MoP4GSF8xRULy54K7Rt9g2pnF3Xw0BNPRyYf5fKs0A@mail.gmail.com>
Subject: Re: A write error on converting dax0.0 to kmem
To: heysid@ajou.ac.kr
Cc: Dave Hansen <dave.hansen@intel.com>, Linux MM <linux-mm@kvack.org>, jsahn@ajou.ac.kr, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ this is on-topic for linux-nvdimm, but likely off-topic for
linux-mm. I leave it cc'd for now ]

On Thu, Jun 27, 2019 at 7:20 AM Won-Kyo Choe <heysid@ajou.ac.kr> wrote:
>
> Hi, Dave. I hope this message is sent appropriately in this time.
>
> We've recently got a new machine which contains Optane DC memory and
> tried to use your patch set[1] in a recent kernel version(5.1.15).
> Unfortunately, we've failed on the last step[2] that describes
> converting device-dax driver as kmem. The main error is "echo: write error: No such device".
> We are certain that there must be a device and it should be recognized
> since we can see it in a path "/dev/dax0.0", however, somehow it keeps saying that error.
>
> We've followed all your steps in the first patch[1] except a step about qemu configuration
> since we already have a persistent memory. We even checked that there is a region
> mapped with persistent memory from a command, `dmesg | grep e820` described in below.
>
> BIOS-e820: [mem 0x0000000880000000-0x00000027ffffffff] persistent (type 7)
>
> As the address is shown above, the thing is that in the qemu, the region is set as
> persistent (type 12) but in the native machine, it says persistent (type 7).
> We've still tried to find what type means and we simply guess that this is one
> of the reasons why we are not able to set the device as kmem.
>
> We'd like to know why this error comes up and how can we handle this problem.
> We would really appreciate it if you are able to little bit help us.

Before digging deeper let's first verify that you have switched
device-dax from using "class" devices to using "bus" devices. Yes,
that step is not included in the changelog instructions. Here is a man
page for a tool that can automate some of the steps for you:

http://pmem.io/ndctl/daxctl-migrate-device-model.html

You can validate that you're in "bus" mode by making sure a "dax0.0"
link appears under "/sys/bus/dax/devices".

