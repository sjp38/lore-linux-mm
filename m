Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419C4C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD69B2182B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:22:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD69B2182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45A896B0007; Mon, 17 Jun 2019 00:22:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 409C18E0003; Mon, 17 Jun 2019 00:22:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FA5F8E0001; Mon, 17 Jun 2019 00:22:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E93086B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:22:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so14493324edm.21
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:22:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=z/36DP3vrSplNuogP08fhpfKmN/eRY4AT0uGrjbQH3g=;
        b=CgTgKHYJ6sEWb/l+cyp/BU/n70oe1S35SvzrhghrRlkgxjOAHTyio9v4FhlVlEQLyf
         mZcCx56FN2jZcizmALC4Ju18ZcRsB1TVUO5NAjQ9L3W/GaUlZbtlkCak4G199UBJevDj
         OWEUhhAqaXeG9KAcjrHh0LCXyFlKbCrsLAjF+I5X2gHfPWOrJIfIYD6tgVQ/bsmV4k0S
         kIDy75PCvzePHT/zQpzNRX1cE49vKLWxXw4vY4RIoXIO47JeFPh4zqT8EabXjJHM/x+a
         8SgTypo6KxC8mA6d9ad1upf+IDCqJzxHIFYFy1AF2tAIjh96vAIvdjkSsXEq+IyqNrGQ
         5Npw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVRNVE9OHvccWnn9SK4C3VFkfcsQM8JCOOi7M1qhDtNg6Q3KwRo
	MYf21d6WTOcEJZC9mjLVPqeO6/PrH4dFpFMfaUtuAT2DQgYITAzMnK0v8UtedqFf05VE/ynRim0
	ovbsXCZQ06ArefZ9rPl/5N84LT6X49uVchEvBv9Wia8EzQ3+LVjeEB3Y4+rwkJZMNNQ==
X-Received: by 2002:aa7:d4d8:: with SMTP id t24mr39494490edr.213.1560745367517;
        Sun, 16 Jun 2019 21:22:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgTLHw0WSXfcxhObZqnitiM300bH5AYdP+bB/AIj42KThTNLiCZvxdwJ3rpVo57aCGH9x9
X-Received: by 2002:aa7:d4d8:: with SMTP id t24mr39494459edr.213.1560745366929;
        Sun, 16 Jun 2019 21:22:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560745366; cv=none;
        d=google.com; s=arc-20160816;
        b=roK2FjKn3KFiG7OfVf6pB2Kh0+wQb3AIRUP1+GHYS+Ou/i1+wWhgKjOJ9k6s2avEhq
         19BD9P47Q3PqYmtWdudR3nVhGg9xCVuGU6/5jUTbkeTwpOEyTe7Ws5hEV7wotFZu5N/Y
         MzyvwG6OOYhMZy+D+3trHfcFBSxFKmP7KjozoJtKuclg1KgkFlJnCShZfP6dpQLkUEM7
         Fr8oxZeQihqcX1/YZ1C68VoAt7M+BcG9A35yMdOqMNsiCC8qgKP23Le4YQNQDNCKb5dn
         woMfwzeG/N43LXDuo8idabivRsrRfezeH3FA8v2AfwYCHc55qmol2CioR41wjKZzl+C5
         kNZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=z/36DP3vrSplNuogP08fhpfKmN/eRY4AT0uGrjbQH3g=;
        b=oxFFIzx0xx3UgwTiplep8lM/I8uAdPxOvhG45HZzofW4TKhOTTi2Lti432vv2ieNzz
         yCCa2JkT2BOrl1wovI0LKTORIN8wfTRa9qcHeiey4t8xwQxeyONSKkAFs9xfiM5hQ4V0
         pWazc8ZCROkTHOhWW7203YM78MtcjTIm9yzSqwWFKj2mvauJNIcHADxCpX1ttFwCAgRl
         0Dk0lm0hQ7+eCT1wMllc02eIcWQnSKPUXs4/5ORUJFn1zlmtk27ash5Y/P1SlYBvJdqA
         gIXzEOurtKOiw86UZMJTpqRtps3tGLzevd5J0qlv3q3PvvEwbjbINiF/YLht6gXe5h1J
         0BAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l5si7493318edd.7.2019.06.16.21.22.46
        for <linux-mm@kvack.org>;
        Sun, 16 Jun 2019 21:22:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C5201344;
	Sun, 16 Jun 2019 21:22:45 -0700 (PDT)
Received: from [10.162.42.123] (p8cg001049571a15.blr.arm.com [10.162.42.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4AEC63F738;
	Sun, 16 Jun 2019 21:22:44 -0700 (PDT)
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
To: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, osalvador@suse.de
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cd31db5d-65f9-c02c-bca3-d7c1c456e447@arm.com>
Date: Mon, 17 Jun 2019 09:53:05 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190616023554.19316-1-richardw.yang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/16/2019 08:05 AM, Wei Yang wrote:
> section_to_node_table[] is used to record section's node id, which is
> used in page_to_nid(). While for hot-add memory, this is missed.

Used for NODE_NOT_IN_PAGE_FLAGS case and it is missed for hot-added memory.

> 
> BTW, current online_pages works because it leverages nid in memory_block.

It does.

> But the granularity of node id should be mem_section wide.

Right.

> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

