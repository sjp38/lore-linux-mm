Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 483EFC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:05:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D13CB247B8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:05:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D13CB247B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 585D36B026B; Tue,  4 Jun 2019 07:05:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50ED46B026C; Tue,  4 Jun 2019 07:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D77B6B026E; Tue,  4 Jun 2019 07:05:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF2AB6B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:05:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so30321168ede.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9HEtVOiu4pNXbnYxArMNpdk8eL5JVqfW36c1mdcGusg=;
        b=KO8oxnHr9HQmIRw3JDYCymnTKTbztJA+1ATLmYQs+R6cgT4f64AZoT2RtAVDHmmFEA
         Tqh3I4OBEWzfCjvvrwqdpuaedKlzXC1SqMgGPN2PBlnpSO3SvhULK/f9ykcatD5TC67V
         xmB3vzMPd3RlOFS41vQ9g8qGsmQVrep2YC9T8QR+VftCPeMb+aXuKXFvywjEMi8HeOeQ
         bYCXlCqIKHfaHKh6Fj+OiKmbFV6tvvPpUnGGk78eTNwj5lisZW0sHZUpCvBYutt3ySBL
         YXl7FcuYYW9fk8IhZslLEtZ7nndCZ74oiCGSyaMUCxEDI2LRyEf5G33pmjGmLggoZZ8Q
         tZ5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWMbaIRwrHkSybxgbmJHAo2eF+OQCm7vTf2SqPwZVO4RjpTqE2M
	i0c0pxJ6LCyccVTCnqU1JF3ypb05UZbDvxxlwQAsMHQ8rSEzQ4mC5Xn9OkLBV1kkWdF78E915YB
	n8VOyrp3ue3w9WrbVQ/6p+F64FAITXMH4q5AcDqq+T3o6d0Q226borhjOIo8D+Vahmw==
X-Received: by 2002:a17:906:ccd8:: with SMTP id ot24mr28521047ejb.263.1559646317344;
        Tue, 04 Jun 2019 04:05:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ5R9R2Vl9RzKMCkw0hUpI4hVdMLTJ16udR/X8Ur4Ahvntm3aQx6JXFRiyIN8CuaBy3g3O
X-Received: by 2002:a17:906:ccd8:: with SMTP id ot24mr28520909ejb.263.1559646315821;
        Tue, 04 Jun 2019 04:05:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559646315; cv=none;
        d=google.com; s=arc-20160816;
        b=rThG6zbDpC6RBLsg1N7MMDAj/N9zOqlRbRRRDO2qe9QBNttVwGbGfFfVWikrFnCQTJ
         pWg+cRX3v7FZaQFGo88GAYgNzGKYgeuwc3GIReSDulkSTp0kgPdfLIldBaEm6ifet9Em
         3tME01xOb7WY7MNP2nICrPYDY8wQSa8DZcwCiZdArZ7xccHLk2TR2XKpoOhFzNeb4R8O
         gbgTc0cRXO2ewY/Y9Uo42ghEdxhNQz/6i5JAsqgqjyl9+v3BqApbwTv/rxN61mLI3Fan
         ybuCi3DetaYYlRBEWpCuPU96Gw5L3UFjo2KxtELTXrvChzt61vN922FbBRLob4936CND
         wfBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9HEtVOiu4pNXbnYxArMNpdk8eL5JVqfW36c1mdcGusg=;
        b=0y3yaMZ45gi3V6pkRtF3Ho6NL5D14QYwVJlNefU2UtolCQL+OdGnffc45CsUWv/bwR
         3YREoX2jiv+c/QkjNsZ5NjygeH6BGw8RU4c8nN3Ox9N/r2bpUSnO+4QX2ZZ7k/BXY+8w
         0yHsdW65WFG2drgUHbWlT8ARvn6euiKL9qmGP3EJt8sxUs0oF9RjPOlrniOnIOtGTQEu
         OxlZZ+Iq8twT8GbS+19RF+s+aUPCMwHTgKWVSYmdGRhSn5XtQ+hRCDhjOTzonNafOTu/
         BhvHKU3R1mpXXoKGPrfsvtGsd2iM6pwfSn5jA6rCs7OOT8miT/9wmbZ77knFJTzJhd07
         pQlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id r20si10292216ejs.243.2019.06.04.04.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 04:05:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 124721C3DF5
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:05:15 +0100 (IST)
Received: (qmail 18929 invoked from network); 4 Jun 2019 11:05:15 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 4 Jun 2019 11:05:14 -0000
Date: Tue, 4 Jun 2019 12:05:10 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	gabriele balducci <balducci@units.it>
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-ID: <20190604110510.GA4626@techsingularity.net>
References: <bug-203715-27@https.bugzilla.kernel.org/>
 <20190529160423.57c5a79115f350c3ebf025f9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190529160423.57c5a79115f350c3ebf025f9@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 04:04:23PM -0700, Andrew Morton wrote:
> 
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> Mel, we may have a regression from e332f741a8dd1 ("mm, compaction: be
> selective about what pageblocks to clear skip hints").  The crash sure
> looks like the one which 60fce36afa9c77c7 ("mm/compaction.c: correct
> zone boundary handling when isolating pages from a pageblock") fixed,
> but Gabriele can reproduce it with 5.1.5.  I've confirmed that 5.1.5
> has 60fce36afa9c77c7.
> 

Sorry, I was on holidays and only playing catchup now. Does this happen
to trigger with 5.2-rc3? I ask because there were other fixes in there
with stable cc'd that have not been picked up yet. They are a poor match
for this particular bug but it would be nice to confirm.

-- 
Mel Gorman
SUSE Labs

