Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E29ABC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 05:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E33B2070B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 05:52:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TW406TlW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E33B2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E72C6B0010; Thu,  6 Jun 2019 01:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BEE76B0266; Thu,  6 Jun 2019 01:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEF416B0269; Thu,  6 Jun 2019 01:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB2B36B0010
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 01:52:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id v205so1041906ywb.11
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 22:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=Gp2g3b03DgFtDGUPs5KjcyAYE0tK8DWBS3G4Sguhlos=;
        b=P2CgGUBpwtSjBrpwvqTS9ZpLIPT8W9acfOEe1smLNR330hUOyqx5GFfWsozC+/nyIh
         rI7MRUccyCHMwghfQwnLCS8dEQ5drOMguOxfWKzEv27luiqdBc9tUg0qAPpQp1/xX2Xt
         DqjTbxK3KGg9iygufqcchrTRoTFSKe4gpcn05A4MUmu48tTAchKJ6HkUG66FQHHTuC0A
         SwarQ5tyei5PgaMC3COWbT8RtfqU0R2c8qNyEU/VNfe2YcTPc0XsyAvqar7oixk4OKIW
         pMGzPlz2mqXAxXSiOWFPJjnF+qmKZeFuN24wMzRMKvJcPECPpL0dvOtGU9H4ympDMZ6p
         z24Q==
X-Gm-Message-State: APjAAAVcz9nhB+gZ1AeLeKIUPU/gxBZE9qGRxjdceUZc8ZP8X9kBYfOl
	b+l1VomJP14mZatqkARkmOzFTZZq8kTJ9eXnTJaphwmyCe5ek4i5DNWuKfEdBULI2T9tLczyupx
	gSmKtUJdAXiHoxe4maCEMdvGnBFW1ki6mD6DBXtObWfenZzfDCkC5cGmio/eR80FofQ==
X-Received: by 2002:a0d:edc5:: with SMTP id w188mr22762977ywe.17.1559800335510;
        Wed, 05 Jun 2019 22:52:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxg/Wt6s/6yhohAK81mbuWo4bIde5DdidKBgNeZXwu82MBYL/8nxDLq3KhwB+0LE5+0xkm8
X-Received: by 2002:a0d:edc5:: with SMTP id w188mr22762948ywe.17.1559800334497;
        Wed, 05 Jun 2019 22:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559800334; cv=none;
        d=google.com; s=arc-20160816;
        b=zS0r6lq0XprE1lxcEiEscgzQD+TUeEz6qkPB8QlkaUY4TdTqVFUFIPgNmMhAAYwK7/
         pwPQ/lWgyfHjcrtkSw20ko0qptvjAyjyr+XJyhLiPdJtIlZxXS3PwpwxhR/ZaxStJ7Cb
         51rVtlE0eCjf9TAhrDviAIPv3o/L0jzFKpaGpl1Mxz1otpn0BmJi8kZMX1a/aiXvLAg5
         OM27FKYL6plj9QrFMWvO8FzFVu4OPp8ZdH9/xweHsRz4elAzllXBFVnxIcKyT9AmoeIA
         bWW/ZjovPWIbGNl0p7CuSwDkx8SdPLbzTgTbnUL88XGQ7+8pT7Ooh0bIZxzwFqp23ZBa
         zcyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=Gp2g3b03DgFtDGUPs5KjcyAYE0tK8DWBS3G4Sguhlos=;
        b=vrjI+7Gt89xXl4zGFXTaFwflpIYAK9LSh5t5VXb/mkcxnMo++vUoRxFH4y9qU9UZKc
         J8PuDZEmxOv/8Qa11oNuow+SROCMP+VP0eukl6F+4F6aFcNYEc6kfTak2LhUa6nIDKys
         0m+7GD9kWFC/Z9JIJVstgrGgmpdKp1cDIP3QvxoYCgdckoFEF2cbcKEjaS6UhNTU5s5R
         f6y21FQaw5l5whVcRd1rnlHfoL4fi818RoerVZhxHdakiCK85tLDWyhImbnqIQcK4ZVH
         0C+AdJSHvO1TG1R5CBjpZ7OlhEeUPDFKtYA6rJnLy+asjYkjw3CvQzVU9AHMx484y2on
         mRzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TW406TlW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p130si479018ywg.105.2019.06.05.22.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 22:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TW406TlW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf8aa0b0001>; Wed, 05 Jun 2019 22:52:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 05 Jun 2019 22:52:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 05 Jun 2019 22:52:13 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 6 Jun
 2019 05:52:12 +0000
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: <ira.weiny@intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara
	<jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Jeff Layton
	<jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>
