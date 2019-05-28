Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F210C04AB3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 00:50:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C0A620823
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 00:50:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C0A620823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E958F6B027F; Mon, 27 May 2019 20:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E463C6B0281; Mon, 27 May 2019 20:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6AD6B0283; Mon, 27 May 2019 20:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9497B6B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 20:50:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so12167524plt.11
        for <linux-mm@kvack.org>; Mon, 27 May 2019 17:50:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ObUsOjfYi2knL12seS4WJmK3UEY6GkuNgXPzUMFfCvE=;
        b=UQr5wHAw3OV8Luso72meaeLmp48iWgrKvnpgnvGZqCdDsk6rQr72VgRFG81FBBiRej
         1/c9Nvy38bhws/spKDp0f8+NM3NI0ab/nEcK1AtLKEojM55H4m9/zzmvfpT7Rmc5Z8ez
         OaFNxgz8OgFqF41DieyJZl/3HHo9AWEjRZhM6CZEroHHRESEfVo57jr3xO/KoU6pvzeI
         pXMrDOWiiiSf/dZ/GteT1vRc0T5zs7NbtffdM7xAQFqjJQDP7m/AgW5CoAmJ3Xj2rwSs
         vaGFnPEMSVEE2mHejN0phx+6tqqa8AI4mtxZjcZLKnqAlbXZ/6R4/3Hwn3w6NZIESDDd
         Kv0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWQNj5w4XtFC4LOUrVg7rGYuWf3Uk/kxhmXUYadMm/te24LBoKV
	Oz8Aw4lKPbd7X91EXDaELhr3IxhUqU2dOS0JkcupzPh6uDyMCslJTekMGm7/ZzXEhSwL1SFKq/U
	2ms2MXo7vkSwD8F7nfzN9MYTxO8eajnlgycYYp6npqlEhIqo9kfNOzaUbNyzWPfhIpA==
X-Received: by 2002:a63:950d:: with SMTP id p13mr129068021pgd.269.1559004624214;
        Mon, 27 May 2019 17:50:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJPdSCcQHfOWB2sGW+6TjDymC/uGEFMKHyI3sFJYkeUiDgqBIODZ3A6XcM1BRPWRZRkfJw
X-Received: by 2002:a63:950d:: with SMTP id p13mr129067959pgd.269.1559004623641;
        Mon, 27 May 2019 17:50:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559004623; cv=none;
        d=google.com; s=arc-20160816;
        b=rFC7TGZw5O3TcTOxkaWzXrxPIGZymXHKMRKn+B+92uz63GBeE9NSrtOs0do7WprV86
         PymgoUXoXCrr1U/j9rIQSmfb7CQn9NbqzIQTuBxgVkIS4W/7mNXx0XcA6kAJy93XEqks
         i7lyK5oHKnosQqrMBtE/MXElt/7PPTb/h5+3J40GAb8JZpRjzAfJIM2+At3mdJUqZ/Vl
         mOqB2add/hqiyiZE5aXkQY8z1BAOMOL6yjlztozpO4ZAPXDH2F4lS7/nKtg8/NttMeIL
         JHzEsinzKGZ2vErsgm3H/4ctaDgEPMzIU3YWutgEgnbX1OcMqqiIQzMEG7RNo4NZLy9f
         CD6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ObUsOjfYi2knL12seS4WJmK3UEY6GkuNgXPzUMFfCvE=;
        b=vdghoR3MPnkDrXmZOkM5bbAreJ2BasR6AfcPCh9Si8jQghFb/8UULiu0r6ca+QxKhF
         0IqA72wpQAEPt1F3tAv0VSkkLcuDeM7M8/RiCoc0v52dgmqZ8Z48ZoT0KF7HF4hDvYSY
         in0eeDHhawijgDzSOZHHrME/KsfO3VRrEaRs+ymG5ccgLOrNElJhC90NJhDinBjATq4A
         6iUX+dIgGASmKk2OGd0tJIwPTCAkt2AlzfNJqMp9QBP0YCTcTOqkVkxnMlUb9Q0R5rTm
         z44z/wxFTrkd1dqHEBzvoTOUk/cdU2eni0R4fXcZroKQjVubxatFgq9GPGBGJrhwu984
         IlJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id z12si18524879pgl.467.2019.05.27.17.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 17:50:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R471e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=24;SR=0;TI=SMTPD_---0TSq1luR_1559004607;
Received: from JosephdeMacBook-Pro.local(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TSq1luR_1559004607)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 28 May 2019 08:50:07 +0800
Subject: Re: [PATCH 2/3] mm: remove cleancache.c
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-erofs@lists.ozlabs.org,
 devel@driverdev.osuosl.org, linux-fsdevel@vger.kernel.org,
 linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Jonathan Corbet <corbet@lwn.net>, Gao Xiang <gaoxiang25@huawei.com>,
 Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 David Sterba <dsterba@suse.com>, Theodore Ts'o <tytso@mit.edu>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>,
 Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
 ocfs2-devel@oss.oracle.com
References: <20190527103207.13287-1-jgross@suse.com>
 <20190527103207.13287-3-jgross@suse.com>
From: Joseph Qi <joseph.qi@linux.alibaba.com>
Message-ID: <7c75d310-1beb-08f3-d590-b4ff2c42cbcd@linux.alibaba.com>
Date: Tue, 28 May 2019 08:50:06 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190527103207.13287-3-jgross@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 19/5/27 18:32, Juergen Gross wrote:
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
>  fs/mpage.c                       |   7 -
>  fs/ocfs2/super.c                 |   2 -

For ocfs2 part,
Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>

>  fs/super.c                       |   3 -
>  include/linux/cleancache.h       | 124 ---------------
>  include/linux/fs.h               |   5 -
>  mm/Kconfig                       |  22 ---
>  mm/Makefile                      |   1 -
>  mm/cleancache.c                  | 317 ---------------------------------------
>  mm/filemap.c                     |  11 --
>  mm/truncate.c                    |  15 +-

