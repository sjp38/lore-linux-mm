Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98586C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 612C72073F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:59:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 612C72073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F35F46B0010; Thu, 11 Apr 2019 10:59:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5416B0266; Thu, 11 Apr 2019 10:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFB876B0269; Thu, 11 Apr 2019 10:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A88B16B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:59:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b12so4411977pfj.5
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:59:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7QmdIg516wwxlnZC6ynDyEAVUceOL67bgRoGU+z8svw=;
        b=agqfREFaNyhnAJL5YvavVbtnCwIvN0HAJZcXu6rtVJNsr03MkVgPUcbqFuWuIlt3xp
         KWR4sK2AfnXlfKMtCA/n5kgAlX0MZBWXvnMenZxPs9JcPwZjAIXKObGM/AwV1XXBm8kn
         mLPaWfWH/yZzORuLes+CJrBkq5TAKySV7MzABvSuIyIdLvbLWjh1nBmds/7VsEisTUfl
         /l+wPQllm/b1HA9Rcgi2zLRC/xFIz/j+T7gkO1FbO3U2+Q1XSW9tXYTKlSviRq2xAHcv
         bLXdv7IK6x3NHGA/VvhVDXnM1OD8OanU2ubpnpkAaspFELOR9PJ6QG8YV0aFWaZCR9BF
         saBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXTzB+PxkHVCeAMvw9eAbOrJ66fzXLCRNZ8eFzTFCvEW22DNl+y
	M1//bLcrn747rS8QeF+pNkYbyy3mBJEWU+4FQqmFOaCLVyx9xrcK61ON9POnw2uJpcO13YCHUdm
	RrI4xx8lkb/QoMhoGH5T5B9aJ2tTkiHpFbF4gZEmi1b/eyg1+OlF3ZtoYHxjYUYbbiA==
X-Received: by 2002:a62:424b:: with SMTP id p72mr32286950pfa.167.1554994756206;
        Thu, 11 Apr 2019 07:59:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTGw4RVt+TbRdLemT22ET5EMReaaIpjHlMj0AfYmxcXu4F5iF+q1fjUJ63OLLhbhJH0r6c
X-Received: by 2002:a62:424b:: with SMTP id p72mr32286897pfa.167.1554994755417;
        Thu, 11 Apr 2019 07:59:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554994755; cv=none;
        d=google.com; s=arc-20160816;
        b=Y90IJdk2eoJcfdZvzcJpmUAxO/X13u1fGtOcX0jL7xWmB7nkXAxMsHFGeDSO6h7zFl
         Ex/rgPNIod2w4KVcz28DrSd0Uun3ZxeGCYFkd0TfGK4OVfSgx4tezLCTWfA6H/wALa4I
         xg95Srtm/2hEIBoRSv/Y4NjhCjKcNKx8BeXP95M3nvzsrV1m3oR/kfAK4TY56vTb/Z9R
         5HN8WVYe7zgJEGt9eTtO31VRUNBbr5AmJ72Ys5PIIiPafXialIAxKf++9xnPGimip5EN
         VIphZXI34h8m7XnKFsv0KmxKmbSSp8Td/S7oOFOMRr06Ym7saYMVKKO1sYMkQApHbpco
         DmXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7QmdIg516wwxlnZC6ynDyEAVUceOL67bgRoGU+z8svw=;
        b=He1zNQMAg06KI5EWPIj/yB8D244cZCc0Wx8k0gRmlPBVKco/bTMIthONsn1E1X/dy7
         U4XYWjA3vIOAvfQHdXEUbsRSY7+oWPzJQhfZIv83jmdWenwLoS33GCNqUGYhzpmPVc4F
         8UfKAa8+sBlYwUK8HByuHA4uznAX0kKRtSmt3Z1Z0akCQzzn/8+qr/wJ3MVdlrm3sQFb
         RBFH98akUegVeqNL52AjlmbbAHARa8YDpCZqRlBXkd/i/M5omboM5l7VLTnUM9298RMc
         twkehEh89kuK5lYfpgnil3WQVPwGTVtgVoFd9HzDA2+BNlY97Ov40U44g2DrCyQCW5uZ
         Mhmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id x13si34693365pll.96.2019.04.11.07.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:59:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Apr 2019 07:59:14 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,337,1549958400"; 
   d="scan'208";a="163411880"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga001.fm.intel.com with ESMTP; 11 Apr 2019 07:59:14 -0700
Date: Thu, 11 Apr 2019 09:00:57 -0600
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCH] hmat: Register attributes for memory hot add
Message-ID: <20190411150057.GA7247@localhost.localdomain>
References: <20190409214415.3722-1-keith.busch@intel.com>
 <CAJZ5v0gOuHSoMd6dnGKN5fW1xKF89b2ak0F4mo+07FBpFUCP6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0gOuHSoMd6dnGKN5fW1xKF89b2ak0F4mo+07FBpFUCP6A@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 04:42:45PM +0200, Rafael J. Wysocki wrote:
> On Tue, Apr 9, 2019 at 11:42 PM Keith Busch <keith.busch@intel.com> wrote:
> > -static __init void hmat_register_targets(void)
> > +static void hmat_register_targets(void)
> >  {
> >         struct memory_target *target;
> >
> >         list_for_each_entry(target, &targets, node) {
> > +               if (!node_online(pxm_to_node(target->memory_pxm)))
> > +                       continue;
> > +
> >                 hmat_register_target_initiators(target);
> >                 hmat_register_target_perf(target);
> > +               target->registered = true;
> >         }
> >  }
> >
> > +static int hmat_callback(struct notifier_block *self,
> > +                        unsigned long action, void *arg)
> > +{
> > +       struct memory_notify *mnb = arg;
> > +       int pxm, nid = mnb->status_change_nid;
> > +       struct memory_target *target;
> > +
> > +       if (nid == NUMA_NO_NODE || action != MEM_ONLINE)
> > +               return NOTIFY_OK;
> > +
> > +       pxm = node_to_pxm(nid);
> > +       target = find_mem_target(pxm);
> > +       if (!target || target->registered)
> > +               return NOTIFY_OK;
> > +
> > +       hmat_register_target_initiators(target);
> > +       hmat_register_target_perf(target);
> > +       target->registered = true;
> > +
> > +       return NOTIFY_OK;
> > +}
> 
> This appears to assume that there will never be any races between the
> two functions above.
> 
> It this guaranteed to be the case?

The hmat_init() will call this directly before registering the memory
notifier callback, so those two paths should be 'ok'.

I may have assumed memory notification callbacks were single threaded,
but after taking a quick look, I think I do need additional locking for
this to be safe. I'll get that fixed up, thanks for the catch.

