Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16815C46479
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:28:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A5BF2186A
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:23:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A5BF2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5116B0003; Tue,  2 Jul 2019 10:23:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74238E0003; Tue,  2 Jul 2019 10:23:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C630B8E0001; Tue,  2 Jul 2019 10:23:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2556B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:23:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so19559785edd.22
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:23:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p3tZICR9OdsCELMReG1iAWSuenLe+xlWYKRGruxarck=;
        b=ZZWewVFytURBUe2HsbbR3SMWLyp/CwuHH3Y2ZF8i3z5gOmHWNoekY1VikYKT15WKV9
         9Pe/5Qx6MbZ/bSLzonxOBCjxEhmvXuMsCYbwQZbLz3jf/WykFbEJDrPl0ySfbXrSopJa
         jKYCX5z1v2l6LnR+C85hS6YpUIm1OZXex/372qcC7hvWceLupZpB5dQ+noSUDi8b/xFN
         fMT2RqgPPVtTSX7YtPyJ21WX0YpFAoqhOhcy6jZE/4rwr6v9C+s2wCM7E2NDWgOmj4ns
         imA4PMRk0ngC7pcNpOQRTaBxLuOlj7fBsq+Muo3Ivd6wkQ8o1P8dnqRGOjkyFvvYTzWK
         b+CQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXdYBL9HPu8bn3o6YtuS+5ddn0xt2Jk3Z/eVRZhQRZNwz8cpBVP
	lZKXIlq49Eech5mv3VJrRWhakAoD5qmppeRRGvbRRdhVjKm69l5xhha6iTWsyNMVyAof6OBYutz
	xnJwiIG0ATEo2m9Xxv7bzraIn7TIrKBcT4uejW9xGmiU6FbgQbJWDM6ugQopKU2tCDw==
X-Received: by 2002:aa7:d297:: with SMTP id w23mr35518545edq.128.1562077392157;
        Tue, 02 Jul 2019 07:23:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykeBtumItmPjEUvCDvVzrG45bhBZqiANNyqZ+9D582jHZYWxTpwNcr20PZDaZE9g2otMy+
X-Received: by 2002:aa7:d297:: with SMTP id w23mr35518490edq.128.1562077391532;
        Tue, 02 Jul 2019 07:23:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562077391; cv=none;
        d=google.com; s=arc-20160816;
        b=HvHZgpdZQthdQyUH6wCQ3+N9EZeWdJohClc5iMWe9YYrw9K9eTNAs64QM7glwW5/54
         rYf+9cnX27/KFksrcdqlI2w74bRJ+CcRLfbEb2yz+y/whxgW7dttIy2QmVO1Rs9YBnNb
         p1gTQFnFW6Rn0q54MqMi1Qb7GPjPkEYE9/vknYhEjrDRjNyvdEClm7sp4azccYBa8BGA
         MDcd2fVTyN2kGb6Mp9EJba8mQsEzu+a6yVu1oxtF7nfkXz/1pKLR6U6Gcc4jYN/tac+Z
         vRzVjzqurQkKjbi+WPWmVCoo23zGLkzdHQnWfP8wQmUZsE2y3rVRO76vo119D6IbfBir
         /T7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p3tZICR9OdsCELMReG1iAWSuenLe+xlWYKRGruxarck=;
        b=fw0qVlmCAjK93NB/o0tmZ786kQZiaURitigtdqF3t8Ziz911s0bJM3XfJY7Gn3KS3x
         KBg2lpcS2tkY4NowzIynPXvfkKoBwKqWSThmP7jUX7dWxeJtVQGYLxDVuiJNGn3LMxy2
         LOfOfwB7e/upe0/bDaLHlpoP4XsGzbyZpof2YwzpxN/ZSyMMyc4bkaGn0CK3M1wk1cMW
         gd6a51rpBmEivOTa5qYmKRVbKJgBBpSUkjAq03wmbfmLyzLrFb9f1j95WuEZ8W5aBjG+
         A9In+wFgR9jLbZWiJteOrmngvLQariN7L/BxJcvlu1cOLd6Wktayt2zhpoHjFj46thrY
         jOOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i22si4172820ejh.242.2019.07.02.07.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 07:23:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 167D7BA38;
	Tue,  2 Jul 2019 14:23:11 +0000 (UTC)
Date: Tue, 2 Jul 2019 16:23:08 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Qian Cai <cai@lca.pw>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/page_isolate: change the prototype of
 undo_isolate_page_range()
Message-ID: <20190702142303.GA30871@linux>
References: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 02, 2019 at 09:53:24PM +0800, Pingfan Liu wrote:
> undo_isolate_page_range() never fails, so no need to return value.

Heh, this goes back to 2007.

> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: linux-kernel@vger.kernel.org

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

