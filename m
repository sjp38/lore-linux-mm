Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A8AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:29:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B9E320449
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:29:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B9E320449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1E708E0004; Thu, 14 Mar 2019 10:29:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCB568E0001; Thu, 14 Mar 2019 10:29:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBA528E0004; Thu, 14 Mar 2019 10:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79CD08E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:29:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o9so2467973edh.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:29:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=g4pAQHdVSNh0OPxMr6unT++rIYH+eOEuHNu2M72X/nU=;
        b=Ij0M7LkOZTqhsB4Rgq8vydLopgFUmItPHKk6fuxYyJyZxBJdv+mKyXO24wGwAJp16I
         COxNWRd+xmPkomb3p6MJp7pWDArZvYO9k7/MNELTQcqbThGoU4TPfEnnZdx4SBLgIN+F
         SkVaU17pLqdFGyEiAkmfUlkgm9NVrdqXem6qWmsiXEaMV7Ssk8dUcvCK6kEt3mdPYhw9
         zWCFwQnqfFmtqO0Ja9fcmj6PsHThH887ElHnuOoYW5WqGx1meMY5SuUixUZxlp9QEpel
         cL/fbZZRAx2y7JmszcxeamOe2pQzqHpvKsmxnWKdXfKBZymVrcyx7n1ci7Dm5iPTXFh/
         nR4Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXey9SdPX9dlEShM6ZP0xgKCmr4iV5P28UHefazBvNJrMlZC4C9
	GESomRGHHz0rrHWEN5ru4FJGPE3YU/GGUuklqAabH6SPrvQuoBZDGa+H+rkq5l+cVxQRcud0QSx
	cLzw91t9Bs7Tne8rBGG2gkEpS45ILd+RVQl0aC4QiArVRK6/sddsvyq0zVEBDFCc=
X-Received: by 2002:a50:d2d2:: with SMTP id q18mr11692780edg.35.1552573756063;
        Thu, 14 Mar 2019 07:29:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEj7c9yO4IwyN2a6DFIp+RXt0i1w3TiN4V13QoP3zUZpiQ02RXrHQuXJYaVksEWuV7iz2T
X-Received: by 2002:a50:d2d2:: with SMTP id q18mr11692725edg.35.1552573755145;
        Thu, 14 Mar 2019 07:29:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552573755; cv=none;
        d=google.com; s=arc-20160816;
        b=MXlv2yFUDR3PhMB2esvBPhUCl1XhO1YRt+lUKYL9ggLTckYGf6DXUzqLUr3uR7ucp2
         TaqOwN5yS0sMyoNazF77/0lz6Ziftov+0dtvkzBC5TPcr1ozkEwbWILHDUVUQg7525L+
         DKk8lSEXex3/j+KESzQZ6yX4SoGHNXYmCWbeBywEV6j3IQa68+dEkiAqKSdPgkEeLUk1
         u3WMBdg4JWJFg1Z2bHjcErWNILhG0tI2dP2pnO72Bu6K80xrVlklrsKSez+wwwrIiEwD
         RHYe2cfAr1jQqvaPzK1Fk0lC4lgyUrJR7ZAApQ0js2KXGjktT8lQaClhmLVUfvFSU5+o
         mydw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=g4pAQHdVSNh0OPxMr6unT++rIYH+eOEuHNu2M72X/nU=;
        b=Snpfk9b0WrQg51MjFa1KK04wdmqhECKJWQw+TA1GVkJ8W/tZVWSaEoWPXG6TcMMDfh
         H6KylKtGs3QIrFo0u1vCDc9Pub3mi1UGkgpwbgCB6t3rCWV8A7HegWATABDz78ZUMEYO
         mJoRdxJ//v9ATkB9C85Gl8YBmqv+oWat1o/0SBoh/PQrkG5+ldXdSJ8SHKTVl5jcPS9y
         DX1D6QCJPwsfGE25qknF6GeKfGM+7vzRixrKYKh2W62NRq/zVH6MsRwvcRqFSdC3DiTW
         0/v/yxAzmfQ4qpT/vjrCLD7W9t4HSH22QDbtdVxbyi4ZBqwgt43KE0zS/CqsdgBgv0AF
         s7Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id g19si711299ejj.331.2019.03.14.07.29.14
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 07:29:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id B8638457B; Thu, 14 Mar 2019 15:29:12 +0100 (CET)
Date: Thu, 14 Mar 2019 15:29:12 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314142909.lzwf64e4yjb5ek6r@d104.suse.de>
References: <20190314140654.58883-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314140654.58883-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002403, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 10:06:54AM -0400, Qian Cai wrote:
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

thanks!

-- 
Oscar Salvador
SUSE L3

