Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8098C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:37:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CDCD20663
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:37:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZpriNPni"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CDCD20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EA356B0006; Tue, 25 Jun 2019 06:37:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C108E0003; Tue, 25 Jun 2019 06:37:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B1BA8E0002; Tue, 25 Jun 2019 06:37:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D98D96B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:37:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k19so11057121pgl.0
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:37:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1VNqATdiMZjRjBl/SX9aDfK/cY5ROrczskzh7bEhyqQ=;
        b=tetGbVv0T5LBbrONw3yvhjuhePkgiOo9vS9R4t/5PAQnnuOtbZ9w8PmUgCXoPNg6ig
         4gz1Q8N/SJ6/Les9QZ9JA6t7bv+EVjAZ9+sBMCcZLPKfFZHCOmN+6mEmwgR3c3ByCV65
         HzBrnP8gC4oYrpMTr2P+S4R77ur43SwObOVPCbAW1Bk4foLjlkq0rHrFB3BxCWt8czDJ
         KigsKm2XonLg/9zrLo+8EPXM/XmvVh8ZM8yHPtbNdy59GIboQqkY/dtHuJnhJPrH9yE4
         fBPpV/tzbzItQZPVm7RCfxn+P+3+Vj74O4eiKtusNeS7tKtZk7ZRG1pyGUK57IcnTVB5
         3blg==
X-Gm-Message-State: APjAAAVEFcGj6uNVcc8YviKJR/LOFeNWXVyQD/0yMrCdiZDPFswfombF
	tY8IL46rKzhBkQu7KPMyJFUNTaiQ4b0HuCiRhC7+BhnWl3S2BGDMiFlixODm2+Riujm1TR3ZxV2
	gclHO2mIwXjK+0PNfvfmxVGAJXYUudXmNgvFeUjwMVRSzYt+Y6la3NqpvxRXnCQVqQA==
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr31192881pjn.95.1561459066501;
        Tue, 25 Jun 2019 03:37:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6TgOhfygh2XufBIuUyCAPZI0SKOrETQ/s9yiaCUm0BGPGYd/yORSNKfsD6iPaDYey7FD1
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr31192804pjn.95.1561459065848;
        Tue, 25 Jun 2019 03:37:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561459065; cv=none;
        d=google.com; s=arc-20160816;
        b=u5mPhS+uRknvHCblpvTcd+oIx5IW/QWW5IrnxUTIrTnf9GaN047WqT5J/uAIhcxYUD
         qSCgK4yBauDsbsOOKaJ4tyIkx+JBtXrlVL0PJS0TH0dpnKRVqYWvDhnIF1Vq3hEn7FWB
         rCXFpjAWcneMY7yUdDZn+gav8b0gmsUxzNX5iqL9iM1c4jD7K8AHYV6nNdU022fP0Dpe
         supy4BKNJT1FTF1JgHZLWmshK3ubgYVt4/XylOAEZgQquMPKbBCyGf1TaCUyvVrGLx7F
         PZSsSIJj7CDbkvpjaN1XcJCFqQXlpAwwOKGEL9B+6KkBbaBL9bZ0SG71fAmk1wYzuJGV
         Vg5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1VNqATdiMZjRjBl/SX9aDfK/cY5ROrczskzh7bEhyqQ=;
        b=07TVh8HemUPS29y1eBOgwy/5hjqah6hJ2eWZQIpmePl2CkdFkmfThLMqua2ehCA+Wn
         CSNzHBNxZkTOTgvIex8T3WdsEDaJbO5UTZmA59cRdbLkc+Xc782HAi91cO3WgD6jl4bk
         WsTIKpMSh1EuQKXiZcFB7qINsKhyMwj3x43+DsUp1xvOx6qfxTZRXizMuL+qleikSvD6
         iYWtkKPNa4cUp2iD5oamavgZeYSA13jYw8mu3w+sZcs8mXG+puZ2alJLBefXNblsdZWz
         xxPDdWZRhLWjn5n+dBVMLGpD1R7hBVqZ6fR1kLnnA5OgGeEyHwnbofQ2dePAxtr6NJBH
         edyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZpriNPni;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d6si12678581pgv.132.2019.06.25.03.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 03:37:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZpriNPni;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=1VNqATdiMZjRjBl/SX9aDfK/cY5ROrczskzh7bEhyqQ=; b=ZpriNPniMtQfF3PzrXrZFLu9+
	swp27pwzGA3dKtOql8ByZMlmC5XAUIK6Dd+GMHjf0qKANtiVkMY+kP24emwMCRR8Bd7PMgTyLe9QA
	5OqMw/nvM9U3sRjirT+3roDKm/2t058rf3DiyN7fkLSlwMZ0SYle68bvh+fdV+mCDEdE0F8PxUYpO
	6uADPC1wdetL3m6crno/ECGMbIBw4GF5RRX2ugGr6ltI3bjWVADicfMYipFtp/ocudq1CWBwDRZB8
	y8f1S9n0qHQVZzv6yurSepPmJiIiCIwpzAKGBbc00350emRHfZhiQtGnClIv9oYZsJs4CbEdnWkcx
	MCg3FRwHw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hfioR-0001Ln-BN; Tue, 25 Jun 2019 10:36:31 +0000
Date: Tue, 25 Jun 2019 03:36:31 -0700
From: Christoph Hellwig <hch@infradead.org>
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
Subject: Re: [PATCH v4 0/7] vfs: make immutable files actually immutable
Message-ID: <20190625103631.GB30156@infradead.org>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 04:56:50PM -0700, Darrick J. Wong wrote:
> Hi all,
> 
> The chattr(1) manpage has this to say about the immutable bit that
> system administrators can set on files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Given the clause about how the file 'cannot be modified', it is
> surprising that programs holding writable file descriptors can continue
> to write to and truncate files after the immutable flag has been set,
> but they cannot call other things such as utimes, fallocate, unlink,
> link, setxattr, or reflink.

I still think living code beats documentation.  And as far as I can
tell the immutable bit never behaved as documented or implemented
in this series on Linux, and it originated on Linux.

If you want  hard cut off style immutable flag it should really be a
new API, but I don't really see the point.  It isn't like the usual
workload is to set the flag on a file actively in use.

