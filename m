Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5B47C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FC0F2080C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 12:33:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FC0F2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 201396B0006; Tue, 30 Apr 2019 08:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B4156B0008; Tue, 30 Apr 2019 08:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A28B6B000A; Tue, 30 Apr 2019 08:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D32386B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:33:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m9so8940823pge.7
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:33:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=ak1BA6uJ5Taf2FM9MeR2kQJ+eKMQxI9D9CjD/mLQV1s=;
        b=axjm+h7JqyrXN/wVjiOOwWRLP4JR08D14ybub9xj2JXLTMeuCBu7su0UgTS6zCY1Xv
         DlHwYDoeT8eLRRwdwO/8z4uCi63+RMfgnYJo7TOm5zXpTa//WpHjDuZoQAn07Braie3/
         ocAEwUYcMMvD2Dna7z53sI8i1nU62NVariBsgeWsonl7P/7NYob68DKhCoy9f8X8VXk1
         mTcoB+x0wffdtYHmaT21iIEds5SyIuz+XQUKRA/Qh8kALsNXFde+ddP4HfdGfzoUOSbj
         7u2t1BZfxh2uQy3qPHt2b4bZfp88kWhQK2MfHQii/BaoJFKG+4r+wi+w9oeOjFZYTj0Y
         sVyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAV/lQ1Yc4IxY58VH5kfgU5ibZNNbCGWNLRY1+Ce1tHm5bibevx4
	Lpky+GASG/+nPGwh/J4C892lnVYWgWesSJFxhvXt6DzyAcqS5EApxkAsyXiP1fwSXL2bvPldcof
	2T55bnwCc1+oPRX4n+ZRXCpGQSaZLAf4g24s0v0CKf5yf+NvVIzcnPKzP0DgqRWHpJQ==
X-Received: by 2002:a65:608d:: with SMTP id t13mr41372491pgu.406.1556627614556;
        Tue, 30 Apr 2019 05:33:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzODVNlFxukXp1A04Gd6AYeHUwIWzXevKsNJXPQAfkRgk7eU2cj9PQ6b7e61VNXuBnUTApK
X-Received: by 2002:a65:608d:: with SMTP id t13mr41372401pgu.406.1556627613763;
        Tue, 30 Apr 2019 05:33:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556627613; cv=none;
        d=google.com; s=arc-20160816;
        b=qAIXEk/P2YrNWzDpBc2lkGAEmNHtiFK9y9jpmTTcEGHjHZQL/fn1/IeiO+MAbuKg4P
         PWbq/Il8VtZpGzYKZy8D3qVYyn4/0H5apWKQvE8rL1kusTZTUzkhqR4VIQkt3UmZFoQi
         iAhwR8ablUmu/GMcbSAo4i1FPTVTcYVfkoIF8DjYmMzcrUP8XoAeTjnAp7BQpRn/qNjC
         S2KDSb70u1VKpS9ys/g4jgEGZQ9f2I1lSGFoMvbKAmcHYaxZlOiihm5uW4tVGrtKtv4j
         eGSLTk2ma+wk+nBC9WzOOBa8uocxVPh5wXSsjoIMRLSnamnFd3lo4nNUqUzvJxJz7ORV
         Tx2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=ak1BA6uJ5Taf2FM9MeR2kQJ+eKMQxI9D9CjD/mLQV1s=;
        b=vCSXl2rODw+jQOfhJ+8XdubivpujSSXtGwbxrrQDVxqgQ76mH4MlR3+RgkyuvlIdly
         AMhYwrkIqzOV7eccMUEcpxjAmZ1D3uthaHkZR+Glcnbs4fGN3uQm40BQGwE6YFAqeXYx
         Uew/nX5D9T27dIyHxu2RY2wVCYrA9hSwxIueJL3bfdegNyjzhKuzLJt4/pyL8OeBOPB1
         QHIgfkHJ7OxYuuW1sNqYMs66VBCqPUTtKrYabyVKs9fooRXpeEZww93CcY4h1lWKrBMY
         VdLoO8pS7lhpgoYuaW284K7oFgl4kvCZkGhP+JfVPbHBPGvWoFzTu6/PfDKgT/Nnm2Vb
         a9Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id y1si9335739pli.411.2019.04.30.05.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 05:33:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id BE7799AF;
	Tue, 30 Apr 2019 12:33:31 +0000 (UTC)
Date: Tue, 30 Apr 2019 06:33:28 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Randy Dunlap
 <rdunlap@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] docs/vm: add documentation of memory models
Message-ID: <20190430063328.41ceca5f@lwn.net>
In-Reply-To: <1556453863-16575-1-git-send-email-rppt@linux.ibm.com>
References: <1556453863-16575-1-git-send-email-rppt@linux.ibm.com>
Organization: LWN.net
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Apr 2019 15:17:43 +0300
Mike Rapoport <rppt@linux.ibm.com> wrote:

> Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> maintain pfn <-> struct page correspondence.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

I've applied this, thanks.

jon

