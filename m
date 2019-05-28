Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE7E3C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 01:24:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FB5C2081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 01:24:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FB5C2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F8956B027A; Mon, 27 May 2019 21:24:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A9196B027C; Mon, 27 May 2019 21:24:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0988E6B027F; Mon, 27 May 2019 21:24:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D17186B027A
	for <linux-mm@kvack.org>; Mon, 27 May 2019 21:24:38 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x23so9558433otp.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 18:24:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+sukcX21lhiUk7GXDe3MLqnZXO2zhx0hWP0GMK5AksQ=;
        b=KXE3hrFg1Iz3NEScdj6ez/r5Wr11NObHggSRSKinHNwC9AcvpYPQp0BkXj5SvhebSl
         u9mnddptMRHknj7XxCG/M2wbxEQvuph7nKlxl9ZN0qZRiFvmUb6G9mvayid9eBMcQ5pz
         H2zneKZ7KQnwmNdutXhLzkPzfMBnKmCr6VbflJTTQy23NDHSiVeFzjvYKftksoRVWqal
         IuU7WqDN2zocwVa2kFvR9ejDlTseUOwA/8ycy5qj07ho2fZJRr01cIVSeY4dBbyZXA5z
         VoxZShRKR+Js5yHr6y8/OtVAadEOECIrF6JNRLlj7qHnrbnR7FI3zKZqQK9WhHp2SeiF
         mL2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuchao0@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuchao0@huawei.com
X-Gm-Message-State: APjAAAUpD/2Kd+mnNKGym1B/d7t0pE17PE3aLAR6JiYvubAVhGJJJ6hZ
	0ys6Vap31sH5mjf1cVOwxfZmrW/O4PG1EhoE4rORNbbBow3Fcxg/VpJ2SlDWeYBZb9JLXaYKtuK
	GDeQEIErqW2LNMB/orlmJKMmA1Em8V4tHz2iae0ITwkwY1iXIaVCJmt7+f3z8M0353w==
X-Received: by 2002:aca:c5d7:: with SMTP id v206mr1181118oif.20.1559006678434;
        Mon, 27 May 2019 18:24:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVxMT7Gru0D8sARac/t6stf6Ln6sU6mQgSf9A+mjJVXkejLbRF6tP2b5PEmySLwNkmHCxg
X-Received: by 2002:aca:c5d7:: with SMTP id v206mr1181092oif.20.1559006677722;
        Mon, 27 May 2019 18:24:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559006677; cv=none;
        d=google.com; s=arc-20160816;
        b=K1jW8cmldSCyt1kfUFgXAIK4lwrWM5kTgY4EtdkeV2lm+aat1YL1AomqWL0C+QLWGt
         piSdA732BmjpszZlmXB4mTlBB+bPeo17wSiWcwiKHgEm1pDOrGoBULm4AgLmFBFWaBsf
         AGN/7dfUFSbn7Z8RsnLtp0Q1GgRd0Pudkwpkc/HlDgI9HkduzOzFMhSGWWaBM8moj/LV
         WxZmeayo7A/ZxjQyt4fwi4/zfjNb8Z/zaqMyNiE383Z2smIUyRCMiGM5yolHBzE5wuIV
         BIFY7XbxmVhl/Jjab5ykZz6D3RVoXMfs9+AFdAhllxInxQr+iUdQVRyOzOq8sc0Ay/X5
         CUeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+sukcX21lhiUk7GXDe3MLqnZXO2zhx0hWP0GMK5AksQ=;
        b=JAY3sPpmkNC/HDrt9DkXxc362x0DHvAA+9UtlRJmHbaklDPgYy3PE1IAd9Gtyv+umQ
         M7FBiwlfPpT6Gs52UAy900uabYAYITCSyDSl9L1OgVVY2vGgu+BOZedCJsncSAa7QbZd
         A4C0Z+6YQJm39DS49bclfChcjzIhvPNIq4zBFeiQ3bsVs4M/yz7VamUzYpGEJTobXv37
         LnR8JZMdiLsDX3eNwWV17PDpdk+/TxP1ai3NEOinBXa0ciGuvDWuGebVMfg/hgYkLdw/
         Hd/0Y3y44gkjB7LEGNWGzUfTYEbiBODopCXnJQ+UHzk7BumVQuzZfUyU2E4zGD6HlSwZ
         ecQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuchao0@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuchao0@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id q66si6912528oig.264.2019.05.27.18.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 18:24:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuchao0@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuchao0@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuchao0@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id CDBE6741DB59E7908D31;
	Tue, 28 May 2019 09:24:33 +0800 (CST)
Received: from [10.134.22.195] (10.134.22.195) by smtp.huawei.com
 (10.3.19.213) with Microsoft SMTP Server (TLS) id 14.3.439.0; Tue, 28 May
 2019 09:24:26 +0800
Subject: Re: [PATCH 2/3] mm: remove cleancache.c
To: Juergen Gross <jgross@suse.com>, <linux-kernel@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-erofs@lists.ozlabs.org>,
	<devel@driverdev.osuosl.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-btrfs@vger.kernel.org>, <linux-ext4@vger.kernel.org>,
	<linux-f2fs-devel@lists.sourceforge.net>, <linux-mm@kvack.org>
CC: Jonathan Corbet <corbet@lwn.net>, Gao Xiang <gaoxiang25@huawei.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>, Josef Bacik
	<josef@toxicpanda.com>, David Sterba <dsterba@suse.com>, Theodore Ts'o
	<tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim
	<jaegeuk@kernel.org>, Mark Fasheh <mark@fasheh.com>, Joel Becker
	<jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>,
	<ocfs2-devel@oss.oracle.com>
References: <20190527103207.13287-1-jgross@suse.com>
 <20190527103207.13287-3-jgross@suse.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <8f69d56d-3fdd-a160-9574-f81bd066e5ac@huawei.com>
Date: Tue, 28 May 2019 09:24:45 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190527103207.13287-3-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.134.22.195]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/5/27 18:32, Juergen Gross wrote:
> With the removal of tmem and xen-selfballoon the only user of
> cleancache is gone. Remove it, too.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  Documentation/vm/cleancache.rst  | 296 ------------------------------------
>  Documentation/vm/frontswap.rst   |  10 +-
>  Documentation/vm/index.rst       |   1 -
>  MAINTAINERS                      |   7 -
>  drivers/staging/erofs/data.c     |   6 -
>  drivers/staging/erofs/internal.h |   1 -
>  fs/block_dev.c                   |   5 -
>  fs/btrfs/extent_io.c             |   9 --
>  fs/btrfs/super.c                 |   2 -
>  fs/ext4/readpage.c               |   6 -
>  fs/ext4/super.c                  |   2 -
>  fs/f2fs/data.c                   |   3 +-

For erofs and f2fs part,

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,

>  fs/mpage.c                       |   7 -
>  fs/ocfs2/super.c                 |   2 -
>  fs/super.c                       |   3 -
>  include/linux/cleancache.h       | 124 ---------------
>  include/linux/fs.h               |   5 -
>  mm/Kconfig                       |  22 ---
>  mm/Makefile                      |   1 -
>  mm/cleancache.c                  | 317 ---------------------------------------
>  mm/filemap.c                     |  11 --
>  mm/truncate.c                    |  15 +-

