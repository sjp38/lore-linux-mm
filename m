Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54DF3C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:52:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 013BB20644
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:52:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 013BB20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67A406B0005; Thu, 20 Jun 2019 17:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629B28E0002; Thu, 20 Jun 2019 17:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518598E0001; Thu, 20 Jun 2019 17:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05DA46B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:52:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so6099227eda.9
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LOeX0nZdu7UVG6L3/v8vxAROb/YLs1jrHm5LlIuMuVk=;
        b=EK6YEugryaAkHTIFt2YvaZhsJyMNBMsVlSnwqOX7H77qJ999qhtkk0RRIcC4orer8w
         LM982JEkDL2SrRNoUv8lfVBhHptFX8AKP21pQ55cqJrue7lTfohfGRIMOm+dtxqRDWw3
         vkyC5xtMIa/th5FzZUvZtE3HcP2AfMU+PKblQczruaxcxR5MgdzsoPAQO5apxsy7vqcB
         wr0+fkwCZq/9Lqp5SH3+6adVacRDI+FrHjtBatbPAcbhycaDo+7S798r6LIvSWC9USHN
         s18N+CL38b8npllJ66Pv55X/BSGk0xM/cb21EYo6u2Pms/j4TAPz1Dw/W6HuW1HDoyRf
         OoQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAU4NULFueRHq6+VRlJaslRlJK3KgiKx9FL0eu9hQex5HMSk6SIN
	Mj1BpbYWIcQtVEYBjnjL4i9ducls61lvFltS4IFqP2FtzOwEzUR5haw04wNWptcJNkflcOLwJDh
	TPbasjv3cR9Dbj5dmnq0bbFNuI5GdxC4ZL3RirEb05Du3UTiZeP+voRJakaFkPxMrUQ==
X-Received: by 2002:a50:b107:: with SMTP id k7mr90278739edd.193.1561067550418;
        Thu, 20 Jun 2019 14:52:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzTCGjFs+T7EdH6GVv4KVSOqYRH5+7ZcHnPe12G7VT+jm6FXKZIAFlJBGPI25hus8kAZci
X-Received: by 2002:a50:b107:: with SMTP id k7mr90278691edd.193.1561067549708;
        Thu, 20 Jun 2019 14:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561067549; cv=none;
        d=google.com; s=arc-20160816;
        b=0ioEe72Av0IDTB4mKqxNNwbCriNFr9qSOdcUazMIt3deDNGU6EIlbjcJ6C6TQH2/Pn
         mFe0BFH+EPr+wGntTA+jgxJRjiQzm3Ldm6x5nqb/b/f2qoJffZczliLAr1/CVUX0YFkZ
         Tr+jwj8ODO7/LzEpay8fD/hSx+oMTxZ0+ZsInJhLj8Q7hBV5lc7C4MCstCJUrS3Zn3uV
         jkFjxASS2zDQYhfnZ4+PeKHyQTm0gUAtBsuQSHurGFBBryqbEazIdQQlle3xRuW/9nvE
         +8ISJewmYBu7zTwmau1azxFNnForZEK5OjoFC8HszjA0qmWafpVSYRS9BkP96Fy8IG/w
         lnhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=LOeX0nZdu7UVG6L3/v8vxAROb/YLs1jrHm5LlIuMuVk=;
        b=GhJvmlK+D1g0Kcf8Y40/rx/0EkR+xGl/AgefP77lLe5fcQIa7johBsTBVhDaQ8xCsj
         +M9mEZOWG6RPvbWOn4nv43VkgsoVmV1wqZY1y4R0hLLruaSb+2B92Q8yNaqVFvIcH9gj
         fu59A6FKaIOAUTLwApSeKHutTgKTe06t260CQ9IesO7JPWmrJoTOIo74XWonHfjifZWU
         IQwGmudZM+qY7imccQO6AK9EAn0YcELe4iW+M8J4y5Y4y9zk6KDqkELzGhg+TkP+dYxu
         nUBTMGf1tW8kiWNc+v1rl5g8oPRLyzM3VGKFvqZKZnSFREdV7xWEgvEtmrHvjorJNY8I
         uulw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id q18si579759ejp.169.2019.06.20.14.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5KLqDCc014930
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 17:52:14 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id EC0F4420484; Thu, 20 Jun 2019 17:52:12 -0400 (EDT)
Date: Thu, 20 Jun 2019 17:52:12 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, clm@fb.com, adilger.kernel@dilger.ca,
        viro@zeniv.linux.org.uk, jack@suse.com, dsterba@suse.com,
        jaegeuk@kernel.org, jk@ozlabs.org, reiserfs-devel@vger.kernel.org,
        linux-efi@vger.kernel.org, devel@lists.orangefs.org,
        linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-nilfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        ocfs2-devel@oss.oracle.com, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 1/6] mm/fs: don't allow writes to immutable files
Message-ID: <20190620215212.GG4650@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	matthew.garrett@nebula.com, yuchao0@huawei.com,
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
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
 <156022837711.3227213.11787906519006016743.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156022837711.3227213.11787906519006016743.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 09:46:17PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Once the flag is set, it is enforced for quite a few file operations,
> such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
> don't check for immutability when doing a write(), a PROT_WRITE mmap(),
> a truncate(), or a write to a previously established mmap.
> 
> If a program has an open write fd to a file that the administrator
> subsequently marks immutable, the program still can change the file
> contents.  Weird!
> 
> The ability to write to an immutable file does not follow the manpage
> promise that immutable files cannot be modified.  Worse yet it's
> inconsistent with the behavior of other syscalls which don't allow
> modifications of immutable files.
> 
> Therefore, add the necessary checks to make the write, mmap, and
> truncate behavior consistent with what the manpage says and consistent
> with other syscalls on filesystems which support IMMUTABLE.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

I note that this patch doesn't allow writes to swap files.  So Amir's
generic/554 test will still fail for those file systems that don't use
copy_file_range.

I'm indifferent as to whether you add a new patch, or include that
change in this patch, but perhaps we should fix this while we're
making changes in these code paths?

				- Ted

