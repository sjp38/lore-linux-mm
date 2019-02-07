Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D080C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF4A12147C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:33:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF4A12147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769558E005D; Thu,  7 Feb 2019 13:33:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 718638E0002; Thu,  7 Feb 2019 13:33:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607808E005D; Thu,  7 Feb 2019 13:33:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 413A18E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 13:33:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id i4so779774qtq.5
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:33:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nu1Fs6ufUZyeC/yysRodZu/LWVtBnSdXzPYfDpbpekM=;
        b=ChCuKH1q9Ov5+o+TY93FwWjyJggB+FZYu69s7/+mQ/eHNA1pbp2xHxj0sr2clU4l23
         HOBfy8uulgqIn4g+BkwHmf6q1yEyzUvPO4pt/FRyrNL6XdHEB5A3ctzAgvit+Pw/RWf+
         rol5O8+9706x66k5y2O3bdSF7tWj4YhfzgBxrPhUt8OXVVw72iJdY9lu7VP38yjAHyjl
         /QX6a+zQl7MYg8ZMUAj6jySxH+7l8bdlDwfQg+q03yZw5xZJCzAJv0ZSrwXdb+UrXSc2
         4E+/5nL9BN26HJt8t10rBZNgWczTayg1eiEs2qs1B5Hlq3BwMXH//NYyBG2MPHu13ujb
         3aTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZxBlZsii4HS2vGdsingbm7TAcfKNrYax9MMyw8h2Bs7SvwolBM
	xLi1XUn60qbOA4dHeMj/nabVditIwz2lacg0m9OcCop9OiPn+YZ0wqwfSodS0CiHupai0vFuHmS
	eK8xbK+zR5Cp2J85MZSWUJtc+JH6Gb8JiBPjFpzRMvE9e1jM8xzjOHIqVk9oGfVMp7Q==
X-Received: by 2002:a37:d417:: with SMTP id l23mr3266707qki.304.1549564419047;
        Thu, 07 Feb 2019 10:33:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3vkRoNdh6IbHYhv2hTumsPBkyE2Lq0VC2TdsSp0bJO/i5nTy33Eepze+m1sclIKprDhji
X-Received: by 2002:a37:d417:: with SMTP id l23mr3266676qki.304.1549564418486;
        Thu, 07 Feb 2019 10:33:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549564418; cv=none;
        d=google.com; s=arc-20160816;
        b=F/rE3fjmHuDF4S4y/WnCvWA0OUI1BJXPM5HAu6tOhMjUoF3LtdbMuGnuvZ3m9Ncm+B
         D/7hk0iQGzEGxStRcVqjiqZyY6a1sZTyAKnCtomqy0R6T9zVNKkcOirRSkfwktzF2mcX
         kTBnP8T6D9q5g3nSUHRM9Q09SFlMJNzMpQ63WuPCG5qcZSj4Q2WNmhtrYSQLw69oer61
         iwltvznwyKwGDaB2oG58418phSFATJPcxfkk8CNMDs7l6Nf1gHStBuWkSn35/OhgpHfO
         +7muOheGhwtSp4LoU4Z/C/yOysmERdVTX7LAo+m4G2NFddWMV9Bu0dmD7QOCZJtybTwT
         T9Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nu1Fs6ufUZyeC/yysRodZu/LWVtBnSdXzPYfDpbpekM=;
        b=DH4jC7gs0kXtFN2uXcM6n/uyy73/2POG6pQdtRqnxiJYtAjG8Rdsl10DVLe+tVGExq
         SZMSkYjk1lhnJG8blIVwemBoT/K2AjSLQo7XhnAAEHkY8fbkmtd/JwXqhLOO6gBUOc20
         o6Fgiq4pTz4xr8A1o83TjiH2RennAALFBfdBzUx/I1Opm9I6ZGNfaxD2OahIgNZSKhXT
         iwllu15vlaluIL3TQD3NqNB+/rJDu5NrHdvWVlefmCCXw2LwV6wtW2hjkqvAc+nZp74s
         9ZmF0qpgLmxFm9srEookcBevGDRqlEioLPF4xJAis3B7P+xvSS3wGdkqCszaWskyIeB9
         602g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r17si4521112qvc.182.2019.02.07.10.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 10:33:38 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF05580F84;
	Thu,  7 Feb 2019 18:33:37 +0000 (UTC)
Received: from sky.random (ovpn-120-204.rdu2.redhat.com [10.10.120.204])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8B84667621;
	Thu,  7 Feb 2019 18:33:37 +0000 (UTC)
Date: Thu, 7 Feb 2019 13:33:36 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Cleanup expected_page_refs()
Message-ID: <20190207183336.GA28677@redhat.com>
References: <20190207112314.24872-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207112314.24872-1-jack@suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 07 Feb 2019 18:33:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Jan,

On Thu, Feb 07, 2019 at 12:23:14PM +0100, Jan Kara wrote:
> Andrea has noted that page migration code propagates page_mapping(page)
> through the whole migration stack down to migrate_page() function so it
> seems stupid to then use page_mapping(page) in expected_page_refs()
> instead of passed down 'mapping' argument. I agree so let's make
> expected_page_refs() more in line with the rest of the migration stack.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/migrate.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

