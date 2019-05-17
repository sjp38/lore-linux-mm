Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 826E8C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:38:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473542083E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:38:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473542083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A32AC6B0005; Fri, 17 May 2019 10:38:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DFE26B0006; Fri, 17 May 2019 10:38:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A77D6B0007; Fri, 17 May 2019 10:38:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 351FF6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:38:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so10970006eda.15
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:38:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hu4i0mDDC1ZPRzBSq6z0NH8TYj9tx5wj8BYhnI3jHLo=;
        b=FpN8drwtdWXTsbKqhb5VK0ej6VbvB3i0xLvvsfQHyFpJ8XMPF3X8ak2B+OmGNC9U7K
         T6ROHL2l3SYl07WKrQbmaPl+DHUqi+Zkt5nDnLCpXlqoDggoOstofdj+8nEnvwvn/2q7
         68IC8FOLYOdCJPCu0cIE8HTcKqOvekkkhY9B1xsNUSWMdI+wp5Chdzrlu678ZJ99HyFf
         S1RFXLrG3oDPbEOixhWpSFxK7krLM9pcp4lbDItBamfJIYuvY6tRkIIWfGt8gBptsrQ2
         dP8fqHuw9LiEi7PSZt0eNrZkuaEwwLs+yhhXjS8q1iIgtqlXgkZmYcuAgPrPh3j2L46O
         RqEg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWbgW7M75z1zvYbpRkJlkapym8Xh9V5hxr/WlTbbsDVzlWX4tC9
	OgoFsb4Ie7/u+VcB9Y7gKvxlsVh7dVV0HcHRXzsxyvaZNRQ/cutZWoGwPTHKE3M/ykVglyTeW/Y
	YAd3HhwV3ldnCnwU3ygrQzE1olElSLSnVHyYq+cAV4K8JGdhzGCdZ+qT8HQoefOw=
X-Received: by 2002:a17:906:58c8:: with SMTP id e8mr33549846ejs.268.1558103898570;
        Fri, 17 May 2019 07:38:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH/DdLnxxWm1xM+EOF23olD4avoWNRf8vzkuNn+RFp3mJTJJP3AEXxB83xkiWZurBl1JFm
X-Received: by 2002:a17:906:58c8:: with SMTP id e8mr33549787ejs.268.1558103897850;
        Fri, 17 May 2019 07:38:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558103897; cv=none;
        d=google.com; s=arc-20160816;
        b=QEJDHbGJOjqTla2d+aq/KwVFV2pt9EdQgwMS6KrvriQ1bckzT9sjzUd8XI0KSu99Pw
         y+coP19r79cNCNH6fZt2gYrEy89sKc+9shlX3c8svV+QSCAjbTzzhKwiiXj+G9yN5vqZ
         jG9RakfjYFa0g1VaL6HtZQtca3fcmWywPrJjL5zud1WBVMR8+RDAnZmnP9S/Y08KzTy9
         CrqewvCC+Ci3wja/Il5skWa5KALzrjpn422gWlH9FSRA4iq/4s+HCYBjaadmmrdTUYI9
         DBgR0yklsPEKcikq2MtXN/dHYo3wFHyLi8l0sTt24y0u0oi2rGqSMp3wd+P/z9TDHqeo
         aweQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hu4i0mDDC1ZPRzBSq6z0NH8TYj9tx5wj8BYhnI3jHLo=;
        b=v1RWS+bUjI2MNhWHcjQh9Ep8hMsZOw4je0TGcqVpQeGDmiSFHhYicZtzYIEaPm9eZh
         2X1MCPsEnN+yY0HxSscywfIUkWWub2BEAM7k9NZ2axpoYKO8uQBXhfnfb9Gm0IqJ5KVe
         XU0RSHhp8VN2oSy6UOppm6WjRLIs05ynMjdcf+IW7N60r6amJNwCaxi+2dkE+j0VGIv5
         QVsDiTNg90Q0RKlGGe3fQzVDLZpxk6xL9ar3SrefI6G6Q/f5m9qKh8c9RtozpdnQ2BTN
         Sf3P0Wxt489I0zJbhG1UYLTat4TJ5OE9zz4+2FdKDMme8PR/5dMB8lhUWyLx7Gll0IhQ
         VN2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j12si6046836eda.305.2019.05.17.07.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:38:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2CF3FAC31;
	Fri, 17 May 2019 14:38:17 +0000 (UTC)
Date: Fri, 17 May 2019 16:38:16 +0200
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
Message-ID: <20190517143816.GO6836@dhcp22.suse.cz>
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
> This panic is unrelated to circular lock issue that I reported in a
> separate thread, that also happens during memory hotremove.
> 
> xakep ~/x/linux$ git describe
> v5.1-12317-ga6a4b66bd8f4

Does this happen on 5.0 as well?
-- 
Michal Hocko
SUSE Labs

