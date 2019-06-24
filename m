Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55763C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFED20679
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:34:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFED20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F19D6B0005; Mon, 24 Jun 2019 11:34:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A41B8E0003; Mon, 24 Jun 2019 11:34:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690B58E0002; Mon, 24 Jun 2019 11:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30EA16B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:34:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so20982431edr.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:34:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PO9YeLkB1SMJb/jJHsI3pjVR6cVpXVnKzrwy5nsh+Ss=;
        b=TCDC78yAF5KcaB2ZOKTbwx+hw0NhNzo6Aj1HTz2cAxGr3ghkQvbgDZbcJu5WyMUjF/
         Jh9qS3OF05MLOa57HjnZ3d4mtXDplO2Nkamh9GhVtKNsQRa6rjuLeDkqbSa+M9N5TpiC
         EPK5l/dh1SZ3U1uOtoN0h4zzxwcAB2XaFK8wzU/6i8rLz27Qbp+YwpRAWtDzoWX8P9AZ
         Rhbp7fn52poKTg/ijF9iTpODhS+jJJys67uxXhcwIoCHMTGipX3s7QKCpMo+ybdZZFGA
         s2U4/mgoYo3atwrgamZLq30QjdhqXht0+hANFCqHgSypfR1siVjsc9RXL3U043mUbgbE
         MrgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAW604NhqwnTacpmoOM2vf6miz3AP5NT03mZ6CrCCP0oql+YRKl3
	cpsfbsPRJ5JpP73jdwFuwJE6oJZLdMoD9UGQk9qqKMyvjg+1e4nziFx6mWxi/LkFr2BuEWWdoze
	lU7uj7BAS5Fm8VkiN/TtW6w6lUoQWWY4+GeAlC3PR/oWDQyoKnEyBV9BneTqfmH6ViQ==
X-Received: by 2002:a50:fb86:: with SMTP id e6mr38741992edq.203.1561390441780;
        Mon, 24 Jun 2019 08:34:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKXETW2zdY9dqicjep+S6QfwtlNlMC+KeJ2mVJb+mu1CMuZYtkSYgtn/Jm7Owpaux0pJrS
X-Received: by 2002:a50:fb86:: with SMTP id e6mr38741912edq.203.1561390441077;
        Mon, 24 Jun 2019 08:34:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561390441; cv=none;
        d=google.com; s=arc-20160816;
        b=p2Z0zm26yIxGDpxpaRs6hiikB25Hm3RYtQiUGFIewLLiaij37Ydr1ICHquDJFYXtEz
         2yJku0a/92w1dSgKF4+1RXP97m/sIpOAcf8dVF9YG9eEIiGN+LkL64qk19ll8i+nzgPj
         PNs+VnfvSQYb27W44p67KuEdBztyeeQmczqVyMpWBlb5W8ZzDQ7QIgPq2K21VTbCOxEi
         3C6uyx3+a6gKTs7QyV1MyNyAFB/zUmZ96+moLfgDgJ3uld/QPyacRwELsHVx5avQiLLc
         QNoJIscXRLP2xWo4mXDxq7gnPu44T5ZFxjGNVd73ry4boig+t984ed8cG4Jp5pfQTl8/
         xt5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PO9YeLkB1SMJb/jJHsI3pjVR6cVpXVnKzrwy5nsh+Ss=;
        b=sRFeVDqFt9wlY9Av96VVTLzbVTMmio7EeDTJxT/jluYrD0TMmkYb5m3un60sXjvwtb
         dX1kPUMgcBMJGetaN5Fy7ktjQlQfkvWmaJziB0Y0xa2lYyYNToBqW5qxtMS3f3BLO7jK
         trMSk2BPczoasLFRSi5gnCow1mbodRgi6aHM6NY55uoHCnHMPSTzdgXa73K/qBQeo3Xz
         KceaYjIR/DwhC2VjR96kRlLZuagCVA8Bnz/riJCkAsYj1F4Mo//9IzT4CBNSobE1nLRA
         Fc6Rdyt5R04iLCSAx220TPCTxQD8aEr0uTMxwdv+kL7fPhhnPsxT0Bi28AmkbmWXQUIv
         k+FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot29si6889693ejb.111.2019.06.24.08.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 08:34:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CB7C9ACAC;
	Mon, 24 Jun 2019 15:33:59 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 408D11E2F23; Mon, 24 Jun 2019 17:33:58 +0200 (CEST)
Date: Mon, 24 Jun 2019 17:33:58 +0200
From: Jan Kara <jack@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
	ard.biesheuvel@linaro.org, josef@toxicpanda.com, clm@fb.com,
	adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
	dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
	reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
	devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
	linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/7] vfs: flush and wait for io when setting the
 immutable flag via SETFLAGS
Message-ID: <20190624153358.GH32376@quack2.suse.cz>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <156116142734.1664939.5074567130774423066.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156116142734.1664939.5074567130774423066.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 16:57:07, Darrick J. Wong wrote:
> +/*
> + * Flush file data before changing attributes.  Caller must hold any locks
> + * required to prevent further writes to this file until we're done setting
> + * flags.
> + */
> +static inline int inode_flush_data(struct inode *inode)
> +{
> +	inode_dio_wait(inode);
> +	return filemap_write_and_wait(inode->i_mapping);
> +}

BTW, how about calling this function inode_drain_writes() instead? The
'flush_data' part is more a detail of implementation of write draining than
what we need to do to set immutable flag.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

