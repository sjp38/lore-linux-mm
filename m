Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6004AC43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27218206B7
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 15:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27218206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC9708E0004; Thu, 10 Jan 2019 10:53:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79958E0001; Thu, 10 Jan 2019 10:53:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 990CE8E0004; Thu, 10 Jan 2019 10:53:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72D1F8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:53:24 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so11116960qte.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:53:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=MqPUnGW6hxwx5xiDIJtGsXepgBBsBxpz8FBpp46aWC4=;
        b=Xl3ekbHaaPJLLzVZbcNecvZs9xYcrvt3A9b/4d53IROSMxrCaqTvDnx0q3IfMEequB
         WpEsUJt0DgzWvgeZsBEwLvUQZ+jBO031+CKQ7YrSHKS7xyiAD5klbbBDcqFzYcXJp1l0
         DsxLEunu7IFDMVhM8xUJzi5MFwxTYHajgmqfCRYk+6dQfgTG0gFlfa/uDzjRxDy4u1gM
         gmAvl6SOfbkeElk0uTIR4FE8utdqLtFWg0qWsxZx3PCGGDu4nEMHeTqGjlSs0I2TFiN4
         iYdUQgDNbct2KS0XNKfrgFuUM9gx0pmyyX/mPLhcvyEELzZleg4ZrMLWYj/qOYTWCdGD
         9osw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdK9T0oSOE+vxMTj8PdfBeZJY6h3HhlMCbb8eTvxJa/yifQy0kO
	ZlfIRN4CLvFLM+2O/Q4OQgiX+tm9evuRqXQaM1Z2XKZnPMXXk994RSjoTphBuPC3nNI6PVZZrT/
	mHwR3AWjyUcjUwFs6jxr9hiExJseLe/53dj8MiwF2eXQq43c6yJItXPAK+RfNbRUnxQ==
X-Received: by 2002:a37:f706:: with SMTP id q6mr9361414qkj.96.1547135604150;
        Thu, 10 Jan 2019 07:53:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7AxmJWmfBmP9kgw87++SFq7fegHWUI1xHCzvWMVhWgOOnguuF2B/Rd/Z8C5RpToRYikU5p
X-Received: by 2002:a37:f706:: with SMTP id q6mr9361375qkj.96.1547135603420;
        Thu, 10 Jan 2019 07:53:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547135603; cv=none;
        d=google.com; s=arc-20160816;
        b=bwc7I4sbLKdqy3Qn3GEgKhqVKyXKePpeS0YkGltRbW5QVMmEabCvKryGFsketQ2WjZ
         y3zhxTtusoD6j8BT4m65MP/Jzaxi75Y+AMFGjIIIuvNFFWd9KrEKaBx3tzEbMYY/JXJ6
         4AtXkRthdKGlz/3nrxaRCp8v5MF5pRpvfh5B/Ddcxti6mUskLjhznFpeVYYA/e6hQ2Sk
         lNJz83RPqw9T+rLuVI4vaAO2mmIk9RItXcJywB4ycUnrbk8c/ViV7sTsuGHIpjMyFKnq
         yVIPUCsvXFEXsz5i9KEFmmhMJZj9w4TEbZUxWiSOnu3mA4tHn7rWvRUibhtDSLC0q8mr
         8wBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=MqPUnGW6hxwx5xiDIJtGsXepgBBsBxpz8FBpp46aWC4=;
        b=0pjK1xRK4nPilNZvVJj8NKdwlO1COMYQJp7DdhU5WC3zHYbNQQDeQC3AlQdMtNDfd8
         IKUkfL0PWIK6c8zgS/mgQntug28cahV7BBatxX5FWzccAvyhRwt6SBlMcSVTtxcdQ62J
         0a0PYy+w205lvdWnguy1WNDi7tefoPgsdUycC/xEmPLO4PEZGLfQ+Al8b86qYudurrRK
         5ei/FsxcEnKtRqz4evnmCMKlmwjYUPNWDK6TT8dk9VNspI0emTXZfKByHQNzDMQhxNTN
         rCUYPCnf/tVSW5HU8dxKqhwuB2TXdqOc1ugk3/aQvUa8TSflFXGGNSmlVJ8mT7PTDZUP
         UOXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n185si227214qke.100.2019.01.10.07.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 07:53:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C44CE4CEA4;
	Thu, 10 Jan 2019 15:53:21 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.215])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9F9108164C;
	Thu, 10 Jan 2019 15:53:19 +0000 (UTC)
Date: Thu, 10 Jan 2019 10:53:17 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	linux-accelerators@lists.ozlabs.org
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110155317.GB4394@redhat.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
 <20190102122110.00000206@huawei.com>
 <20190108145256.GX31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190108145256.GX31793@dhcp22.suse.cz>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 10 Jan 2019 15:53:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110155317.xJn5VFkMrzh7J26i7CEFiVKaNLjsTUeCjnhKPcFXhW4@z>

On Tue, Jan 08, 2019 at 03:52:56PM +0100, Michal Hocko wrote:
> On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> [...]
> > So ideally I'd love this set to head in a direction that helps me tick off
> > at least some of the above usecases and hopefully have some visibility on
> > how to address the others moving forwards,
> 
> Is it sufficient to have such a memory marked as movable (aka only have
> ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> it fits the "balance by migration" concept.

This would not work for GPU, GPU driver really want to be in total
control of their memory yet sometimes they want to migrate some part
of the process to their memory.

Cheers,
Jérôme

