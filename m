Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCAFFC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8654121880
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:19:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="utzXytN7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8654121880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1978D8E0002; Wed, 24 Jul 2019 20:19:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14AAF6B027C; Wed, 24 Jul 2019 20:19:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05E458E0002; Wed, 24 Jul 2019 20:19:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2B3C6B027B
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 20:19:47 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d190so29613619pfa.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:19:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8X9OAT7Ub4bGz+CiDDCqB+6Z0vTXY4myxWRPlRtlgHU=;
        b=QQd02zZpK/RkKL2Zy3I1GsoIsxx8xvKD+efUbyktKHUwxRioMnY2XitBEPXDO3mDpn
         CL4rACKandoAsNrqu0LHy87fEV5cwiHUhXh1QVCldrQV55f7mjxhDwuRQEtYeBXZWLvq
         UprjfrIgnW5gGTCqRhJgU2pV6F3MUZvDzH9hGqSINJ/6MTbS3CRZr173edawpi+w6cp1
         HCMejs3BH64OIAjjclN1vcnoCI2HV8O2RG6rMm2rzkSqes3ofcMfNS44Kp81PfIzVjBF
         ShSLktVhkpJLqGjpxdaja0vePkwLVez2Bv2JWlVDbMHNd1fdrCcx4w4ZQ6hfCYnLLKZh
         4KPA==
X-Gm-Message-State: APjAAAVz+RPQu76PjiEeMfwCVi/k0KN53ioq4hoAh52wvd06MC1MD5PK
	bZ3fKANx9HW6Ch4SAESLqidY7G+8bglChfwXqhuCFVCS5v+2KNl2y6RlFOtxwa/UC00Jt7WPKY7
	HjNXecs77gcfBZCNwAwQei8Xi7fxFoaJYtcT4HmnPwM8lLmsiBbE0Z4skAEyrFDwfKg==
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr6341132pjf.86.1564013987317;
        Wed, 24 Jul 2019 17:19:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzP29UG4/Ejt+HAa/VYyA4/Tz217Cz2TYKOCOFOqGfehHciCrwO9/hXVQprCkCPec4odl+P
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr6341089pjf.86.1564013986503;
        Wed, 24 Jul 2019 17:19:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564013986; cv=none;
        d=google.com; s=arc-20160816;
        b=RoGbdX+Tn5qyLfR4Htqz0mTcLqKscu91t+BbFeN3VoFVy9ItVQC8tw1tQ5vJw+u5KI
         JobuxDzOhImvS/GKg6agAIeeuQ8enzR2lZlXGtEjAH/C2YUvd7y6t4SFuWoAP+0T5c5R
         k9qRGa3q6+ColfWGNoPoNSJHrha5d7yCgQzTO5OBHM1JYcPMyUzAEZ5SEhkudCp02eZN
         c9fdAAWIXZjVfa2SJrG9/pYFOy7O/+Wpt7VMF9uCTC6mJ+g46TWX8X9mXPXHKUDWPIS9
         Ek46l8oF9FkKxyS/iHPQflFPm4aIt92hw+4iyFQKMyVM7hHGVKCvyjBoh0YF+rtITRUs
         A15A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8X9OAT7Ub4bGz+CiDDCqB+6Z0vTXY4myxWRPlRtlgHU=;
        b=VkUNcN7BdXmJ6imAPLdJ/htgR0Mf0haNbTdChEK7miTbUEoGLyOb200Zye0BbLVzRO
         4kouUV8Rqf/61P8xdZpPRX7n/LFXxGddCDI4xHOD6jluz/gBEZoqOD59nCN0nxFkh77E
         c/k2C3Oww5XVDL8Km0A9XLetcv6Nwxa9Kvrmt2j6VaiWZ1w95Y1r8eNZ2dyNPIYIcBnL
         idfZveYaqoXvnracNUS7xxqf7xavlZPkKPvJf7h7GQm95sSGIB+PUS6jix62zgw9oXPL
         yODEJ9hA2HfkdcwCCTh8767LgpWF18jv0GquxDmKzB2Ta/S5w8X0Yk/n8vsf52/0kobz
         mJkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=utzXytN7;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q12si7278666pgk.102.2019.07.24.17.19.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 17:19:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=utzXytN7;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CFEAC21871;
	Thu, 25 Jul 2019 00:19:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564013986;
	bh=Zqwz4aS1iY+zulSY8zCDg4moCvQGQN0iXNNVDIrE1oY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=utzXytN7Igj8F4xn3wJDFep/Q5GeKewz75XL+1cE4cbvTXvMKAdLH8CiW4K+NrYbJ
	 7XT9i877mFSny3piPkzCb88xvOmj96jKL1iKA5eK54hq3zoB5qshnBm2ITaj1bkv3a
	 h4seyx8c4KFaZQDvWnm22nQf5/+RNfRIByRs7c7M=
Date: Wed, 24 Jul 2019 17:19:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Yafang Shao <laoar.shao@gmail.com>,
 linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Yafang Shao
 <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: introduce a helper
 compact_zone_counters_init()
Message-Id: <20190724171945.c81db3079162a1eb4730bd20@linux-foundation.org>
In-Reply-To: <1fb6f7da-f776-9e42-22f8-bbb79b030b98@suse.cz>
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
	<20190723081218.GD4552@dhcp22.suse.cz>
	<20190723144007.9660c3c98068caeba2109ded@linux-foundation.org>
	<1fb6f7da-f776-9e42-22f8-bbb79b030b98@suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2019 15:35:12 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 7/23/19 11:40 PM, Andrew Morton wrote:
> > On Tue, 23 Jul 2019 10:12:18 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > 
> >> On Tue 23-07-19 04:08:15, Yafang Shao wrote:
> >>> This is the follow-up of the
> >>> commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".
> >>>
> >>> These counters are used to track activities during compacting a zone,
> >>> and they will be set to zero before compacting a new zone in all compact
> >>> paths. Move all these common settings into compact_zone() for better
> >>> management. A new helper compact_zone_counters_init() is introduced for
> >>> this purpose.
> >>
> >> The helper seems excessive a bit because we have a single call site but
> >> other than that this is an improvement to the current fragile and
> >> duplicated code.
> >>
> >> I would just get rid of the helper and squash it to your previous patch
> >> which Andrew already took to the mm tree.
> 
> I have squashed everything locally, and for the result:
> 
> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Also, why not squash some more?

An SOB would be nice..

And this?

--- a/mm/compaction.c~mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix-2-fix
+++ a/mm/compaction.c
@@ -2551,10 +2551,10 @@ static void kcompactd_do_work(pg_data_t
 							COMPACT_CONTINUE)
 			continue;
 
-		cc.zone = zone;
-
 		if (kthread_should_stop())
 			return;
+
+		cc.zone = zone;
 		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
_

