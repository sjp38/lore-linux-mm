Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72349C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BCD52083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:46:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Ph8a0a5y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BCD52083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D88C6B0003; Thu, 27 Jun 2019 08:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 589E48E0003; Thu, 27 Jun 2019 08:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4790F8E0002; Thu, 27 Jun 2019 08:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EADE16B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:46:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so5881981edc.17
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QcDk5zUKbz23dkSjNBVXwjq0i8xHM9vtNbHjMMC6vV0=;
        b=g45VS6Zr5glr8GALy5fruRJ29yKlnzPv2Uo9C2gcKBfCxsKOcIOiwwgzOr4ZtKjGPF
         UlMoSDNouX8W0l3nI4+pQM/SyTbAN8JH4Nb5fgwkOYnggxYR/K172nyOodzVjtjNFgWt
         kTey18uORCMewLJCVDjXd3ezssgC/nQe92YESe+gAGvmzQzCD7VHv4SBd7VJ0OAzPk/m
         rH6vxJ9n4ZiKNyoWnKVXL+BvkrrccE1GV72F3CrrGBKuBblg60ZV9d/6254vxacYdwaC
         Qe/tEpRl3rJA0Xr+IupUxOYYaOhvV/5NK63PyBc9dHuBlQWz3hrZQOwFferipgd8WMvU
         VqcQ==
X-Gm-Message-State: APjAAAX9TlWRa/fqdLaQtSdSsBbo3DgyrUxVgVLd/54biEN41rtRq4Ay
	qPtwjWi6ZasWxXMOjcNdkKX3DR8M1NHuit0wV4OmJAw/026/slz9Bbfwf8QeHiYVgNswOsJOUHc
	wZmBdiOznE/klHkh2mmBMOfKRdbvfE7+dQeoed4HliJSCJ4dhfK1yiJCrFRT205gamQ==
X-Received: by 2002:a50:92cd:: with SMTP id l13mr3902021eda.136.1561639587547;
        Thu, 27 Jun 2019 05:46:27 -0700 (PDT)
X-Received: by 2002:a50:92cd:: with SMTP id l13mr3901953eda.136.1561639586731;
        Thu, 27 Jun 2019 05:46:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561639586; cv=none;
        d=google.com; s=arc-20160816;
        b=mxiyKeg/uo6a5NSmJ1MboEx98z/iUD9Y7hq8rZQHdAcoEdiy7Tc2XhlFFav2+hg3xt
         cqf1ReVqByevbIMcqBO1yk2N42u0M0kYIwJNaKtHEuQ/Jbf8uiR+vNDBPUG/0BKiG/s0
         BIHlDRfRty/y8cuWkyjQbCokIJNyexpRahzTkKwPnSIVDRVH59zxdsJl436dDya0Gx4e
         QhdTrfgyge8tRSi14jxborSakptT0cxHS99tSVd0uvKOGbhwlTlnk2E/ebByvJprTSBQ
         Lja6i1QbZtL2+fbhSre+1uCKBYh4y7KCYj0+GjBlc4/ugOLght/CGvqAzNdCOQYILrdt
         iR9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QcDk5zUKbz23dkSjNBVXwjq0i8xHM9vtNbHjMMC6vV0=;
        b=HDnesWUZMSmqfbCrQyrpQGl5ScvPs7C6mbMhLJofs3w/DrRDGp7CWSuqst8xkJdvSk
         lDnSET0r0gn4BH+la+3A1jEgTEvNUd/ac6gOZJs5NV7YhWilSb0FoUgwwR97T/WLoRw1
         Xhx1ehdSvg945nubsAgiMbxTVhixCUfv1ESyDmBjR78o5uYXig2McqV/OCItBap2oA+z
         o2AtjwLjG3wVrk29oemyGbu5Uz1n6a0aEwVpJV3iAhDGH9r7X8H53UL8W4h2Qo1IdP5P
         zUqxy9fSX6TZ4pym+1AE58oZLxCYQDl6e5H7dsSsk9caprSlOIy8jO+x/h2RMWYm0bvS
         ZyOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Ph8a0a5y;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor2116838eda.20.2019.06.27.05.46.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 05:46:26 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Ph8a0a5y;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QcDk5zUKbz23dkSjNBVXwjq0i8xHM9vtNbHjMMC6vV0=;
        b=Ph8a0a5yHbRPhclO3Pn0KnYkbHmqZJ1TzgavGNPl8lmeqhJTJc84xPfvgYwIEtmpAJ
         SLUBBxlcsWcu+FQLeGK2WBfqjvVNdPyCSw5uxBpm/DHLWwg6ht4aR7x0iOdbABcWIihQ
         wRNHBiJrT+zuLgpTm1MbLIaqKSi2JTrCJHxM7CkX09ypWgFJpJ4b4xqX00fWg+NBj175
         V7xJ+dVSS9ieTZq8jeuaAVG7c45OdqBRFsyCmrAD+BAy/yBT2KC/Homx61Vz7PAGYIeL
         7oTqvW3rLlxDu9ZaKffB5hPvoQHEQthc7VBSVJ0OTK1xXMRCB1wzy+2+JrC9R38OptSn
         mGQA==
X-Google-Smtp-Source: APXvYqx8PviEpESGoaGFrEkuGJDnDhMWSIld5rUq0chtQKwTslTti67hACIPECZQNkq5ZBizPpaPOw==
X-Received: by 2002:a50:976d:: with SMTP id d42mr3969822edb.77.1561639586109;
        Thu, 27 Jun 2019 05:46:26 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c48sm735496edb.10.2019.06.27.05.46.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 05:46:25 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 2E04A103F66; Thu, 27 Jun 2019 15:46:24 +0300 (+03)
Date: Thu, 27 Jun 2019 15:46:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 0/6] Enable THP for text section of non-shmem files
Message-ID: <20190627124624.uzu5trpfcdcz5uzz@box>
References: <20190625001246.685563-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-1-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000019, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:40PM -0700, Song Liu wrote:
> Please share your comments and suggestions on this.

Looks like a great first step to THP in page cache. Thanks!

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

THP allocation in the fault path and write support are next goals.

-- 
 Kirill A. Shutemov

