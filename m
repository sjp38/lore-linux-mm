Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F55C282CE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AADB206DF
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:25:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AADB206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD8E6B000D; Tue,  4 Jun 2019 21:25:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5E156B0269; Tue,  4 Jun 2019 21:25:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4C636B026A; Tue,  4 Jun 2019 21:25:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B95B6B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 21:25:58 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e16so13658798pga.4
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 18:25:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4XZ0pVa+tNLhyWAYscx6UnjPvPRJi3sa+oh9MIWMGY4=;
        b=dKL2U6fhE+KcX5+ztC0vd5DdacUf72rwmUiF0XZkTNQ+t/yVInm9dhE/RiTgrnukuo
         9wLcLihngLrU/r3+GiAZrvtU5EySJDb7UwHfjmMsYGPCu5CWoNF4ZvQulPKGUImlCrp+
         s7owC/9cqUuhuK81xX6n86LDtIy9LcFllJRLncxkvlMNJTpvNV0G4SknXTJ+RasjHYeG
         TwX5anFkwqt4AHEYWHQvBPxlrSQY2S6A/1fEpxgrNjpcIAiLW0mnxuM7tkkpV5IaVsD2
         yCsLOKYq+6ihJrHt47Em4YNwVhJP+o0JaKCaTOhT8qDT4D+YFD36CaBw9qLo81aoTKu3
         4Jyw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWtdmbVmzco+Ft3CAop2jRDB80QxUQ+1gtmtRQnDo/s/KTYCXmO
	b11GWY7tJIsV2NAwGt1R/mAjkDK8lalKAUqBiwCWomZlzfhlKoHUyzC9rusQGQXOSQ/2DGqQlto
	uNWXbjePpCyaVaxGikWQ3SSXmrcjstflwXscqACzlx6Q0cMoVkByK5V7zmLpohao=
X-Received: by 2002:a62:6d47:: with SMTP id i68mr42421411pfc.189.1559697958238;
        Tue, 04 Jun 2019 18:25:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIzXtpVtzJYMABRR4cbeWmgN1G++IPvjuaKkHNH1uxHhwsJkj7BAmWJOr7DPbT7C1eIcyO
X-Received: by 2002:a62:6d47:: with SMTP id i68mr42421357pfc.189.1559697957398;
        Tue, 04 Jun 2019 18:25:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559697957; cv=none;
        d=google.com; s=arc-20160816;
        b=f9rm9p/4zM9ilqCrQFHEtIVauqoHnuOdEg59Ixwc5/4/WtQUFL2n4RnAkdMsxKN19g
         EKasunpQN3kXCbQ8U8/WSJChC60HpAigl74Qvq/ZneSBafO66uanY68HUX3Opff7yQbu
         k1nV2SKyrEf3Qr0rU3DxfWGTbjH2kJFaqdDAtsce3XiCde1RlBsukQ4h6IuvDPaiOaoW
         XrE5t8LnQWcqWBrZ0hG9u1RJDysqtfYnw+42le6MH9ROtirmC67rsoxYiOqqJXNuV9Dq
         Xl0JeXc4S48Y64es3KN7CwgQPCcGvswx5bj1HEqZWlE9E1mVbET3vckX/ia6E4BcNOXb
         c6DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4XZ0pVa+tNLhyWAYscx6UnjPvPRJi3sa+oh9MIWMGY4=;
        b=qrd5TnCv7c1Logqzqk1sffNpzFNK/CfMRkfhC5wp0omzK1xt2L2OSBeIU0v3KnKVeA
         fAl1gl8bBXygeHp1YSBl87BPNLCe+fC+TuqsyrQL1EWCsUgnKUOs+/dA9KGxexRR0yTh
         2ukNoxe3TprVciX3SZtRl/jsBaSNP6/iJlPjmvvcFDXH7Ua6NkEgDlwyybWENROQB3T9
         agKwrWoogcv26Nt3vWQXeyNYNdwfWEkUWrzdKRxQX9eqoZTfauS1tZWcOl0oDwmKwUO8
         ED2P+GNx76VvMPh3jetDDBTmz4jfIrt/Zqf3DOz1X+pwsrw6VneQEZcUn5NkLO7OjLNi
         KfuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id f7si23422552pgd.155.2019.06.04.18.25.57
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 18:25:57 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-180-144-61.pa.nsw.optusnet.com.au [49.180.144.61])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id 5D1B53DC6C3;
	Wed,  5 Jun 2019 11:25:54 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hYKgZ-0003fG-MR; Wed, 05 Jun 2019 11:25:51 +1000
Date: Wed, 5 Jun 2019 11:25:51 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH 2/2] ext4: Fix stale data exposure when read races with
 hole punch
Message-ID: <20190605012551.GJ16786@dread.disaster.area>
References: <20190603132155.20600-1-jack@suse.cz>
 <20190603132155.20600-3-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603132155.20600-3-jack@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=8RU0RCro9O0HS2ezTvitPg==:117 a=8RU0RCro9O0HS2ezTvitPg==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=VwQbUJbxAAAA:8 a=pGLkceISAAAA:8 a=7-415B0cAAAA:8 a=dBuVX4ejtxO155pZRcAA:9
	a=CjuIK1q_8ugA:10 a=AjGcO6oz07-iQ99wixmX:22 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 03:21:55PM +0200, Jan Kara wrote:
> Hole puching currently evicts pages from page cache and then goes on to
> remove blocks from the inode. This happens under both i_mmap_sem and
> i_rwsem held exclusively which provides appropriate serialization with
> racing page faults. However there is currently nothing that prevents
> ordinary read(2) from racing with the hole punch and instantiating page
> cache page after hole punching has evicted page cache but before it has
> removed blocks from the inode. This page cache page will be mapping soon
> to be freed block and that can lead to returning stale data to userspace
> or even filesystem corruption.
> 
> Fix the problem by protecting reads as well as readahead requests with
> i_mmap_sem.
> 
> CC: stable@vger.kernel.org
> Reported-by: Amir Goldstein <amir73il@gmail.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/ext4/file.c | 35 +++++++++++++++++++++++++++++++----
>  1 file changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 2c5baa5e8291..a21fa9f8fb5d 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -34,6 +34,17 @@
>  #include "xattr.h"
>  #include "acl.h"
>  
> +static ssize_t ext4_file_buffered_read(struct kiocb *iocb, struct iov_iter *to)
> +{
> +	ssize_t ret;
> +	struct inode *inode = file_inode(iocb->ki_filp);
> +
> +	down_read(&EXT4_I(inode)->i_mmap_sem);
> +	ret = generic_file_read_iter(iocb, to);
> +	up_read(&EXT4_I(inode)->i_mmap_sem);
> +	return ret;

Isn't i_mmap_sem taken in the page fault path? What makes it safe
to take here both outside and inside the mmap_sem at the same time?
I mean, the whole reason for i_mmap_sem existing is that the inode
i_rwsem can't be taken both outside and inside the i_mmap_sem at the
same time, so what makes the i_mmap_sem different?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

