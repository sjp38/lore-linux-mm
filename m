Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD706C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:26:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81AB920818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:26:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="KdWHadNe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81AB920818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E4716B0003; Tue,  6 Aug 2019 07:26:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 295D46B000A; Tue,  6 Aug 2019 07:26:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 183DC6B000D; Tue,  6 Aug 2019 07:26:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D77726B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:26:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x1so5662799plm.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:26:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eQDxozI2qjukpUkcofnkYlDLvFKSd1P/XqoYuWp8Iko=;
        b=qfOYerQv1cEWVJvQgD+IiD/KifM5qYxCvJB7mMJDfg5Lahv8myUKot25hMDVW3n0j3
         IAabiQxykTArns1DWM3mRz5kBXHpCB52+WqjOkY7iUnwQ0LzYrgWYIB8YL57SsMWHcwL
         RUrS9FBo9RRblCw7l5NLVnCj1bc+OBJ37SPLAtIei3j4dTW2U/Tss6Z1WhlKq/P2w/fU
         Xq8vKVNV3YDwMiDoDR5rI/iLQf1zIb+cZJyxZO5PLcCceJUXuq6odjHXD92byhrRHVTg
         Q7Lr4z7P+1OmPscTKK0+NhcJZBRcf5CvJCQUgWTzvHToAa3DNTShEtqgOVTPn2MjJ0LN
         BxZg==
X-Gm-Message-State: APjAAAUBRCRdV+Q307fE3MXrfK2+kNN4Sd7mEwtJ/dudPlaTdnn8Nwmu
	LaUILTWmAGj+EEU7dqrMFOq3P0zei54ulQqnE90XChW/UQaqdQtjruk9LckwbALCUy57O0BIbqw
	yYL4L/eFd8eaTRzlrQH1eTrvKMhYWBl4XI3NTKwUWrnbgFw9yJae7cDh1iyrkDy2PvQ==
X-Received: by 2002:a17:902:e281:: with SMTP id cf1mr2622097plb.271.1565090769563;
        Tue, 06 Aug 2019 04:26:09 -0700 (PDT)
X-Received: by 2002:a17:902:e281:: with SMTP id cf1mr2622061plb.271.1565090768958;
        Tue, 06 Aug 2019 04:26:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565090768; cv=none;
        d=google.com; s=arc-20160816;
        b=jXgmjmZt+igEG7WXHArdzFW6MiIwxYW7iJ2AzQBlmoeOAvgagfnghEp6JElI9tgEUq
         teBp4FFPfWbTYhs50BBXUQ+umLxjnz2inC5f5vySLaawC3CT/BLOV1p3htA1+lw7gm/2
         ttW1DebksAolYZaxBs4J1XsTNjrirniUJffzJDEPFYKzfTeG1vBLBSZMocMuAfa3P+ui
         QFm/7vJTBufaZQFkudouWlO3/06Si0ON6kn0pP53T2d4GqCRQH9LQJb+g13V5DI7FY5F
         n9S3yLYSZsXc7EZLkgTVKM+yr6CzY83cB+M002kHsVyCRgErtk37CLEbWD3aXjuFKHE8
         iQnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eQDxozI2qjukpUkcofnkYlDLvFKSd1P/XqoYuWp8Iko=;
        b=fO8X5WPy0eqMrvhFIDaAkhTPQrct1qn7V9wSYA8nphS2mcyjG4NIBbMqjyc0nav2Nn
         6DEhBllNFeyzCjxwvshhWpuXgDlatnjk6MBTLHZAqpOzyKl0LoHIR9tMWPGV8bAP+z4i
         BGJJQrXuNN7fHdlDZUudtMe3cBZkEstj2PzLRwahmgbeEG3weRO/VVvccSCNHVbVQ3Qu
         rItLVXMnpn//E6NmrN8bYNRNF6aVixq03shbC0e3rH+75pJ+LQC63Wuo9beJwUeBuHKg
         v317sCDWreHNayLbU76fnvOzoZ/orNNpQybp1QQHX2mv8o7QF4E4ujpuTkTcBo9stl4W
         ZkOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=KdWHadNe;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go5sor102969488plb.37.2019.08.06.04.26.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:26:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=KdWHadNe;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eQDxozI2qjukpUkcofnkYlDLvFKSd1P/XqoYuWp8Iko=;
        b=KdWHadNeW6pa2dnhFD6vGAJeFuZ4bU94l8h5hGmJoB6iVklb97AFdq2hkigQMM5/UW
         duwzf5xlAas4hj7F57fOHGW4Fbh0eAqKIwiEUMntWH0rzszBSsXQxg7vmdW0vXnYKvIV
         u177tjd2FQ7ASDBdqt2QwZ/5p/Ocdpipr0UPw=
X-Google-Smtp-Source: APXvYqyhzcoKkLyUNInxKHTRQ0D58ehVR/MM5voEdZBk61kMSmPqKu2JfV8+IDkI8ipd4TE0B17EDQ==
X-Received: by 2002:a17:902:a413:: with SMTP id p19mr2767311plq.134.1565090768446;
        Tue, 06 Aug 2019 04:26:08 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id h14sm113010833pfq.22.2019.08.06.04.26.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 04:26:07 -0700 (PDT)
Date: Tue, 6 Aug 2019 07:26:06 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806112606.GC117316@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
 <20190806110737.GB32615@google.com>
 <20190806111452.GW11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806111452.GW11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 01:14:52PM +0200, Michal Hocko wrote:
> On Tue 06-08-19 20:07:37, Minchan Kim wrote:
> > On Tue, Aug 06, 2019 at 12:47:55PM +0200, Michal Hocko wrote:
> > > On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> > > > On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > > > > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > > > > This bit will be used by idle page tracking code to correctly identify
> > > > > > if a page that was swapped out was idle before it got swapped out.
> > > > > > Without this PTE bit, we lose information about if a page is idle or not
> > > > > > since the page frame gets unmapped.
> > > > > 
> > > > > And why do we need that? Why cannot we simply assume all swapped out
> > > > > pages to be idle? They were certainly idle enough to be reclaimed,
> > > > > right? Or what does idle actualy mean here?
> > > > 
> > > > Yes, but other than swapping, in Android a page can be forced to be swapped
> > > > out as well using the new hints that Minchan is adding?
> > > 
> > > Yes and that is effectivelly making them idle, no?
> > 
> > 1. mark page-A idle which was present at that time.
> > 2. run workload
> > 3. page-A is touched several times
> > 4. *sudden* memory pressure happen so finally page A is finally swapped out
> > 5. now see the page A idle - but it's incorrect.
> 
> Could you expand on what you mean by idle exactly? Why pageout doesn't
> really qualify as "mark-idle and reclaim"? Also could you describe a
> usecase where the swapout distinction really matters and it would lead
> to incorrect behavior?

Michal,
Did you read this post ? :
https://lore.kernel.org/lkml/20190806104715.GC218260@google.com/T/#m4ece68ceaf6e54d4d29e974f5f4c1080e733f6c1

Just wanted to be sure you did not miss it.

thanks,

 - Joel

