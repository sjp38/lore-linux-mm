Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E67F4C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:39:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3C742173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:39:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="w9LAj5XF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3C742173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1B96B0272; Thu, 13 Jun 2019 07:39:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 152896B0273; Thu, 13 Jun 2019 07:39:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019886B0274; Thu, 13 Jun 2019 07:39:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A58016B0272
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:39:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so29489507edd.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:39:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2xaaGMG7No2zQ7VPLAPzQ32rj+gGmBMPzXcN5RQJnF8=;
        b=A8xZKoJCwteLwdMTuTlUS7T/Sej0CCT6RaK0yE6wDblSuR87XQjuO//KoQ+dGvK0mg
         1PIFP/3oeyj4iGyjAS0RMAOXV0e5/DD/Kr/9bRo0NPtrv5/cFqj5I8349Cl1141DqbqH
         YoVs6nARaYL6ANqGZibeOrwwNIPX0q69jkpi+2urfBqx7XUWW2BK6/MACzKBC3kJBtM+
         v/IHHXKrLNioAaK5UcCAsVEuBMrH6lyE7ZA5OIJGiF3BZgGGMiBBrQHD2qHr/KTfwbxW
         +EmpAVQHXXvj9XNgjhv515F19+1adB8A8bzQIlUo1/sDqwSPCrkjmzSDpkZM1RlGo1H9
         FIOg==
X-Gm-Message-State: APjAAAWcAK0o1iT5Pfr9wdFHwEqfVlJLnZLURcLKiXqQ4mfau0TtvkPh
	4R3AhRLuN/z4XAOs3gN55/66CrCNNfJIjR+//MESPecEz70qQQiP/iAvf3M+5E9nfEq5ycWg0S1
	f+l2eAXuaYMp/oYlvFWOgfnbEzvsx1FRO62z455e/h2G56W/J9kTrLVb799LnZ4OD7g==
X-Received: by 2002:a50:ca84:: with SMTP id x4mr8998593edh.228.1560425986140;
        Thu, 13 Jun 2019 04:39:46 -0700 (PDT)
X-Received: by 2002:a50:ca84:: with SMTP id x4mr8998535edh.228.1560425985482;
        Thu, 13 Jun 2019 04:39:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560425985; cv=none;
        d=google.com; s=arc-20160816;
        b=qmR0mPUuM5KKUVkhrHTFr3JgI0IzgD2/4Wpg3F1fQyg7JUGBMfNsX5bsDNhM0pCdBQ
         v6sQDzvkQ06d5+3ystO5LBsUWEARSQVjjjD1TMb5b+O4UltB0mNWwEDy4RetOZNQqobJ
         P/jZWcEIOTau9umDDtNfOcL8m3gJFZPtQuexON7dfpSLD7bCRKXgeEGjsw+UPGf+Gexp
         g5e1e8yO4gBM+WGkBCuQoPnL2pCpcxwU1hX2Wor+hbpX/E8SdqmCsDjYizs2rfCiWHkw
         CrC5Ob+bRbEpmyx1xCHantinXUPpKvvbIHy9ghMxFvk+fRayleat1RaAGay7+7OW9jmA
         HG6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2xaaGMG7No2zQ7VPLAPzQ32rj+gGmBMPzXcN5RQJnF8=;
        b=R8VnxA8vSbE9ben+ti8DuV9dpXGwT5dwMIu+pYtY81puQvdoeWd4d9hcN3Cvz7bGQG
         rr55ELQBKWooCfw7yXoJiGzNGph+UjjoKmsek5csr6+splvfbGY5SQbnAXNkS3Zh4O0I
         McK2V3+U6XPG6tm/zGBhr3rrBOKVUdM9ZCfhWB6Awepfe77r9QgMu3DwGKXPxQf+BGR6
         ES/Seiq0NgmIa2puUzgcW2huEk5cJxsxDB82W4Xtc9RV2cSqrzhCFdujsIIaza8anBdL
         egt92gcYWfn7FuVZfs5mU+BDp209aeoPHwGHri7efdDbDeLhgZXSnvzBSehdPTLvhe1D
         qjpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=w9LAj5XF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor923821eja.25.2019.06.13.04.39.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 04:39:45 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=w9LAj5XF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2xaaGMG7No2zQ7VPLAPzQ32rj+gGmBMPzXcN5RQJnF8=;
        b=w9LAj5XFY3ophQ4DwkbtNeEFNYTxLX2X5OdCVXnqnO3uj/VWYQ7iJfD888INwOAkyj
         0BB3q5T5bJea3946DH84lSLMeNeqV0RqrMsWryk4vyz07gNhLZ+xO9Gc7Ya9acqsvQir
         lmxxyDCm2sg4r6cj1gW51A9ku4YV1DJPROEeyiN7XoD00wvUn8tVxatQYIBRJyhGxPax
         hBSqiTLMnE9fXLPEcQ0rgzrh19vAcRiiEGtHraSy7nma6MHE2ewccw10WPd+GrVUCwmJ
         Rb60/5vDUddTfedPvHIZZE7qDEx2Xns7fcz97/+iv2Y+hSKU0gSZCCB9kVsDwnRlOfJ1
         ogRA==
X-Google-Smtp-Source: APXvYqy7Xsp8FQwiuXe2lfvRN1vozauF321WOLdOmtipAcKk82HAFQY/JTpoxC5Z6nYOM32/iIsHSA==
X-Received: by 2002:a17:906:308b:: with SMTP id 11mr15873396ejv.39.1560425985036;
        Thu, 13 Jun 2019 04:39:45 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d12sm841728edp.16.2019.06.13.04.39.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 04:39:44 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 9479410087F; Thu, 13 Jun 2019 14:39:43 +0300 (+03)
Date: Thu, 13 Jun 2019 14:39:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of
 __page_cache_release()
Message-ID: <20190613113943.ahmqpezemdbwgyax@box>
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 05:56:47AM +0800, Yang Shi wrote:
> The later patch would make THP deferred split shrinker memcg aware, but
> it needs page->mem_cgroup information in THP destructor, which is called
> after mem_cgroup_uncharge() now.
> 
> So, move mem_cgroup_uncharge() from __page_cache_release() to compound
> page destructor, which is called by both THP and other compound pages
> except HugeTLB.  And call it in __put_single_page() for single order
> page.


If I read the patch correctly, it will change behaviour for pages with
NULL_COMPOUND_DTOR. Have you considered it? Are you sure it will not break
anything?

-- 
 Kirill A. Shutemov

