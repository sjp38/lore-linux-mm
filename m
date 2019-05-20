Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42ABEC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 07:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E444220815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 07:03:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E444220815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C0636B0005; Mon, 20 May 2019 03:03:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 348956B0006; Mon, 20 May 2019 03:03:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9DE6B0007; Mon, 20 May 2019 03:03:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C37E96B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 03:03:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h12so23617238edl.23
        for <linux-mm@kvack.org>; Mon, 20 May 2019 00:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mx/fQvFr8GDZBdTCUR8uRj1/+9gf8OnUPoCyNEkC9D8=;
        b=Wy+k8QklwhLzkvDf8Itr/9MFo3LX50lKmDnTcQuR1eL6Xqqoxcsk67EbvbWVPb3G99
         sp3ycwRo89e8rSXz3Ip5qFRavTeW+gF65ztVEJHwBHa2hgHODc5rgIbXnySKUHu2W5Nw
         TpH6eHSCRICUf3seq2Yp8a9nzcln8oJVzjVR0YLR3E/aFPwCyMnxataDK6SEVIdr5K6O
         7JPKIkG95a7NgdjOW0NifqupyH20CkaQMwA1LH7xpLLKL06E3L2VeaMaOYfw49n0Tnb+
         lezzE+EGewPoOMVSVQ+3VFUSsx25iOjo3vXglyOB0hfgi6VAbaAFmoDne2ocJpL5IOmY
         YleQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUg9MvnPCos35TymNPWEJ1rQE7nbmp1QnAbDMkYEZABp6n8sRPj
	NH/l2hWF8LsNb3FZPlnHKMfW8HC2cnaTCuvQmQpqS6vEZtlhXc6w5+aPRJgIuIkirvGD+cGyv1z
	AahVqWvZIh55pM1DEhakuuwL0kr2RLQ2vZlgX4Aq21DpNiILZ2pY3eOWGzvawdgs=
X-Received: by 2002:aa7:c402:: with SMTP id j2mr73932831edq.165.1558335801382;
        Mon, 20 May 2019 00:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1B2x/QOD9Eq51wCnwfHdlhNETgYz9rSw0woJQUGPrsJOuTXDHsIqeMMR2nQFL8G1C3czQ
X-Received: by 2002:aa7:c402:: with SMTP id j2mr73932763edq.165.1558335800541;
        Mon, 20 May 2019 00:03:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558335800; cv=none;
        d=google.com; s=arc-20160816;
        b=bqdjrtiZ/QDdAxaBTkLk8fdFEvmFFlU9dGctunIXlIRmRjZcEO1XZoKKImVUhCvw/U
         kmdkcUzNQ2FI3ghGIk4oZ62w/zxEyJ48nTsn0T4Yl+ax0RIsFm/1pM0NnK1FoFkXUc6K
         0r2ZXhWZJPk5NjA9JvrqZYQbUyy22/2DT8ZwjX0GpAeyhkA4tirRoEPMMBTUgnF4wvpZ
         x9YqPJlaqH1zbNQfPtvCRqC3tiNx9dFY1Yuf0/BEogP5VAbtkFhy5XeA8Z+Si2ewS4ch
         ZioeVIXq+cOb/wY4FCIHv0Zj+RnJXL5GadlviV5KeFNXKYGxWn/dO4Mh1JG05Kj8EaMO
         wSLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mx/fQvFr8GDZBdTCUR8uRj1/+9gf8OnUPoCyNEkC9D8=;
        b=UL8DQis4EhkonspPRWhxE4M4arL9uqSnW+uIDzCYtRHVEvrkH+pfsE7VhWJrMZZ6Ub
         ieYhJYeZIGb+Ab7jL2ir0mr86Ne2NYrp3WcLF1qoC2RuHWnHTHhEm52AYnXcbwl7+hjo
         iCBKDHdB7FbBh9pLkI4m1d5sEEzJVYObthu617Pp/Y4AVFxTEUCCHLSx21RbKo7MtG7E
         EJaK7TBsedpXJ3YLQjhvJSEHEqABfJ5z9SCP86232l8Ls5JpTvN47a3xIrrGmPBJNA18
         cMWkN9FAJ5BuS3oaVstB/NkoTcieu2ILyCcGx+U+SrrCw/CjtxJ3MOGC8Q07ByY7vmMQ
         Rdsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e52si11883462edb.265.2019.05.20.00.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 00:03:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6293CAE48;
	Mon, 20 May 2019 07:03:19 +0000 (UTC)
Date: Mon, 20 May 2019 09:03:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"tiwai@suse.de" <tiwai@suse.de>,
	"sashal@kernel.org" <sashal@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"david@redhat.com" <david@redhat.com>, "bp@suse.de" <bp@suse.de>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"jglisse@redhat.com" <jglisse@redhat.com>,
	"zwisler@kernel.org" <zwisler@kernel.org>,
	"Jiang, Dave" <dave.jiang@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"Busch, Keith" <keith.busch@intel.com>,
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"Huang, Ying" <ying.huang@intel.com>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Subject: Re: NULL pointer dereference during memory hotremove
Message-ID: <20190520070317.GU6836@dhcp22.suse.cz>
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
 <20190517143816.GO6836@dhcp22.suse.cz>
 <CA+CK2bA+2+HaV4GWNUNP04fjjTPKbEGQHSPrSrmY7HLD57au1Q@mail.gmail.com>
 <CA+CK2bDq+2qu28afO__4kzO4=cnLH1P4DcHjc62rt0UtYwLm0A@mail.gmail.com>
 <CA+CK2bCgF7z5UHqrGCYu4JgG=5o6uXbjutTo9VSYAkqu3dqn5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+CK2bCgF7z5UHqrGCYu4JgG=5o6uXbjutTo9VSYAkqu3dqn5w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 13:33:25, Pavel Tatashin wrote:
> On Fri, May 17, 2019 at 1:24 PM Pavel Tatashin
> <pasha.tatashin@soleen.com> wrote:
> >
> > On Fri, May 17, 2019 at 1:22 PM Pavel Tatashin
> > <pasha.tatashin@soleen.com> wrote:
> > >
> > > On Fri, May 17, 2019 at 10:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
> > > > > This panic is unrelated to circular lock issue that I reported in a
> > > > > separate thread, that also happens during memory hotremove.
> > > > >
> > > > > xakep ~/x/linux$ git describe
> > > > > v5.1-12317-ga6a4b66bd8f4
> > > >
> > > > Does this happen on 5.0 as well?
> > >
> > > Yes, just reproduced it on 5.0 as well. Unfortunately, I do not have a
> > > script, and have to do it manually, also it does not happen every
> > > time, it happened on 3rd time for me.
> >
> > Actually, sorry, I have not tested 5.0, I compiled 5.0, but my script
> > still tested v5.1-12317-ga6a4b66bd8f4 build. I will report later if I
> > am able to reproduce it on 5.0.
> 
> OK, confirmed on 5.0 as well, took 4 tries to reproduce:

What is the last version that survives? Can you bisect?
-- 
Michal Hocko
SUSE Labs

