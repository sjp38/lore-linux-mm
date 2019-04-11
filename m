Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FF8C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AA8F20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AA8F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1584E6B0269; Thu, 11 Apr 2019 16:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1068D6B026A; Thu, 11 Apr 2019 16:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F117E6B026B; Thu, 11 Apr 2019 16:11:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0B176B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:11:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y7so3672408eds.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:11:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=JKvQz9IhtW3K86EwtdMcJ9G8ihTRQXOBDTfeIETRrPQ=;
        b=Q/k6AK9UnKu5Qhgh1CqZFfUsiwrBqpoRxrbXcLYtkB2w9duZAx4dv97lFN2lBgn7DC
         VfBht+FPZHY8HBEQlDgktBxA6KYDamU5ixlLfp3IrU7jpvtOxj4JCxjkvILCUrafk8CY
         53sASfgkqktgJslapodLVAmayX9nor68eR9UgVwKtLMXTCTqzrfFs5UHej0Euw6P6B5Z
         ZbAD77k4Wjwo7qO68kCUWwulB0TUnQsyfe5o3n8TwxRxRzscXiUaSt6t7dtViOs5Xo8u
         s6eomDZGdB1imwA+/OqsEHAg64/YGTD10fZob3QTfG0ZC76sCKlFGV1jkYk+7Nj1dAg+
         qN5w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVH3mGJu/ENdiT4tX6XFzkIjMTKQ/bzRMnE913lchxAaQhJi4V+
	9NvlHQAH+v0xGqreHBOUcbs7aBp/YlzQXKB07QW/niWXrFLux37PWXwYOBvDK5NMdtpabfzv6lm
	fKTAO2sHLTuwYc7TcFgGUp7v6voTRvaP+atcYoNlUELbtVsHQEYLaNQVa1ys0cfE=
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr19162417ejg.98.1555013515140;
        Thu, 11 Apr 2019 13:11:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVB3eGy5zvOM+l/RNgcBF9Ss5drvfT7H2fSuJJwlPeyR1GTrnEPa7159AHU5JbviiynE2X
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr19162383ejg.98.1555013514211;
        Thu, 11 Apr 2019 13:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555013514; cv=none;
        d=google.com; s=arc-20160816;
        b=k9QdGNOOG1j1UJWlOOaLukqRRcTsVukapPo15tE+6VYHF9T/TnpwwagGg9dRhJqzZJ
         E3Y3hrmkiVaMCbqmoXkEkCrcyXKpZ1JX42ukENhwAZNDMvWc6KSrw66UnAV0gR//NLpV
         bnLAy7YT533vCG2Es3kZNQAMssMsUySwPcdoNikFnzsJXfqxrMWjsTdSSZyaM7XCZ025
         9vwd5GOx7AjW8J8m3R5wZN0KdKb/j9epMVACDWrz/z5Wd/V6HUERGvLAOy+XwH/mJxGW
         v4rngRh89aOv0GT+YqTBSTHfSSrcFDKetl0+bbWZpB+dNzd0U2s2f6VaOdR8Z5LL1AXG
         vMqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=JKvQz9IhtW3K86EwtdMcJ9G8ihTRQXOBDTfeIETRrPQ=;
        b=YMv2Nrc32AWNmNLg4RmAxINODczG+L36+/mwrhOX8k1JpkD40h0MaMIfuMNQz5I9cW
         Vazo2sgMRVQEJh3v9k6eHqhgL1N9i414l3jIAwTGWYi5I6lOzpird3ogaU1XG9jz/j6b
         1kGtWW46fizq6Q8tefh1vLV0jTta7B7kElc3SN7KBGfQUmRAXr6Cio+RdWqYbRKNBzjh
         w4FiDcIMY0Lm4SMMSDu/30uns27c9kd8NK9025TSGbzOHPV+QB6t8M2mCjCKSVOdpk8J
         7vko3BIvzKsnS3nhuQUuzLCRSnlM48f6M0Py1qD3nqITCO3CI2gQ+alVneohp4lBPzZA
         p9wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si1780934edt.141.2019.04.11.13.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 13:11:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1E911AE0F;
	Thu, 11 Apr 2019 20:11:53 +0000 (UTC)