CC: Matthew Wilcox <willy@infradead.org>, <linux-xfs@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, <linux-fsdevel@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190606014544.8339-1-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c559c2ce-50dc-d143-5741-fe3d21d0305c@nvidia.com>
Date: Wed, 5 Jun 2019 22:52:12 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559800331; bh=Gp2g3b03DgFtDGUPs5KjcyAYE0tK8DWBS3G4Sguhlos=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TW406TlWPfq1+txQJKeJk28J1JWSrmzZBUVeqHD3lW0hwmrqL+i5fmSoZOx4n4lWy
	 Hmav7hC+Dg2NnnU5/CKwGJdLiRg333XopPd8PNY/+OwsQjn4q9eA0uKBcQ18GF9GA7
	 bYorekfcWSMtASfx9atYR+4f1F8QwG+zlW9PqvxXVvqn3XJTcUDuvIUXPM8aJLM+s1
	 n0mI8czwPnoQSbO7wH92BWoJ5ljhc5QN8KOrfC7Etg4R98qDMovGb1D5yAPWIzIDso
	 ICscXJ9Im6L2nwKphSDu/r7hHPF3XN6orU2ooI7jJgoOKQuUSz25kWcKOJRt+HaqXq
	 PVtJjo3M2HZOA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/5/19 6:45 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> ... V1,000,000   ;-)
> 
> Pre-requisites:
> 	John Hubbard's put_user_pages() patch series.[1]
> 	Jan Kara's ext4_break_layouts() fixes[2]
> 
> Based on the feedback from LSFmm and the LWN article which resulted.  I've
> decided to take a slightly different tack on this problem.
> 
> The real issue is that there is no use case for a user to have RDMA pinn'ed
> memory which is then truncated.  So really any solution we present which:
> 
> A) Prevents file system corruption or data leaks
> ...and...
> B) Informs the user that they did something wrong
> 
> Should be an acceptable solution.
> 
> Because this is slightly new behavior.  And because this is gonig to be
> specific to DAX (because of the lack of a page cache) we have made the user
> "opt in" to this behavior.
> 
> The following patches implement the following solution.
> 
> 1) The user has to opt in to allowing GUP pins on a file with a layout lease
>    (now made visible).
> 2) GUP will fail (EPERM) if a layout lease is not taken
> 3) Any truncate or hole punch operation on a GUP'ed DAX page will fail.
> 4) The user has the option of holding the layout lease to receive a SIGIO for
>    notification to the original thread that another thread has tried to delete
>    their data.  Furthermore this indicates that if the user needs to GUP the
>    file again they will need to retake the Layout lease before doing so.
> 
> 
> NOTE: If the user releases the layout lease or if it has been broken by another
> operation further GUP operations on the file will fail without re-taking the
> lease.  This means that if a user would like to register pieces of a file and
> continue to register other pieces later they would be advised to keep the
> layout lease, get a SIGIO notification, and retake the lease.
> 
> NOTE2: Truncation of pages which are not actively pinned will succeed.  Similar
> to accessing an mmap to this area GUP pins of that memory may fail.
> 

Hi Ira,

Wow, great to see this. This looks like basically the right behavior, IMHO.

1. We'll need man page additions, to explain it. In fact, even after a quick first
pass through, I'm vague on two points:

a) I'm not sure how this actually provides "opt-in to new behavior", because I 
don't see any CONFIG_* or boot time choices, and it looks like the new behavior 
just is there. That is, if user space doesn't set F_LAYOUT on a range, 
GUP FOLL_LONGTERM will now fail, which is new behavior. (Did I get that right?)

b) Truncate and hole punch behavior, with and without user space having a SIGIO
handler. (I'm sure this is obvious after another look through, but it might go
nicely in a man page.)

2. It *seems* like ext4, xfs are taken care of here, not just for the DAX case,
but for general RDMA on them? Or is there more that must be done?

3. Christophe Hellwig's unified gup patchset wreaks havoc in gup.c, and will
conflict violently, as I'm sure you noticed. :)


thanks,
-- 
John Hubbard
NVIDIA

