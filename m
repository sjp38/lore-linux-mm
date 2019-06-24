Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CD30C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:37:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E3C920665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:37:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E3C920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B47F8E0005; Mon, 24 Jun 2019 07:37:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9657A8E0002; Mon, 24 Jun 2019 07:37:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82CF88E0005; Mon, 24 Jun 2019 07:37:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 364518E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:37:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so20109528eda.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:37:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kC0tGTExToSY0TsjLIPhoVhUNCUhdd7MZXe46kxsGEA=;
        b=hP3yFVN8IqBggtchD6RenOSH9VT/0kNMxkYP8ylpx77u6pc/1iVvlHe7lSoJSML/8f
         7K9TngIkkGf75fwtZ0lPHldjLtt8cuP36dcAy8mvRDy7ShbxYKrVTYnuqmLCavZUJecI
         EfQvNV7EGOx60Wum7tl8j6PT2VdMcm1tBBXc+JRZI1vIoyRdtOfIZvEoP45vl7SinhyK
         SxsfM5h2katwnhuCgiGC7v7wN3rlXOjGFUMwpPDRpogiqs+lGDpkq90V58DXwyjWxWGG
         1HME8iLGcx1V2LaEMcyxfOMAEzKsYsNkgxtMPSTNDY69OTCXBW/123aMVPZwyH0IZOnZ
         arqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUSEGj6Wyb3InTTOtLHVMVIA0Bpa7cr3BmkwBuYdIX5cL1685Sq
	GFPhgnXSZSSQBMBOBdqtRFVmnCPdUALA5Fb8x/eZLZeblL2iU5KFRteyX5iph/M5yH2pY3bs+sO
	do08d/NCsUHzhul13YvGkOirqH8CjKil1XkmWP1AA6awSnP0R43WfXI2TEbcUUlvPZg==
X-Received: by 2002:a50:f7c1:: with SMTP id i1mr34691037edn.268.1561376261733;
        Mon, 24 Jun 2019 04:37:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8m5aZoq34RIAP70kCwPmveHXZrSdqEeYITYDt4stOAFT1gt11y9+tpaCDwTSaY8//cYz5
X-Received: by 2002:a50:f7c1:: with SMTP id i1mr34690976edn.268.1561376260921;
        Mon, 24 Jun 2019 04:37:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561376260; cv=none;
        d=google.com; s=arc-20160816;
        b=Tsp0Wd0LId6NqjmFCL4Wta6rC4sYcWP40MQLPNniTCCodzvrFF9g7t3YF5hJWunbI+
         afO8Mn2SQgSgXLauP39/tzJ1xCU29nhziHGAdJ7OurQDyedCS6gXF684zSI1sVDTdIQB
         oOz7wgovdasueDiRtjjl8wFn7EzmvzRhGHMAVho+KeZZ7OFcc7iysjkJ3FY5iUogq/6L
         JzPGBB8QncaaBV8SLgN+DRIeW8kYhDvf9eSc79ixDwFkKkesjc870Ab8aqEYyRC0qn15
         z7GD0jFlQBqV3Smm/r33TwKCCXOJqP82KgINSu5nf3tX53cRKU7HpEIxr9k3a1/hHEty
         BoTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kC0tGTExToSY0TsjLIPhoVhUNCUhdd7MZXe46kxsGEA=;
        b=It15MNjDm1oXuuzR0UknMhI8Nb/AGNfcQzSpPPb+cmrSQWKmGvh/XzTAmmhcXnLWnZ
         Nt7Sr86g9JCoo40ocMYfkEXGRP3I+vazoazwZ4o0TTrbp/MV9q3FgonKoJY6S2X7iGtW
         hdGW8ZQj93ya7LN0gpOoEaAg/bFTIayhDRcYWBJVpOOiq7QmVhQuHp1sAf1LrnwJdmUg
         DaDiwIjoDGVcKBMqbCx0DXATas79NFTeb/R9KO7lOAmeKETWz5XbipeqQoFqiT1JJfuL
         2Yah44lEW3b3xW5kB33M/AHMsTFr4b/X4rGVcFrDztf7XZBEWgxGN3tx57veq+Q4TrRi
         +zJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1si659752eju.246.2019.06.24.04.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 04:37:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0EF03AE79;
	Mon, 24 Jun 2019 11:37:40 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id DBCD31E2F23; Mon, 24 Jun 2019 13:37:37 +0200 (CEST)
Date: Mon, 24 Jun 2019 13:37:37 +0200
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
Message-ID: <20190624113737.GG32376@quack2.suse.cz>
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
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
> need to ensure that userspace can't continue to write the file after the
> file becomes immutable.  To make that happen, we have to flush all the
> dirty pagecache pages to disk to ensure that we can fail a page fault on
> a mmap'd region, wait for pending directio to complete, and hope the
> caller locked out any new writes by holding the inode lock.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Seeing the way this worked out, is there a reason to have separate
vfs_ioc_setflags_flush_data() instead of folding the functionality in
vfs_ioc_setflags_check() (possibly renaming it to
vfs_ioc_setflags_prepare() to indicate it does already some changes)? I
don't see any place that would need these two separated...

> +/*
> + * Flush all pending IO and dirty mappings before setting S_IMMUTABLE on an
> + * inode via FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
> + * returning error.
> + *
> + * Note: the caller should be holding i_mutex, or else be sure that
> + * they have exclusive access to the inode structure.
> + */
> +static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
> +{
> +	int ret;
> +
> +	if (!vfs_ioc_setflags_need_flush(inode, flags))
> +		return 0;
> +
> +	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
> +	ret = inode_flush_data(inode);
> +	if (ret)
> +		inode_set_flags(inode, 0, S_IMMUTABLE);
> +	return ret;
> +}

Also this sets S_IMMUTABLE whenever vfs_ioc_setflags_need_flush() returns
true. That is currently the right thing but seems like a landmine waiting
to trip? So I'd just drop the vfs_ioc_setflags_need_flush() abstraction to
make it clear what's going on.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

