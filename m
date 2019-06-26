Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7E48C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B705B2082F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:53:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B705B2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D8D96B0003; Tue, 25 Jun 2019 23:53:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 362F28E0003; Tue, 25 Jun 2019 23:53:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22A508E0002; Tue, 25 Jun 2019 23:53:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C58236B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:53:21 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n8so399770wrx.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:53:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=kIclzzvbwh3gy97S4kcHDKI8qcoqoEowJ4LfFBdWgr0=;
        b=OyOKEjr3cULPFTMVQmImKUEosE4fxzl8O/6YDCV1JSxN+LbjrVk37+XxmJVbSUOAEt
         2etMz2SXYuZCA8mM9DPQTu8PKAayhbMGlH2CcnQCCCotEe4OQz4K2E9vNn0RGvf0QH9t
         j5V8L2oF+wA7MYq/uBPC3eRlv7A7rwPmAguuJdMhuYFo4PsLcoG6JTBB8du4nkI8fZYd
         BAI9EfWdYuNcGwEOBh2Y/Ef7tQFlisURRoXHeUgOVPCBzRBy2NkxORvhdqn35eBypiFb
         IiSeeV8MEjZZgIUSDMVdHfAbVRVgTkDftjDHSCwFZyIygQM4RPDVBg3HV0H8z5Tjzmfu
         OJKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAUGr316TOBw4MHHVP9V5HH97mD0hWu6NlL7mHX6vK34ZmqX+wOa
	gL5pLDvHCRdemfQP+mhsOTfPhTtfA7BMsl6yW3CEJKHZOMHL859Wvlv8aeUx9KkxVyinTKm6ZQy
	MqsPlIzEYuV+Os/paSMygWK8coN03mrnblN3LClrB4hTm+dCo3VJVkh8gvOUDgRhR5Q==
X-Received: by 2002:a1c:b757:: with SMTP id h84mr840910wmf.127.1561521201352;
        Tue, 25 Jun 2019 20:53:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM4qjDNIXZD+XBrO/gnXICi2vlDynqlQXwVDHp3f0OlJrsOkMMEy2P8SoyKQiEuSBHZM8r
X-Received: by 2002:a1c:b757:: with SMTP id h84mr840863wmf.127.1561521200657;
        Tue, 25 Jun 2019 20:53:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561521200; cv=none;
        d=google.com; s=arc-20160816;
        b=U8PTx5Tf1RDu/NKAyITN6b9i4auGnnhIhqmg6bgPaLWeZSu9MpIJAnP806LmBwp9rd
         fHUfaC2iBCddSQkOlbVvqOYBzq+T7QV45ZXbA1O/a/2Zd+8asxFbIzbKO8GQvG+W3Atz
         eI0ssrKSqTxObvCMZeLQ04d88bHLa6/EZftq6Ky10zqP5ooaCPV6DBfqrFAmoOEXb0VD
         mNxDdJpDqO208l9qDT2yytlnogAeCY3ZcW5IlT0j11JgXFyE534TrL2PciQ4awytzpJM
         xeUJRFReGPSSEUMUmbm+yTbjbMQvQiUQiDC/ElPq495SZHh6buosZwN0Gb8jUKi9rO2r
         pfvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=kIclzzvbwh3gy97S4kcHDKI8qcoqoEowJ4LfFBdWgr0=;
        b=RclClpZHgE3f7tPB2o0w4M7KV3X22YYjSzV5KKFyGceuaOaBz19xUyqu+LSDqmbvyh
         Xp6gVPb6YjAh2TkxzGdWFIEot6y0IJjnJH7NKgR2Sjxgaq1Ntg73RmYfLHC+fcMLt/nB
         V0rosD/5QGR3sTkYckpTfmZsBAtKKxznO7U3bDRAPdzwmMp91kUkLkOlOrJ1Tp2TNXoa
         m3pqsQlNclC2JyfULIDXmRX/gc6FJ0syhTKFtzITFhzPyWWiBZFHYis2DaRUrixJuc+f
         msPmUfrODiFhx1G0UNP6DQYWo+QmtPHCgNGFHYIZVLFCgqHXKxr2eELHhQapqC1t9ARo
         ZpFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 92si1943853wro.273.2019.06.25.20.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 20:53:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hfyyN-0008Mv-UN; Wed, 26 Jun 2019 03:51:52 +0000
Date: Wed, 26 Jun 2019 04:51:51 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
	ard.biesheuvel@linaro.org, josef@toxicpanda.com, hch@infradead.org,
	clm@fb.com, adilger.kernel@dilger.ca, jack@suse.com,
	dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org,
	reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
	devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
	linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 5/5] vfs: don't allow writes to swap files
Message-ID: <20190626035151.GA10613@ZenIV.linux.org.uk>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
 <156151641177.2283603.7806026378321236401.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156151641177.2283603.7806026378321236401.stgit@magnolia>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 07:33:31PM -0700, Darrick J. Wong wrote:
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -236,6 +236,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
>  	if (IS_IMMUTABLE(inode))
>  		return -EPERM;
>  
> +	if (IS_SWAPFILE(inode))
> +		return -ETXTBSY;
> +
>  	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
>  	    IS_APPEND(inode))
>  		return -EPERM;

Er...  So why exactly is e.g. chmod(2) forbidden for swapfiles?  Or touch(1),
for that matter...

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 596ac98051c5..1ca4ee8c2d60 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3165,6 +3165,19 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	if (error)
>  		goto bad_swap;
>  
> +	/*
> +	 * Flush any pending IO and dirty mappings before we start using this
> +	 * swap file.
> +	 */
> +	if (S_ISREG(inode->i_mode)) {
> +		inode->i_flags |= S_SWAPFILE;
> +		error = inode_drain_writes(inode);
> +		if (error) {
> +			inode->i_flags &= ~S_SWAPFILE;
> +			goto bad_swap;
> +		}
> +	}

Why are swap partitions any less worthy of protection?

