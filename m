Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB820C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:48:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6F8A218D0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:48:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="gp70rwtR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6F8A218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C2038E00C3; Fri, 25 Jan 2019 01:48:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 171958E00C2; Fri, 25 Jan 2019 01:48:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087D18E00C3; Fri, 25 Jan 2019 01:48:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2F4A8E00C2
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:48:10 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id t83so4031902oie.16
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 22:48:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3Mv5wuebRzoalbCk7v0arDMNle3VSxPxLSOwttSePtY=;
        b=LGllKdJujPp6aMsB/a+ESub7/uEsSmkQShObFjUSnoCfvZsrnNDlm8jSeB7F9H3/uQ
         tGDUk8/tomPRCsQlcV1sHKXB2urqR1jCzkhp2j3d3AJKFlkueA22DE6E//Obsf0e51TH
         ZCvAoiGECTRATWjH1CFee3iXTK9OqEotjmJ+IfuequHOVtMEYlFBKJ/RLsJ+5PDu3vfi
         wVAs/CnLfPSmBMSKjUpBlLAHe1fQafnBKdzkzKSqDTYZ1a5u8SQg24bMpKUEjN+ZbU9E
         rxpRRfAZzegFlw1HuLEeZC+gF2PpYWwyD9KYr3Z9Lty3ubQi9MtyGNdsFNowpbczkgqp
         t42Q==
X-Gm-Message-State: AHQUAubA++QWocPEKaXisvjayYkM9N9hQQ6odFaT4zYrq75YgmQxguBE
	ZZuq0FR006M9oza7SdRpo+HNu+Trj4m6n+Pgba/N8cMPfa2vJBtQrAZRqKmvtwVYqLxWnjehDTD
	2Hm7XdJII0YTH81q//YkBYiNLeXsvb5ri/lC+c7wYiWReZaj1c0myok+0g0yRheZDfqzVIeQoMi
	Ld1QBmDJbusIhvH4yXobNA8hBvjvL5R5m9JOkTXWc+Mv3BshpQtdyIVvlDdoRjBIoucSWRbKAUV
	zgw41c506qIcI1oTZUnv5R2QEv0WIeGiwb9oSWSJrEYmGkRIDJzz8nMXvs1y+8wClwDYm/shKz8
	iJH8XT3crFtveR6DcB5UdWl0ENsJtG7XJUZ4cC7oE5Gxx1Wq1WD0ST2nAGScNjaeGdZMLuZiNwA
	S
X-Received: by 2002:aca:6995:: with SMTP id e143mr527279oic.283.1548398890556;
        Thu, 24 Jan 2019 22:48:10 -0800 (PST)
X-Received: by 2002:aca:db41:: with SMTP id s62mr495324oig.349.1548397689398;
        Thu, 24 Jan 2019 22:28:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548397689; cv=none;
        d=google.com; s=arc-20160816;
        b=XKBsB0hOtXVAjdGoyFGpYeF75WqVtjYEyCfVzs5Tab85d5D2hDcvVmA3jigy7CNiBj
         vq7lzQ1MuOfRR9Y2mnFqntTkg41DRVdm4bv6IdlIgvLdidzsEav1uXyG5y2cOuEjmUz4
         AoH6OLuSeBimAo9g08RYV+IfRQLgrzCwTpjIUTPG9XiRAiiUXWzHGujSXO7IQoDMn1GQ
         k2Yq8qJqrMt71fZ4lviBRGYSQv0/qoLQS0jkpThroffF6H11rNDcUD6uZzmi6K6B4aTe
         ujAKr4PD6CQWhVwT2T13FvzmvcwegVt6LwxyidI+DwFIOmea7/WcGnCpO2NIc6tvav3I
         TBlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3Mv5wuebRzoalbCk7v0arDMNle3VSxPxLSOwttSePtY=;
        b=tymUeRE5muU/+QHLJcvqhFPwYOUCGiFwkg/FKjhwsmoIlKACgapkXUkMBz1pfhcM10
         yR+LwDjanm+037VVHi0wWrYPtC3QAcCxeAebeakYFV+9a/Jh5Gtk9JUR9P9/rG6zAKkE
         anc5jRbRFUJ/Q+OVhQxkKewcVMONjZgYT0wqKfACg+RPyTuTCARKTRoLWC/0wkzcxU43
         2ROJDXcVZhUUgWihxzOfcMV2KA6ir+la6ljsgSkRCs4yTICq5UX2+WEfqJ9ZMu39lqmP
         3N6EBOe8y8JMSFMwykZuf6jD7TjudPEgVysD4A0wu7HNox8ztRUdv8MZADNgmHzxRkH4
         +gYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gp70rwtR;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor1101094oix.68.2019.01.24.22.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 22:28:09 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gp70rwtR;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3Mv5wuebRzoalbCk7v0arDMNle3VSxPxLSOwttSePtY=;
        b=gp70rwtRHbqz/Kj7KbZjRxy4Tiu+ZnkP1IVeLNRLzlqV6rncaLAO5NAGYGjGXoS8gK
         ghskggWCWW0/Y56HMc6J0RP/BEDdM+5S89h/5Cy1fqiGtUUAVQyXB/ORHmUGRy/oVpFD
         jMCs5wh+ZhweLK8ozanvFtp4ieRPha1WYgQeDsmnm9fl4UFMzOYA94+DeZs4uNwwoCdY
         +DxPEymsYhIVEz6R2Y6Vl89GH6bbLXa3U6ALFkXcsWfSqmY7Me4P6C8n9ndQBhvMktgI
         rRBQhQzH2Ybhz13Z/tt62bSi5xLOJbx7thOHGBEegMudekMopSbTeJ/KfrU9TP18CIEM
         DM2A==
X-Google-Smtp-Source: AHgI3IaAd7/Bz4rL67ZFLiO3E0QWfxNZbkq3MoXd0sjw9uIOtxAfi2CtOXobVGBBel159D3EmKXvi06BZYuigPT2ldQ=
X-Received: by 2002:aca:2dc8:: with SMTP id t191mr502126oit.235.1548397689037;
 Thu, 24 Jan 2019 22:28:09 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
In-Reply-To: <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Jan 2019 22:27:58 -0800
Message-ID:
 <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: Jane Chu <jane.chu@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Takashi Iwai <tiwai@suse.de>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125062758.cuaqhDTUPH-IcrPjT5gloNyN6FPcI_3fPA5fH1rjoO0@z>

On Thu, Jan 24, 2019 at 10:13 PM Jane Chu <jane.chu@oracle.com> wrote:
>
> Hi, Dave,
>
> While chatting with my colleague Erwin about the patchset, it occurred
> that we're not clear about the error handling part. Specifically,
>
> 1. If an uncorrectable error is detected during a 'load' in the hot
> plugged pmem region, how will the error be handled?  will it be
> handled like PMEM or DRAM?

DRAM.

> 2. If a poison is set, and is persistent, which entity should clear
> the poison, and badblock(if applicable)? If it's user's responsibility,
> does ndctl support the clearing in this mode?

With persistent memory advertised via a static logical-to-physical
storage/dax device mapping, once an error develops it destroys a
physical *and* logical part of a device address space. That loss of
logical address space makes error clearing a necessity. However, with
the DRAM / "System RAM" error handling model, the OS can just offline
the page and map a different one to repair the logical address space.
So, no, ndctl will not have explicit enabling to clear volatile
errors, the OS will just dynamically offline problematic pages.

