Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB913C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 06:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB74D20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 06:46:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB74D20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5670D6B0007; Fri,  9 Aug 2019 02:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0736B0008; Fri,  9 Aug 2019 02:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4068F6B000A; Fri,  9 Aug 2019 02:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC86A6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 02:46:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z2so721385ede.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 23:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=947QlL07PPoYbdW0VJj6ydRfatc+ZVl3uFshUThc4mc=;
        b=t874VuKnr2BQpc0MajSr34YGcV7CRGtwiEinZLcIE0TlgdXgafYVd1A3NNrYtA3Zas
         3FowutK3yixshyDNhCu/jeJQGidzjuCqdxm89XyiQ4SnmP5llAWwaBAwOW/cFpsoSzu2
         FDJQnwTzK0TVMtPs7XGqrKnBhnDtlA6Vn/63EKp3dGiBn9bpmKRN14OR43vGcZ0hEMBz
         w0F56mkeb5HgAQsUJFmO99QJ62rs2U7BNovf90htGVDylBjCIYerdpjkFlcLAdmKpryD
         8K7qCAaZo29uCNP4wu8VYSj+L7PoPrqRukWItuu3MbFDvngi++PeNqgpHa4MEECM6eKh
         IGlA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxJE41zt+8eItom4su0ZUcmYPBqWIh5D52/uzXOT4Nv2lDDaP+
	KQmadQhMa+6OZLGnJVCPIYmXAJ6egaPWUwZSJX4eoZuK0hlp9akRkwK3PG6VwwcJ98RUgqJ+Igv
	PZPsN77B4V99X6TrCBny1mqiisSyz+6q5xncy03w6oBYmNjplnuMbGW6G8taTlKM=
X-Received: by 2002:a17:906:12d7:: with SMTP id l23mr16803596ejb.282.1565333196458;
        Thu, 08 Aug 2019 23:46:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytbe9HcgZEEeQtc8j99oyO3Z9YuZqvsnRPkq8PS6CKz58CVD/G2Sex9nBSg2fpUPcj8suK
X-Received: by 2002:a17:906:12d7:: with SMTP id l23mr16803558ejb.282.1565333195768;
        Thu, 08 Aug 2019 23:46:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565333195; cv=none;
        d=google.com; s=arc-20160816;
        b=ydMtXXa6CeptjQ/UYpOffJjApjTK6TFLKMKokBulYkS9TGWLyX7DL/yAHcoP4tPzVK
         XUHwQHdaLokZHBpW9DA5FaBxAvk80yGnb6QjWE6s1TeT9XNOpVy330h7pVwFj0YmibiO
         +dq88eg2aFiantGLS4mC6LLSt6N8d49mpryrwhuDUuOw2awO8F1iOAN83N/GuR5aHUnA
         LblortvlKDBFiY+KWH0ErEKuVwCmB2voYoZjrqDWd0IdFrNsXe3Vt+up3nXxhEig9kEN
         odwdeYGtqe+h/r5iHKgmMkDJGy/QXYo1RliBNsdICyYYVfZJOs/s3qksxXpoRM+FZAI7
         S9SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=947QlL07PPoYbdW0VJj6ydRfatc+ZVl3uFshUThc4mc=;
        b=RwrbfwtNw4HeBLjGjRY59jieRXOPYPs1v6k5apA3uqAxjUOuE5yFZErt7c5j05/dn/
         C9vSTFFGV+yNvOgGfeODHtEN1e8LSYdWMNOTPTXi46YM9NBrCj21RC5VlsfVXiQ35Xg2
         OS+LU4MhFsDu8aL/+KSc5a5jUCkoK0TkkdXN9n0Xg+9qR50qLENT48EVtOR8ruu0Blb5
         /aT+JSjsGnpnumMrVs5BAw8o6tJCKfI8wPnbhPnoqeXfiWYHvxrWQwsfreil4JtHUSZN
         9hvsEo1iw9Gz51EJDLHvOIO5d2DAtFbEBym2XA//W+ERDmNQrFe/Ly/98NE3Cn66PQQs
         CS4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si35591332edb.259.2019.08.08.23.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 23:46:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C910BB03B;
	Fri,  9 Aug 2019 06:46:34 +0000 (UTC)
Date: Fri, 9 Aug 2019 08:46:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, ltp@lists.linux.it,
	Li Wang <liwang@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
Message-ID: <20190809064633.GK18351@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
 <20190808074607.GI11812@dhcp22.suse.cz>
 <20190808074736.GJ11812@dhcp22.suse.cz>
 <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
 <20190808185313.GG18351@dhcp22.suse.cz>
 <20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 16:39:28, Andrew Morton wrote:
> On Thu, 8 Aug 2019 20:53:13 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > https://lkml.org/lkml/2019/6/1/165
> > > 
> > > Ironic to find that commit message in a stable backport.
> > > 
> > > I'm happy to drop the Fixes tag.
> > 
> > No, please do not drop the Fixes tag. That is a very _useful_
> > information. If the stable tree maintainers want to abuse it so be it.
> > They are responsible for their tree. If you do not think this is a
> > stable material then fine with me. I tend to agree but that doesn't mean
> > that we should obfuscate Fixes.
> 
> Well, we're responsible for stable trees too.

We are only responsible as far as to consider whether a patch is worth
backporting to stable trees and my view is that we are doing that
responsible. What do stable maintainers do in the end is their business.

> And yes, I find it
> irksome.  I/we evaluate *every* fix for -stable inclusion and if I/we
> decide "no" then dangit, it should be backported.

Exactly

> Maybe we should introduce the Fixes-no-stable: tag.  That should get
> their attention.

No please, Fixes shouldn't be really tight to any stable tree rules. It
is a very useful indication of which commit has introduced bug/problem
or whatever that the patch follows up to. We in Suse are using this tag
to evaluate potential fixes as the stable is not reliable. We could live
with Fixes-no-stable or whatever other name but does it really makes
sense to complicate the existing state when stable maintainers are doing
whatever they want anyway? Does a tag like that force AI from selecting
a patch? I am not really convinced.

-- 
Michal Hocko
SUSE Labs

