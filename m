Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6D0C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B3CD20828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B3CD20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57FAE6B000D; Thu, 29 Aug 2019 09:10:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DC8A6B0266; Thu, 29 Aug 2019 09:10:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40D36B000C; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id C362F6B0010
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 68232181AC9B6
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:42 +0000 (UTC)
X-FDA: 75875499924.30.beast06_23369e8c2f83b
X-HE-Tag: beast06_23369e8c2f83b
X-Filterd-Recvd-Size: 1861
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4DB86AF18;
	Thu, 29 Aug 2019 13:10:40 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B8F471E3BE6; Thu, 29 Aug 2019 15:10:39 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-xfs@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	Amir Goldstein <amir73il@gmail.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	<linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>
Subject: [PATCH 0/3 v2] xfs: Fix races between readahead and hole punching
Date: Thu, 29 Aug 2019 15:10:31 +0200
Message-Id: <20190829131034.10563-1-jack@suse.cz>
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

Changes since v1 (posted at [2]):
* Added reviewed-by tags
* Fixed indentation in xfs_file_fadvise()
* Improved comment and readibility of xfs_file_fadvise()

								Honza

[1] https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
[2] https://lore.kernel.org/linux-fsdevel/20190711140012.1671-1-jack@suse.cz/