> 
> A general overview follows for background.
> 
> It should be noted that one solution for this problem is to use RDMA's On
> Demand Paging (ODP).  There are 2 big reasons this may not work.
> 
> 	1) The hardware being used for RDMA may not support ODP
> 	2) ODP may be detrimental to the over all network (cluster or cloud)
> 	   performance
> 
> Therefore, in order to support RDMA to File system pages without On Demand
> Paging (ODP) a number of things need to be done.
> 
> 1) GUP "longterm" users need to inform the other subsystems that they have
>    taken a pin on a page which may remain pinned for a very "long time".[3]
> 
> 2) Any page which is "controlled" by a file system needs to have special
>    handling.  The details of the handling depends on if the page is page cache
>    fronted or not.
> 
>    2a) A page cache fronted page which has been pinned by GUP long term can use a
>    bounce buffer to allow the file system to write back snap shots of the page.
>    This is handled by the FS recognizing the GUP long term pin and making a copy
>    of the page to be written back.
> 	NOTE: this patch set does not address this path.
> 
>    2b) A FS "controlled" page which is not page cache fronted is either easier
>    to deal with or harder depending on the operation the filesystem is trying
>    to do.
> 
> 	2ba) [Hard case] If the FS operation _is_ a truncate or hole punch the
> 	FS can no longer use the pages in question until the pin has been
> 	removed.  This patch set presents a solution to this by introducing
> 	some reasonable restrictions on user space applications.
> 
> 	2bb) [Easy case] If the FS operation is _not_ a truncate or hole punch
> 	then there is nothing which need be done.  Data is Read or Written
> 	directly to the page.  This is an easy case which would currently work
> 	if not for GUP long term pins being disabled.  Therefore this patch set
> 	need not change access to the file data but does allow for GUP pins
> 	after 2ba above is dealt with.
> 
> 
> This patch series and presents a solution for problem 2ba)
> 
> [1] https://github.com/johnhubbard/linux/tree/gup_dma_core
> 
> [2] ext4/dev branch:
> 
> - https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/log/?h=dev
> 
> 	Specific patches:
> 
> 	[2a] ext4: wait for outstanding dio during truncate in nojournal mode
> 
> 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=82a25b027ca48d7ef197295846b352345853dfa8
> 
> 	[2b] ext4: do not delete unlinked inode from orphan list on failed truncate
> 
> 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=ee0ed02ca93ef1ecf8963ad96638795d55af2c14
> 
> 	[2c] ext4: gracefully handle ext4_break_layouts() failure during truncate
> 
> 	- https://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git/commit/?h=dev&id=b9c1c26739ec2d4b4fb70207a0a9ad6747e43f4c
> 
> [3] The definition of long time is debatable but it has been established
> that RDMAs use of pages, minutes or hours after the pin is the extreme case
> which makes this problem most severe.
> 
> 
> Ira Weiny (10):
>   fs/locks: Add trace_leases_conflict
>   fs/locks: Export F_LAYOUT lease to user space
>   mm/gup: Pass flags down to __gup_device_huge* calls
>   mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
>   fs/ext4: Teach ext4 to break layout leases
>   fs/ext4: Teach dax_layout_busy_page() to operate on a sub-range
>   fs/ext4: Fail truncate if pages are GUP pinned
>   fs/xfs: Teach xfs to use new dax_layout_busy_page()
>   fs/xfs: Fail truncate if pages are GUP pinned
>   mm/gup: Remove FOLL_LONGTERM DAX exclusion
> 
>  fs/Kconfig                       |   1 +
>  fs/dax.c                         |  38 ++++++---
>  fs/ext4/ext4.h                   |   2 +-
>  fs/ext4/extents.c                |   6 +-
>  fs/ext4/inode.c                  |  26 +++++--
>  fs/locks.c                       |  97 ++++++++++++++++++++---
>  fs/xfs/xfs_file.c                |  24 ++++--
>  fs/xfs/xfs_inode.h               |   5 +-
>  fs/xfs/xfs_ioctl.c               |  15 +++-
>  fs/xfs/xfs_iops.c                |  14 +++-
>  fs/xfs/xfs_pnfs.c                |  14 ++--
>  include/linux/dax.h              |   9 ++-
>  include/linux/fs.h               |   2 +-
>  include/linux/mm.h               |   2 +
>  include/trace/events/filelock.h  |  35 +++++++++
>  include/uapi/asm-generic/fcntl.h |   3 +
>  mm/gup.c                         | 129 ++++++++++++-------------------
>  mm/huge_memory.c                 |  12 +++
>  18 files changed, 299 insertions(+), 135 deletions(-)
> 

