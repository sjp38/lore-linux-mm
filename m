Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC46C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F96E20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F96E20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD2D38E00C2; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E6D98E0032; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C47E8E00C1; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32A718E00BF
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so4732601edd.22
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=tLcysXJkKcfrmLpC4SU90EbRf2nSP2ysndLOE49Dgr8=;
        b=kRrKK6UPxzQT0ZVOeMjkRF/qfzysbfJvpMBkQ+spYnsk1X4BHAr/qu01Sk+/7hIbI/
         RVsKD8m6tojyQmwD4Zzxx9TQZ3x3b/QPB5PtzLmroxjyGTKm48wFYIbrH+PRa4oZIDWc
         jkcVxmTujXQ1WK5TjtSG8GvvgSZpQo9jXeUkBEzKEfSZRtf0W2kqGlCw/xhcIZCiRGli
         hzwNW/mhxDHGcYBgy9hQsklNCmyhcIaELNHlFQpPw9Uj+c+MOO7/Lw2SMKdScD2eHZL9
         nO9pn5FAldU97CpmXZ9ghOvzNRq6qT0ml4mMo+cg4gs3ausNfaG9cbPLCFRqCM4VGNhz
         RMUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWnGVtESPJPwhfaZwzQh5RsSL/h3ZuyNNLGvCkAmlIrLYl6Nb57
	DquKAhO+QaGBwbeZ8IFyE2TFCffkxpSZGzWG9xdoUDl5D/WOydw43gEKSFTDvMe/4O/XKqlwZc+
	THzaP4A9116qF+8wy+efhJQv5Ft4f19BXtHxbVyzARyElRsw6kXb+ubJJmgJM435uJA==
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr3588058edm.89.1562853619791;
        Thu, 11 Jul 2019 07:00:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbr/tjhdIRvC1GnqRmPQz1RVe17BQNXQHnsl0KNP0GZ3pFBfc1ePlsvTKE69gAslqGqsPT
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr3587792edm.89.1562853617674;
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562853617; cv=none;
        d=google.com; s=arc-20160816;
        b=m8qAeyVtDxs0EiTYQ5NJiU5PXuMU9neNYeuRAsFE7aBdxqtN19IBofOo0cEa5pdUvb
         hK2ntcvdPXbNbJjg/1PWlOeSmPWPrlIYi4R0yjFbI+4ZNSWAm0AM+ORhgZ5LGmumPd0N
         +Ekc+Q/JrGZ1mOKcksOjZYtmccHIltBHa5cOY+F1Fkur4iBviDg/FYUL+anJjqgiC850
         BEaKxNx9K1uaWa97VFX2YyaoiidW+IInMRhRv4CF6u2nQwgRbIT5vlUbJAWCDKhF7FfA
         0RpruxmqWAkoeO3Toa9YrXFYLL/gx5hVdNy+b/1XyA2bvmROuRENJHMT4zQ5WogIU5eO
         oYwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=tLcysXJkKcfrmLpC4SU90EbRf2nSP2ysndLOE49Dgr8=;
        b=tzPYU3AXC32yNyy/7/FeX4TxgDMsvrgXYmJqUWxwmsS6V4yPofcaU6Dl3DKMeGdTUg
         /u1SSgjGt++aWpN/btsFcAUfxK4IfcGOy61Z66PPqAkTdBGhGIN6M5u28Jyir3/QgBZc
         cU6nbEviIytp8tbOpIfnNI7a2k4ql5jpdPQe7NUUPsATFUwBPP2yqf4iuh6c2pPrT8rP
         BTN5B3IJ9bmM3ZtIGTYPoTzjoS24FsjV6B/0ShOdfo+HKRDIWLFUuj2wwiGdeY4VvYQX
         yLjj9pIFEm5/L+PoydvnUP89zuqDRvknutKKsevJMkH0lVyYiRImG9vDRLqzq6r82njJ
         tsTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o21si3137581eja.9.2019.07.11.07.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3AC4AF5B;
	Thu, 11 Jul 2019 14:00:16 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 24D661E43CB; Thu, 11 Jul 2019 16:00:16 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	<linux-xfs@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Jan Kara <jack@suse.cz>
Subject: [PATCH 0/3] xfs: Fix races between readahead and hole punching
Date: Thu, 11 Jul 2019 16:00:09 +0200
Message-Id: <20190711140012.1671-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

this is a patch series that addresses a possible race between readahead and
hole punching Amir has discovered [1]. The first patch makes madvise(2) to
handle readahead requests through fadvise infrastructure, the third patch
then adds necessary locking to XFS to protect against the race. Note that
other filesystems need similar protections but e.g. in case of ext4 it isn't
so simple without seriously regressing mixed rw workload performance so
I'm pushing just xfs fix at this moment which is simple.

								Honza

[1] https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/

