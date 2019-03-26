Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B0BCC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:01:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6228920866
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:01:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6228920866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D95596B0005; Tue, 26 Mar 2019 05:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45FC6B0006; Tue, 26 Mar 2019 05:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0F736B0007; Tue, 26 Mar 2019 05:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C49F6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:01:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x13so4945857edq.11
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8MgUXLcOoFNg2NbDkFF37cNGTXcjXfI74ystPIoN9vc=;
        b=ab8Yc/YEaOxDQ9vaIBUUeYDx5m/P9bBZfIitBzTckXaW7Z0zLHJdE025tW0HLcCAIO
         s69QjdwpuauCwbRkekyxF4uacTkZZGUD1TIYEV+lHDzi2jerayQ3M78+y9sJaBnOQ7mE
         fEXojcYrwIFlhBQR3GRgwkUMJjs1lAL+S+LCFtuDMVvjGxG70hbH+SOFnkK9svq2kSKQ
         EJZlqxn947EEPpj3A1g9PMQa+i77jKqzsNzoE1ul5oOCWlQF7r4mMboqipZ5xZRek32p
         1KvlHEyhtElhkCYAOzQKWfNF7BpStS2T2BE/dqyjYGuNvvqMFnUOJxal/Mq1DRGotini
         BA0g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWuwWb2slF2MpN0kl6VA1P9IpsDQE9U55B7j8eOefZCEiAYflwG
	NqavMqp1bEgljMNQafIJlTIE5ExKE2kjglHPRLwqMT6bZt9gb28fjY7ITWNeQLK8XvBJEYrIT+b
	M3oYqxGwf+QMjZSmHCMTOj+RTP1WkSUi7av1d0A9zlG6sSWmwnH441oUe0oDiIFU=
X-Received: by 2002:a50:a725:: with SMTP id h34mr9875111edc.201.1553590905043;
        Tue, 26 Mar 2019 02:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnaxPq0K2DV6TCIJV24cGKWC+nOhQQMCuHcQBAVAkwU+bNuFCY1Dk0WcSPr5WyD9yX30Rw
X-Received: by 2002:a50:a725:: with SMTP id h34mr9875065edc.201.1553590904336;
        Tue, 26 Mar 2019 02:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590904; cv=none;
        d=google.com; s=arc-20160816;
        b=OecUxz9vM9vHrc/wmrEf6haG78Wv3d2YK0XzHFA5shE4TgFCFTbP49M9Y0KKO5snuZ
         hyR7PHjtoFlnLDwROGlzkbwD4paAEwFXmy9eA/UcslpG1LJi3+phgQDCZoQvmWCL+Hdm
         PD7rTmCf9+GXp3XelmwfdaaSoC6ihXLTDJuKFFQYNapZhH5LTk0HUpKOVHgYybrAcHRX
         AWk4NpAkS+DD0TdD1MzdQJbEsbOwicnbMpT6iQENo2aSiYaLef+1KoGDh1QBGuascgGC
         Ba8mfDM3gMgNdmTnu8wchjoOO0sv/iZh0cmJNmxgppi8dkqQNsmBRoGjAaEVGLh3ePfo
         ZnPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8MgUXLcOoFNg2NbDkFF37cNGTXcjXfI74ystPIoN9vc=;
        b=FkUu3lmE2B4SUDSuDW5KMtJVxlXElmlMIi2QieLdlo0pGdOOUeTfKoyAyK7R6erduL
         NOZXOn9kdXgc4hAvsvIBZ0Cw2JVIOk9rERxdVVKjiKYS3wGx03kytwUarEWEVrnkqqp5
         33h3xsPIsXORoXBdZ5PvX38DPloGSx8rhusA4HEuOxCE2QaGxvmYki9q7xLkkQXY6X2h
         kfRexcrgMQU7ciuRObf7eabBkXYJRab76/0X3b7/YC7efJu4nzCB5o5M1K2dyAvQCEzS
         Ztw91EiNrmdbuGSiUTzD1bDBn24HDpFcLhxW7SZQeD8aJfW1Rz1GnFOCoLjP503PawzC
         qCFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8si350596edh.103.2019.03.26.02.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:01:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 75AA9AD65;
	Tue, 26 Mar 2019 09:01:43 +0000 (UTC)
Date: Tue, 26 Mar 2019 10:01:42 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>,
	"aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Message-ID: <20190326090142.GH28406@dhcp22.suse.cz>
References: <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
 <SG2PR02MB309869FC3A436C71B50FA57BE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <09b6ee71-0007-7f1d-ac80-7e05421e4ec6@virtuozzo.com>
 <SG2PR02MB309864258DBE630AD3AD2E10E8410@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309824F3FCD9B0D1DF689390E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB309824F3FCD9B0D1DF689390E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[You were asked to use a reasonable quoting several times. This is
really annoying because it turns the email thread into a complete mess]

On Tue 26-03-19 07:53:14, Pankaj Suryawanshi wrote:
> Is there anyone who is familiar with this?  Please Comment.

Not really. You are observing an unexpected behavior of the page reclaim
which hasn't changed for quite some time. So I find more probable that
your non-vanilla kernel is doing something unexpected. It would help if
you could track down how does the unevictable page get down to the
reclaim path. I assume this is a CMA page or something like that but
those shouldn't get to the reclaim path AFIR.
-- 
Michal Hocko
SUSE Labs