Date: Thu, 11 Apr 2019 22:11:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Daniel Colascione <dancol@google.com>, Jann Horn <jannh@google.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Cc: Android Kernel" <kernel-team@android.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411201151.GA4743@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
 <20190411181243.GB10383@dhcp22.suse.cz>
 <20190411191430.GA46425@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411191430.GA46425@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 15:14:30, Joel Fernandes wrote:
> On Thu, Apr 11, 2019 at 08:12:43PM +0200, Michal Hocko wrote:
> > On Thu 11-04-19 12:18:33, Joel Fernandes wrote:
> > > On Thu, Apr 11, 2019 at 6:51 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> > > > [...]
> > > > > Proposed solution uses existing oom-reaper thread to increase memory
> > > > > reclaim rate of a killed process and to make this rate more deterministic.
> > > > > By no means the proposed solution is considered the best and was chosen
> > > > > because it was simple to implement and allowed for test data collection.
> > > > > The downside of this solution is that it requires additional “expedite”
> > > > > hint for something which has to be fast in all cases. Would be great to
> > > > > find a way that does not require additional hints.
> > > >
> > > > I have to say I do not like this much. It is abusing an implementation
> > > > detail of the OOM implementation and makes it an official API. Also
> > > > there are some non trivial assumptions to be fullfilled to use the
> > > > current oom_reaper. First of all all the process groups that share the
> > > > address space have to be killed. How do you want to guarantee/implement
> > > > that with a simply kill to a thread/process group?
> > > 
> > > Will task_will_free_mem() not bail out in such cases because of
> > > process_shares_mm() returning true?
> > 
> > I am not really sure I understand your question. task_will_free_mem is
> > just a shortcut to not kill anything if the current process or a victim
> > is already dying and likely to free memory without killing or spamming
> > the log. My concern is that this patch allows to invoke the reaper
> 
> Got it.
> 
> > without guaranteeing the same. So it can only be an optimistic attempt
> > and then I am wondering how reasonable of an interface this really is.
> > Userspace send the signal and has no way to find out whether the async
> > reaping has been scheduled or not.
> 
> Could you clarify more what you're asking to guarantee? I cannot picture it.
> If you mean guaranteeing that "a task is dying anyway and will free its
> memory on its own", we are calling task_will_free_mem() to check that before
> invoking the oom reaper.

No, I am talking about the API aspect. Say you kall kill with the flag
to make the async address space tear down. Now you cannot really
guarantee that this is safe to do because the target task might
clone(CLONE_VM) at any time. So this will be known only once the signal
is sent, but the calling process has no way to find out. So the caller
has no way to know what is the actual result of the requested operation.
That is a poor API in my book.

> Could you clarify what is the draback if OOM reaper is invoked in parallel to
> an exiting task which will free its memory soon? It looks like the OOM reaper
> is taking all the locks necessary (mmap_sem) in particular and is unmapping
> pages. It seemed to me to be safe, but I am missing what are the main draw
> backs of this - other than the intereference with core dump. One could be
> presumably scalability since the since OOM reaper could be bottlenecked by
> freeing memory on behalf of potentially several dying tasks.

oom_reaper or any other kernel thread doing the same is a mere
implementation detail I think. The oom killer doesn't really need the
oom_reaper to act swiftly because it is there to act as a last resort if
the oom victim cannot terminate on its own. If you want to offer an
user space API then you can assume users will like to use it and expect
a certain behavior but what that is? E.g. what if there are thousands of
tasks killed this way? Do we care that some of them will not get the
async treatment? If yes why do we need an API to control that at all?

Am I more clear now?

-- 
Michal Hocko
SUSE Labs

