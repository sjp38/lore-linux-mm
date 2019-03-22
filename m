Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D174C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:06:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6451E2190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:06:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6451E2190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDDD66B0003; Fri, 22 Mar 2019 13:05:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB5206B0006; Fri, 22 Mar 2019 13:05:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA5F66B0007; Fri, 22 Mar 2019 13:05:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFC76B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:05:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g83so2913173pfd.3
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:05:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:organization:user-agent;
        bh=Pt/TcMnbusJwjFDnWcO6rWzM3iTDc+cNsPzs+V9A+1U=;
        b=hlohOL5nRImHY8LyOnEwuKGwI8PQWescWtk2N5cbb5dkcyGRr6nLEMbiYkW27vxu/G
         cz8NN71uLIZz8KghIGiVOMJMdapR7BOX5zcyX66NKNulkhW0BjUqAl+vgqT55HYhlRkN
         oSboFNePnzZgYZabzDFK/jqLfPHRimkIGi+4IW/kzaQtJB3972KF5SSDPpbkXUDJS27v
         KnF4B8MMeYb7aJQRPo/NAAkFxQFLJpAqgF4Kgtav/BbFiqcSEKhzVQ5G4WQRN676XquG
         X7UfNmfa5hRNWoZnU6dzcgdVhh+DCZp9b30g8pOLySjEiXyKXh3usGm8AYB1EeeUAQsc
         nKdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVixMChZ04aw3pbfIFTapY0uY7mVvOmcdlAaRW42qGCcfHdwSfl
	QzTEq6k97WHZDYcOejtH2+H/NvW68et+Ptc98xHSKCvVLtHILZrk81YHiatpPbMNhehlkQxGvn1
	w4/p+s2lcklTQDTkEwTA/xHV0Kd68A36YWIiHPb8C+/0JvuvM6q2tcLSlbQMr/c//Ww==
X-Received: by 2002:a63:c505:: with SMTP id f5mr7121514pgd.87.1553274359213;
        Fri, 22 Mar 2019 10:05:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0QLwgsGbi1jEJjoRnSe++kANhv+NmB7y0YUUk31Toh2GOP3KXcKWyOq/AaQRRQj4+5Fog
X-Received: by 2002:a63:c505:: with SMTP id f5mr7121464pgd.87.1553274358389;
        Fri, 22 Mar 2019 10:05:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274358; cv=none;
        d=google.com; s=arc-20160816;
        b=gZc+FluZqQ83UNsN/e/xpF8a7MjizhdAE9s7eLyiPXVNSkXpLaThAW4JuizRJ93FFi
         vLO6YEEzF8CRi8spbrK1UU/ss/XHfZ/xGEHfHrX2XQlElrtMZXjjgIfQmS84usd997PN
         3rbOyO2/1Q+CFzRr+nRbRg7JJphe+bDJoGVmXlvfxxHyG3aoeQ+QeiN8da1YKsP9SdL6
         VuQD5JL/fXRBAnm2pAW9+7hnR173gNGdNjS7EBX+iiVEyHX5vl/Bnlm+BEU1/K4ZwkyN
         24uYjHS6Ik6zohABgzur5tlfWOtYYJdOo073s7NB4i7zfvp4gZh89azY3rg5e1jQWCdk
         YSTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:organization:in-reply-to:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=Pt/TcMnbusJwjFDnWcO6rWzM3iTDc+cNsPzs+V9A+1U=;
        b=GZNC0B68ya4+E0dzKVz8n9EJpQcJJRxfjkmHGzQJ7AtbI11t8ACbtcicsky89g7Wjz
         Zu1JZ9ccWnYWWVTUznWBHk2r4LqpJsZhPF0o4IdbGqBPLk0rGCxgH5h5XTNrtL0Lj7g6
         KsAO7xuZcsxiCzcuZdZRDIKLNiSZuKnKWedwLYVCPKxbA2zZtngfDN4K2rm4m1a4CjQf
         TU04QZEUrmgnwtgEGj3uCDrH0IfRckKM32m6pPzV26nELIBPbv5ZNIh6G/QPeKnf/hQB
         eA/pKfhaGK9I0Yp8hbGusO2qZkkSNWyEbsZKQNOBiE2JAlCUotUiRvlCEgJUfxMB88iE
         vJSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 32si123651pgz.259.2019.03.22.10.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:05:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andriy.shevchenko@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=andriy.shevchenko@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:05:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="329774387"
Received: from smile.fi.intel.com (HELO smile) ([10.237.72.86])
  by fmsmga006.fm.intel.com with ESMTP; 22 Mar 2019 10:05:52 -0700
Received: from andy by smile with local (Exim 4.92)
	(envelope-from <andriy.shevchenko@linux.intel.com>)
	id 1h7Nc7-0004wO-0W; Fri, 22 Mar 2019 19:05:51 +0200
Date: Fri, 22 Mar 2019 19:05:50 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Petr Mladek <pmladek@suse.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	scsi <linux-scsi@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	Linux MMC List <linux-mmc@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	linux-um@lists.infradead.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-btrfs <linux-btrfs@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	ceph-devel <ceph-devel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>
Subject: Re: [PATCH 0/2] Remove support for deprecated %pf and %pF in vsprintf
Message-ID: <20190322170550.GX9224@smile.fi.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
 <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:53:50PM +0200, Sakari Ailus wrote:

> Porting a patch
> forward should have no issues either as checkpatch.pl has been complaining
> of the use of %pf and %pF for a while now.

And that's exactly the reason why I think instead of removing warning on
checkpatch, it makes sense to convert to an error for a while. People are
tending read documentation on internet and thus might have outdated one. And
yes, the compiler doesn't tell a thing about it.

P.S. Though, if majority of people will tell that I'm wrong, then it's okay to
remove.

-- 
With Best Regards,
Andy Shevchenko


