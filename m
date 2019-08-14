Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68EA8C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25C4120679
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:38:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="GZ5y/O3f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25C4120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B62AF6B0007; Wed, 14 Aug 2019 13:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B12AD6B0008; Wed, 14 Aug 2019 13:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A021D6B000A; Wed, 14 Aug 2019 13:38:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA076B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:38:33 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2B340181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:38:33 +0000 (UTC)
X-FDA: 75821742906.16.cap45_2d84dd35f834a
X-HE-Tag: cap45_2d84dd35f834a
X-Filterd-Recvd-Size: 5972
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:38:32 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id x4so12980246qts.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:38:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4BL5XZQz+p5d6tRSI8UgGndGd0i26QwDHoau6MxYYLA=;
        b=GZ5y/O3fyBNnstbyvOADsRpKWOCP6tLzpWK55C2O1o3SaTumF2M8WN5IquV0vharRJ
         Vj6F0ER/zA4UHC1gLoJgqgJmo1pUufEieBTrdTqoGIBq2N4DUumbW/cMJbrl1VVNByad
         4aZw5rj4SSAm/2VgxPx3ehp5ieE8vIwRpTpcljvn4XtLfC/IJjeZRnOJxcC9IAXjC348
         u6NmUmhnUOWJ+9pf7Cg19TgIe9oMd4mmBt4OgnbpwVPRlHasESVQXh8DgORDFL7e9dIY
         DQQ1R3SBs+BxU2oSOxNE84A+2nDuDnbsk5f6AxEuLomLooVFQuDKqC8zTybwExG7DYQv
         Ovww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=4BL5XZQz+p5d6tRSI8UgGndGd0i26QwDHoau6MxYYLA=;
        b=FlO2o3iq+StSkxxDnHbh9IJWA7Jie1YSQi2fYD47hq0ExlwcLJkh7E9h1yg0uWZY5J
         /cWx+J1sBQMIARyCePbjXei7VmnKvbttjR2BHfAJW5z9TUmyV3vv5y5ew//1fTf6glzX
         8gjJWfDOhV3If4qlG3zUSld6sV/9OTh3OyPJNIzQ8lrcmVPBsz6mXPvcDMcch6gpzXVR
         oMFnmJu0BCxx7pNXQwKD1Lx4FZifnbm1Gyp/IxCzCav6i/a7TF3FNH0o5ojFC/BxHknJ
         UxaypbmsTDDF65z2RGX8QsxNjb/BPpZgi9HcN+olWekm3M/0l1Ffq0ve70ZMJaE20iB8
         PA3g==
X-Gm-Message-State: APjAAAXjbRUOWCtywSJU+3UFgq5P56PDujSHtlfnzH96QI63CidQ5rz9
	GyvKkywSLOLdIK9useQvwbVDpQ==
X-Google-Smtp-Source: APXvYqxpAAoXp0kvOxvJXtMrsqgsFY3sTwK9jF6HD5sftMuz7DlYtAaSID0v0hvt26yGYDKgp7YVfg==
X-Received: by 2002:aed:2fe6:: with SMTP id m93mr512005qtd.114.1565804311976;
        Wed, 14 Aug 2019 10:38:31 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id j61sm150258qte.47.2019.08.14.10.38.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 10:38:31 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxxEE-0001nN-UV; Wed, 14 Aug 2019 14:38:30 -0300
Date: Wed, 14 Aug 2019 14:38:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: Dimitri Sivanich <sivanich@hpe.com>, jhubbard@nvidia.com,
	gregkh@linuxfoundation.org, arnd@arndb.de, ira.weiny@intel.com,
	jglisse@redhat.com, william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup
 functions, Convert to get_user_page*()
Message-ID: <20190814173830.GC13770@ziepe.ca>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
 <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
 <20190813145029.GA32451@hpe.com>
 <20190813172301.GA10228@bharath12345-Inspiron-5559>
 <20190813181938.GA4196@hpe.com>
 <20190814173034.GA5121@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814173034.GA5121@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 11:00:34PM +0530, Bharath Vedartham wrote:
> On Tue, Aug 13, 2019 at 01:19:38PM -0500, Dimitri Sivanich wrote:
> > On Tue, Aug 13, 2019 at 10:53:01PM +0530, Bharath Vedartham wrote:
> > > On Tue, Aug 13, 2019 at 09:50:29AM -0500, Dimitri Sivanich wrote:
> > > > Bharath,
> > > > 
> > > > I do not believe that __get_user_pages_fast will work for the atomic case, as
> > > > there is no guarantee that the 'current->mm' will be the correct one for the
> > > > process in question, as the process might have moved away from the cpu that is
> > > > handling interrupts for it's context.
> > > So what your saying is, there may be cases where current->mm != gts->ts_mm
> > > right? __get_user_pages_fast and get_user_pages do assume current->mm.
> > 
> > Correct, in the case of atomic context.
> > 
> > > 
> > > These changes were inspired a bit from kvm. In kvm/kvm_main.c,
> > > hva_to_pfn_fast uses __get_user_pages_fast. THe comment above the
> > > function states it runs in atomic context.
> > > 
> > > Just curious, get_user_pages also uses current->mm. Do you think that is
> > > also an issue? 
> > 
> > Not in non-atomic context.  Notice that it is currently done that way.
> > 
> > > 
> > > Do you feel using get_user_pages_remote would be a better idea? We can
> > > specify the mm_struct in get_user_pages_remote?
> > 
> > From that standpoint maybe, but is it safe in interrupt context?
> Hmm.. The gup maintainers seemed fine with the code..
> 
> Now this is only an issue if gru_vtop can be executed in an interrupt
> context. 
> 
> get_user_pages_remote is not valid in an interrupt context(if CONFIG_MMU
> is set). If we follow the function, in __get_user_pages, cond_resched()
> is called which definitly confirms that we can't run this function in an
> interrupt context. 
> 
> I think we might need some advice from the gup maintainers here.
> Note that the comment on the function __get_user_pages_fast states that
> __get_user_pages_fast is IRQ-safe.

vhost is doing some approach where they switch current to the target
then call __get_user_pages_fast in an IRQ context, that might be a
reasonable pattern

If this is a regular occurance we should probably add a
get_atomic_user_pages_remote() to make the pattern clear.

Jason

