Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C213C0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:31:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FDF620644
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:31:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FDF620644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6EFB6B0006; Tue, 11 Jun 2019 15:30:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF7B26B0008; Tue, 11 Jun 2019 15:30:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 999976B000A; Tue, 11 Jun 2019 15:30:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6037C6B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:30:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u21so7158690pfn.15
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:30:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fqarlXkDbWo/PMrt5MMtWDMgwEm8qqVxDnTaKcqipZM=;
        b=ogvWy+2XKwOfUv9uowRdikZqtXiFT1F6ds2gqZaWNFOTIdogWc1eXzMpfFa5d3BFp/
         k1mmApuOAYkHcF8ip2nJPd7OAvaWx9vsds3TPqgC5zF941tCaZM/yQJ+zeAE24qTAjtI
         WpA6bbVOW9ROhuG1zc1rQvvHGjUA2PZXgukRm3s91RjB++o1/9RGd6rkcc98dPWi96FX
         hLqJ3aWrLjqBodU5Efh3TNvlZYofqo3XxyRkGTbQwVtbof7hIvjwSTY+bQZhGiLDI27x
         1UbTMYwd1fPs5kHUnrEfinFybLQ+CHKrZXW9pz/hblctU1T+97/yG4G2GEggkWnnjsmG
         bHDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyJb2FrUUmRfOvInwXpDnlGFMdJOHgjeoy9TdseX2x387P3PZ8
	c1kpjMRxvVrBMvL2R9tqLgsleXRYJjfMeLkZgTQ8supYMZbw5T8cdajVeemJ2dKD0pOhFndzUhe
	91x8NAHe7QykO9i+7cDYHo6aC4OObXAPg89j6or78Uel5kJtg2ZJMKTfNsBy8WgkmYg==
X-Received: by 2002:aa7:8c52:: with SMTP id e18mr13071836pfd.233.1560281459076;
        Tue, 11 Jun 2019 12:30:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAi2izO1Md064gEifXCpzbuIOhohQRFrCWD346jvysfD0cGT1EzxKMUUtHywNzBk7gFxMn
X-Received: by 2002:aa7:8c52:: with SMTP id e18mr13071769pfd.233.1560281458294;
        Tue, 11 Jun 2019 12:30:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560281458; cv=none;
        d=google.com; s=arc-20160816;
        b=BAdp9KHk6M04yVPA90eHzkEaQfNat4GK+aBQwoUxL/29WHSnRSDNe5l4BL0bnGjDp0
         YKxSKBxpp04cra3G5PAV1vORgW31zRE4aNONphhtPWQohajsUOGJ+oW0l8myVj/QHtTT
         gH7RSjEDWY7fuMnoSx22HT1F0D3lKloLXTlgePG5XMVJfo0huAypMQzmqjTjKbpAKDQb
         MZ5rA/XD4scuN45ewYKJ3wUJeJy3GhsWjPt4Cv+wGmZ41ub3bu+uV4R+TBKTpdWfwjQc
         BOCuUQITSo6s6m+jz/hT0gSY23scn9lJMVNb1mhutZeJSY5CBY/Vk4QFIhsGCka1iGV4
         Of1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :to:from:subject:message-id;
        bh=fqarlXkDbWo/PMrt5MMtWDMgwEm8qqVxDnTaKcqipZM=;
        b=e0m5cBTX1PFboQnpjtoXxHlODXqKwJLzT95hOmWIlB0Hx96J4NWsHn3wGZ+drK4bjw
         yq3efqCUSYiWYaVoW7Gz6dtqgpzzQKmpXlDl5M8kCeym7YtLXaGTrJzwQIIiZ3fwSxRP
         JAHvasPg5KMcV8J+vTyv15PRF81IXaF43VWtzhgUtDYWWFivGUDx8I/1uj1Y8zVPzswt
         knO/6cpOjtxymaFTk2b9YJ1Ajg2Rgcx0ll9PnmR5mGfzFXEZJZX889pRhskuoYXuOYXJ
         WCtgZh/CKueEuzo1rj+yy98Bq/f7son7ZdaMb2fRa4iJsEZItSN0yzr33Pd0Tex32A1K
         poyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d2si3246708pjs.10.2019.06.11.12.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:30:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 12:30:57 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga007.jf.intel.com with ESMTP; 11 Jun 2019 12:30:56 -0700
Message-ID: <d3d027a903524729454efa235155e5db75216e66.camel@intel.com>
Subject: Re: [PATCH v7 25/27] mm/mmap: Add Shadow stack pages to memory
 accounting
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,  Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, 
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Tue, 11 Jun 2019 12:22:48 -0700
In-Reply-To: <1cfc7396-ca90-1933-34ad-b3d43ae52e08@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-26-yu-cheng.yu@intel.com>
	 <1cfc7396-ca90-1933-34ad-b3d43ae52e08@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-11 at 10:55 -0700, Dave Hansen wrote:
> On 6/6/19 1:06 PM, Yu-cheng Yu wrote:
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1703,6 +1703,9 @@ static inline int accountable_mapping(struct file
> > *file, vm_flags_t vm_flags)
> >  	if (file && is_file_hugepages(file))
> >  		return 0;
> >  
> > +	if (arch_copy_pte_mapping(vm_flags))
> > +		return 1;
> > +
> >  	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) ==
> > VM_WRITE;
> >  }
> >  
> > @@ -3319,6 +3322,8 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t
> > flags, long npages)
> >  		mm->stack_vm += npages;
> >  	else if (is_data_mapping(flags))
> >  		mm->data_vm += npages;
> > +	else if (arch_copy_pte_mapping(flags))
> > +		mm->data_vm += npages;
> >  }
> 
> This classifies shadow stack as data instead of stack.  That seems a wee
> bit counterintuitive.  Why did you make this choice?

I don't recall the reason; I will change it to stack and test it out.

Yu-cheng

