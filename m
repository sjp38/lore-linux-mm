Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DE17C31E54
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A4412080A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:46:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A4412080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AE6B8E0003; Mon, 17 Jun 2019 04:46:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95D858E0001; Mon, 17 Jun 2019 04:46:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D3E8E0003; Mon, 17 Jun 2019 04:46:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 509928E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:46:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d19so5634157pls.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:46:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=r3nv/jC1xYzb4dCidKqSGlnTBsdSGx2qP6siOmwCpG4=;
        b=Cb7+D7eznEh/FU/HBb/DAMbgqzeH6BwKFoJAhO0hs+WiGMcXo5QUYcr++t4vp7h70Z
         41qE6Ul12/CESnYmLsSEbWJkSOAaaYrA5+hepJlby+RXuNx+JBRLq5UIhkcYwNZKRbbI
         nT7HfomzRPnb7418JHeAYkD2QBB4WDq3GzYf/nSQIVIqyZ4o7CRRW20OPpOh3Liy2I73
         rzvqEA7xcMjsPq2V6RhSTpUOpmQlBoIQKWr5jAnaTqKlzpvMxkuJgokYL7LKkS04vE2X
         Ly0sYpbD5uzH8OUmF4E1vzAhrkidg3ys4IFmGP9Dzlqjxy0vi+SpRigXPeYNVUW2XgAr
         3j6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVi3sJGIWGsv+Be9MMf20VG4xaU9ozuQ1NpN22yJBwjGDaEsrGt
	qw7CZD+4ykdOT4nyE3DIjmT6sVizgqQYMolW1ntzdSoSzdi7Od92nAWjOYxTwxBngP1ooCoZVeq
	gu4mETzpe5wmzKFbvoJzu+XsrdzMpimirPA4+iW8X4Ux2SOI4Y5/MXbg8P2i9YP5Ycg==
X-Received: by 2002:a63:5656:: with SMTP id g22mr33611099pgm.280.1560761196431;
        Mon, 17 Jun 2019 01:46:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJLivwrGdv4mRuWkoxyQl85tNMYBUKGvrH5mBGrTvmA9LrE5kZiLOR0ENq2mT4DEsTJIjI
X-Received: by 2002:a63:5656:: with SMTP id g22mr33611039pgm.280.1560761195490;
        Mon, 17 Jun 2019 01:46:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560761195; cv=none;
        d=google.com; s=arc-20160816;
        b=J/DVN1Se4SyOjKTo8XVVkVuOvoDhdcMymLmfhvPhnM+KIYiKI4uj+wwHNkpUOpitix
         9v6fLTwZdV37goFuQ4cHzT6uP+xoCE4z1iMPTJWAHQlZyaF3ClwQpwkjXePn4ylOIx9i
         08/lmTqyswwO493pUHOZed9IbrH3NxTlTxN6pytYv7AzLQ1ogCj4yd+DRneVX/XrcXkA
         lOkqh5OUkyCWBlnnB6e6b/SwWly7PQvU7R7RE6Vg3sWv0uabQECwx4qtRAwR+MyjQWkX
         Zcisc80M6TlKeB7VMplkDewfA5bUlvtAlMWyBSxZsCuzzIYPDmfEPrBBHWSoE5yIl/Ao
         EXlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=r3nv/jC1xYzb4dCidKqSGlnTBsdSGx2qP6siOmwCpG4=;
        b=dgakjoPcIiERuGQjJr/ACIsVdRtanKyKJlNvyFB8mER/BaoiOTEoPYtCw60ug5HuFH
         7rXhVrdVwADgti/1w27984beSHHJFFyRv2m+/u5VyIX+W+/0p+I0HLvHqVoO+IiGJY1m
         RW9X3aOitP/v257qLb7H+25gzvDL3rfYAnV6LhdaswyKDKz9fX885Np5scBZO834Bz8J
         hRvZoYTGzqzdWxXX/DMvwqp3ilLOq2QwZX3h8b8mM6V81zjb4GysmVBmfSDm8+6MGotM
         Y2vJWNa0/95hQd5MX0sfYjDEyYJ0mGs87rCilSWBPJHeyxBPEMfLcifJlEEjV0V4PYkj
         7JUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z9si10303965pgi.341.2019.06.17.01.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:46:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 01:46:34 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga001.fm.intel.com with ESMTP; 17 Jun 2019 01:46:33 -0700
Date: Mon, 17 Jun 2019 16:46:10 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	osalvador@suse.de
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
Message-ID: <20190617084610.GA8206@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
 <cd31db5d-65f9-c02c-bca3-d7c1c456e447@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd31db5d-65f9-c02c-bca3-d7c1c456e447@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 09:53:05AM +0530, Anshuman Khandual wrote:
>On 06/16/2019 08:05 AM, Wei Yang wrote:
>> section_to_node_table[] is used to record section's node id, which is
>> used in page_to_nid(). While for hot-add memory, this is missed.
>
>Used for NODE_NOT_IN_PAGE_FLAGS case and it is missed for hot-added memory.
>
>> 
>> BTW, current online_pages works because it leverages nid in memory_block.
>
>It does.
>
>> But the granularity of node id should be mem_section wide.
>
>Right.
>
>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>
>Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

Thanks

-- 
Wei Yang
Help you, Help me

