Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6BAAC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 17:21:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48C532075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 17:21:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48C532075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDCC16B0266; Wed,  5 Jun 2019 13:21:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8D076B0269; Wed,  5 Jun 2019 13:21:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7CE76B026A; Wed,  5 Jun 2019 13:21:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB186B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 13:21:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a21so6632477edt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 10:21:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wmhLTsjSokkqh5+/OTvpKw/9iaYRU4mTxJw/7I1542I=;
        b=gvdh9T59f2inTetFADodbJNUvQn09n2jwyMML51rcjMfA8JQOUp6Lo9J4xqkuuBcy6
         31GLxAhxVNvSRFsKAVlK9OKjj8GyC93ckPcAL+Bn50mE0jW7zNRTxHGYf2fu1C4W7Puv
         ij64uuTtQ23ehXV3axqJt+i6Rao4GXBxPLtihtbN6K7php47RMh9CCxrHjfuacs84LNh
         BtNjoj8gQJA/CksggZw1szvDImrRwdiFb79A/17Pp2IKTJP9Hn5eBVV4dg3SF9jTdWOW
         9EWSufcBvwwH/opvHm/Yr1aM3LZIEG3dQOMd7NxWAcl3rC8nDxaoSkb5GviyvWlexZ2i
         BGPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUJbavBT893OqMqIM45dfo7Mh+DKy+z7kGTq6xvzSpg24OvS77n
	aBw+IVzpdxk92BD71phEJVVdUt6UCCzkaeJ2XGyNKoY7nTou9bR1X+rarlyXxKu9nFLC2HZiWU8
	8rDOqyKGB0oXG6yhUitC5lFZg3kWDawS+hu3seRdGUPn3kBuylMBnrC4Hghc9hmP/ng==
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr19204921ejb.166.1559755300895;
        Wed, 05 Jun 2019 10:21:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxafcV+iwpOMbbQku5FXrdsdg1zwBI9AA7iZl9cYBh0vtQ5f1LZIcqm5MFhe3guyKhSm8Y/
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr19204799ejb.166.1559755299220;
        Wed, 05 Jun 2019 10:21:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559755299; cv=none;
        d=google.com; s=arc-20160816;
        b=T4uKX/Yw/17zn9nZEHtxJfFToQ6KqczZHHKUkxik7Ro69Q1q+M/tv0FDy7V9NGAjOW
         o5Cjim1FQT8bK4qNpfDlOQ5bMYODAKvDfXM9G4dZcpqfWf0nkpSwxv9RxC98YotnxRCF
         sC458KiQnVrdLf3Ic6b7H9+qYzJITFihxH7P6oDLx3luQPRCcknT1AQ3+oZ9FH1oA1Jb
         dnvUyUcKmsBvb9Ixl86JkoK1e4U/xcjP+c8V0I7J8eur5XE/B1Ro/PCNx8d4W4Xdzj0h
         yeloVzoPrdPEdY2Y2kM2Vmu+heQ2dgicv17Vkbds7/3rkccRLswW5TCnTmWAysFTEv2U
         m2hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wmhLTsjSokkqh5+/OTvpKw/9iaYRU4mTxJw/7I1542I=;
        b=I16Dzux4rdvsZtXcNkWhEfBDsEQrxIx59WtZ7y7qiruqK1TYhWMAc1paFIJHX5RcEV
         +u5D7izGJpmcUvz/dVxKS2zOd/Yk9vB8H6xOw/TwF9BD2QC0Dwxr3K1m9WTBxH4WeQRb
         a8pq8mSQMmAqdDiPmxDDzSVvfmNLaQplkd+tKeYVKpKP2Fp3s/K1V0NdK9Qyo7UNimuy
         LIisUa88ot9m7T0w6iZmtoOj8Uc30GzulHH0SVRfX0vEPF4iPCY16fViHcaBpt23YakO
         8XL3fxarvQqPUZTJvYzMAzp5OoKBFw7toma10o09Njk2Neo6fcnmWGy87WZVbo3stf5R
         4euA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id hh12si6394247ejb.189.2019.06.05.10.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 10:21:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 5F16B1C2F8D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:21:38 +0100 (IST)
Received: (qmail 11740 invoked from network); 5 Jun 2019 17:21:37 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 5 Jun 2019 17:21:37 -0000
Date: Wed, 5 Jun 2019 18:21:36 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: balducci@units.it
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-ID: <20190605172136.GC4626@techsingularity.net>
References: <20190604110510.GA4626@techsingularity.net>
 <11510.1559738359@dschgrazlin2.units.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <11510.1559738359@dschgrazlin2.units.it>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:38:55PM +0200, balducci@units.it wrote:
> hello
> 
> > Sorry, I was on holidays and only playing catchup now. Does this happen
> > to trigger with 5.2-rc3? I ask because there were other fixes in there
> > with stable cc'd that have not been picked up yet. They are a poor match
> > for this particular bug but it would be nice to confirm.
> 
> I have built v5.2-rc3 from git (stable/linux-stable.git) and tested it
> against firefox-67.0.1 build: no joy. 
> 
> I'm going to upload the kernel log and the config I used for v5.2-rc3
> (there were a couple of new opts) to bugzilla, if that can help
> 

Can you try the following compile-tested only patch please?

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..b3f18084866c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	}
 
 	/* Ensure the end of the pageblock or zone is online and valid */
-	block_pfn += pageblock_nr_pages;
-	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
+	block_pfn = min(pageblock_end_pfn(block_pfn), zone_end_pfn(zone) - 1);
 	end_page = pfn_to_online_page(block_pfn);
 	if (!end_page)
 		return false;

-- 
Mel Gorman
SUSE Labs

