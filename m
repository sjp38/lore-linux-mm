Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7596C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 00:54:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 940222075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 00:54:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 940222075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA686B0005; Thu, 20 Jun 2019 20:54:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B988E0002; Thu, 20 Jun 2019 20:54:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 242D38E0001; Thu, 20 Jun 2019 20:54:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0391D6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 20:54:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r40so6082741qtk.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:54:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6dAfEP10mYLzrMjbDQx3yrRDWC6z2OR5tbIbKtzt5Bg=;
        b=AC23hsJpfKrtuhKeiHvQflqqcgz0QcHcRFbsvuxPoY+Ysib5w4ZOxA5pvsxcThz1Im
         Kb8oJ63lAAl3P9zonllbz6qh3ugBPZvZCFQdq/8XrPglHHYmCOnlkAqP8SLGX9TjG6Pr
         cgXavTfBpcRk+yeCJzfYw7CmOL+vZGX4gDi29+QTQmTml4h19B08kuK62QXdCVF1kNJG
         W8jbVBXFzhS8MB1IMAwSufilSd2o4xLMST71qXUCh7zaBHO6aEDOHiHSYzgFn4kOs+LX
         dPM/0ZFUpND2ymWcmPMye6R0Ip0kAqz6J9GAdRUOgZ3D4TcByZVv9z0AkaS9p0aKswS9
         +0pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAXWu5tb8wHAtIf2bDNIJj5dJJOGBVIn70feYOsMiXQjARCwWDaH
	gzf1Yw/qfGVEQBBlgvgFLSDZ+HSLK10fXZ/jpJmhxxy3g5xIcM/HmRLoHx/oQ0iHTpoBxuvzM20
	NfcTmcTr79qKxfd6x91jxXwMgREgg6SL1m+NAtIk4i10wEd4aqJWtavdHYe2mbUKJGQ==
X-Received: by 2002:aed:24d9:: with SMTP id u25mr117339738qtc.111.1561078475806;
        Thu, 20 Jun 2019 17:54:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMluyhBL1+gsbgFm9G+7+AQNpQNtfidmg5AuyThnjOkMTxX9hKU/Ut7TsRIBbz2+JSe9qa
X-Received: by 2002:aed:24d9:: with SMTP id u25mr117339708qtc.111.1561078475133;
        Thu, 20 Jun 2019 17:54:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561078475; cv=none;
        d=google.com; s=arc-20160816;
        b=MlTIBMWkmChGoCXBJPhjD8OmogOn4WfEiSP0LXYie3pKcu/1QSnkta3B/eXSbOJJQZ
         iIArDlO68JfNmsYLrV5Chj1tWWFluNj90Lp5ANyUYVv5mhuh7ahRIBL42yuCRPloCx/R
         FdmSGT8WutBev0uyHC8po5NuEkgEgHDMFVzA4wc05aIMBZYm3BgfkoILDDpSWqB3bFjm
         i44kwzsSLbRV0qiu47L1Jn/S1MFNTFx5bqo+2aHzTRyUFemwWl1xM89Llc3CK8zBb0up
         YDwsjZVNrx+rjZnxS9aF0xi1DmciT+mue7vhZOReEvC8UDauiQlaB3Bz8j/pVk4xw9r1
         R28Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=6dAfEP10mYLzrMjbDQx3yrRDWC6z2OR5tbIbKtzt5Bg=;
        b=rMpvgZFZDgAIfF3xL1lR7GbqF+wixn9UeXDkTsHEDE+UOZ6TgCzZN8fCcCvsjZHTuK
         oVAXVcSk1GBtPUhNXn9SApGiCFFqHpQI+KnkGtngn7SUiQC59HSlOi0u+/p+QqOnsREa
         btaHiExlxWwaNGCokgbzlhA2DEcbORvg4vUsBah1e9JZdQ8gu5dSf1vIxm9xPor/NzAU
         CLH6nFmiMp30oLUjUg2XkLa2dNL/PodLasoOT8bszJy9SfK/sLbYwM99c1DexNbtwBui
         DjHNK/wfKndbLNcK5Chk8fr7/OOh+y8L7y8KwOjBY7cItYp86BeOuLbIfokHCmT3wi3i
         o5iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id b19si877154qtc.279.2019.06.20.17.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 17:54:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5L0sK0h000800
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 20:54:21 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 28403420484; Thu, 20 Jun 2019 20:54:20 -0400 (EDT)
Date: Thu, 20 Jun 2019 20:54:20 -0400
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
Message-ID: <20190621005420.GH4650@mit.edu>
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
 <20190620215212.GG4650@mit.edu>
 <20190620221306.GD5375@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620221306.GD5375@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000315, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 03:13:06PM -0700, Darrick J. Wong wrote:
> > I note that this patch doesn't allow writes to swap files.  So Amir's
> > generic/554 test will still fail for those file systems that don't use
> > copy_file_range.
> 
> I didn't add any IS_SWAPFILE checks here, so I'm not sure to what you're
> referring?

Sorry, my bad; I mistyped.  What I should have said is this patch
doesn't *prohibit* writes to swap files....

(And so Amir's generic/554 test, even modified so it allow reads from
swapfiles, but not writes, when using copy_file_range, is still
failing for ext4.  I was looking to see if I could remove it from my
exclude list, but not yet.  :-)

> > I'm indifferent as to whether you add a new patch, or include that
> > change in this patch, but perhaps we should fix this while we're
> > making changes in these code paths?
> 
> The swapfile patches should be in a separate patch, which I was planning
> to work on but hadn't really gotten around to it.

Ok, great, thanks!!

				- Ted

