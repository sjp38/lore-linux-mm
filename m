Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35D29C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 10:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B09192083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 10:03:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B09192083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038C18E0003; Thu, 27 Jun 2019 06:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2C428E0002; Thu, 27 Jun 2019 06:03:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF48D8E0003; Thu, 27 Jun 2019 06:03:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2288E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:03:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so5655256eds.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 03:03:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+d5j82Fo3iPYHKkvq5n+DFJOp1qhzd+HosfCzA5oj58=;
        b=oyBSgQ+Edj2wgtXJDy0unl+iajz46rb05fX0pQsIXmh63jQH0XUV2sNLPXALOEyNFD
         6CZ0OyD5UiecvYQDkNslh7YQw1DVskQTIVjWQdXCU0Yle17cbZlRWQAUe0l++X16pD2B
         5dQRwf4nQcVIXyj2Onr6Y6qNE7ZdMjWusuWZhZG4pCjOa/cJyvdIoZz44VZRwMcxPRXa
         NLBe/LtUdpicI2SQHJW3Z/x4ccVtESNv0+RZ21BicxlZVoF6+7xM5OLsNOS+r1IMWyY5
         JdGYNPGXfRRLDfY/StDWZW8PIis4sPokrpbqXW5hyJ0o9A2PxVBiRgFwII7VeMGM21xY
         lV3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUrw/lWgMi0Hw1JuB9oHmKZPCANBwr5OcQhXLaqiamqXZ+aGRcc
	D7WdHzSm+ykdufAsrN81rva1lrxUJv+v+s9bV/UbbVb0KngDMmDS/C/zQX3nRgVBs6OxGgJfA1V
	fT+P/k0Rf5ez1CCyQTr8/bFrSG6NLuWe8rx9lX8Mf6DPGVgT75dhLnuQiEskmez/Bzg==
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr2303411ejb.146.1561629813104;
        Thu, 27 Jun 2019 03:03:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvExhjZy5QaBWbSGQsd6CnTsG2CeCATwPb84skt3nYqd5iJUluuFAI88/XK3wXkkv6Pu3A
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr2303335ejb.146.1561629812242;
        Thu, 27 Jun 2019 03:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561629812; cv=none;
        d=google.com; s=arc-20160816;
        b=IISC4qnT/9CWfCKO8MNwoGmwgmdSIEkOIcsrIlY7/izNlZCgHrhBfGJkhBlAX92zmt
         2tF32QrI339j7HRHL4dYZag+oghr0bUyoPZTG6X4bDIZPNKWCz1VfV+twnCJUOcRVbHv
         tJ2A5ZZAm5iE3Y5sRgCPBEix9ZTCui+figLdVv6mwmtWbeGyfCYibFCgETzdEt5IQSUi
         /RIqANfqJy99TsFmk/W0du4ARWfWvlVRihtjUnyqfoyC8LuGg7TCdSA92o7Wxla2pxel
         rns92H6gUqLE09FIAklELU1NRROiidqmF2COcxQfPczcXh+bSRBiPJcxpfi/5pH/+S3I
         NETQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+d5j82Fo3iPYHKkvq5n+DFJOp1qhzd+HosfCzA5oj58=;
        b=rZk+Mub8FJnyQaykNLCFPCgleuwiDyHw6HnCfVBCvPTxoi5oECuBTRchXbsbbjlywd
         q8sLgGlf2YDivdr/uSlsxuNvbkE9W2vIk6DJGI0kbolwnxeWjcuWECxXhG8AkI4fsyNl
         KG/oChd/GmrohaStF/W128+FQnu4Oyr3t4yBewEqntcFoHYiU260/J0OzMREQp7Q544S
         /mZ3QKBmmvWCUhOVMSAxK+ryEk3upsAZFO9Y0f3cRATxOG0K5t1Wi5SMUNWRN9WtlogQ
         edEULL+L0g1YSMIeZyh8UUrJcIvtwHfLzKZ9uRr8CJaLbi/zfJ6wYJjHQudAaYirWoR8
         MbGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l28si1267820edb.261.2019.06.27.03.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 03:03:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5DE11ABD2;
	Thu, 27 Jun 2019 10:03:30 +0000 (UTC)
Subject: Re: [PATCH] mm/mempolicy: Fix an incorrect rebind node in
 mpol_rebind_nodemask
To: zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org,
 osalvador@suse.de, khandual@linux.vnet.ibm.com, mhocko@suse.com,
 mgorman@techsingularity.net, aarcange@redhat.com
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <ef6a69c6-c052-b067-8f2c-9d615c619bb9@suse.cz>
Date: Thu, 27 Jun 2019 11:59:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/25/19 9:07 AM, zhong jiang wrote:
> We bind an different node to different vma, Unluckily,
> it will bind different vma to same node by checking the /proc/pid/numa_maps.   
> Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
> has introduced the issue.  when we change memory policy by seting cpuset.mems,
> A process will rebind the specified policy more than one times. 
> if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
> Maybe result in the out of memory which allocating memory from same node.

OK, how about this instead?

mpol_rebind_nodemask() is called for MPOL_BIND and MPOL_INTERLEAVE
mempoclicies when the tasks's cpuset's mems_allowed changes. For
policies created without MPOL_F_STATIC_NODES or MPOL_F_RELATIVE_NODES,
it works by remapping the policy's allowed nodes (stored in v.nodes)
using the previous value of mems_allowed (stored in
w.cpuset_mems_allowed) as the domain of map and the new mems_allowed
(passed as nodes) as the range of the map (see the comment of
bitmap_remap() for details).

The result of remapping is stored back as policy's nodemask in v.nodes,
and the new value of mems_allowed should be stored in
w.cpuset_mems_allowed to facilitate the next rebind, if it happens.

However, commit 213980c0f23b ("mm, mempolicy: simplify rebinding
mempolicies when updating cpusets") introduced a bug where the result of
remapping is stored in w.cpuset_mems_allowed instead. Thus, a
mempolicy's allowed nodes can evolve in an unexpected way after a series
of rebinding due to cpuset mems_allowed changes, possibly binding to a
wrong node or a smaller number of nodes which may e.g. overload them.
This patch fixes the bug so rebinding again works as intended.

> Fixes: 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets") 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

(an example of what exactly was the sequence of set_mempolicy and cpuset
mems changes with expected wrt actual results would be nice, but I think
the above should be fine by itself)

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mempolicy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index e3ab1d9..a60a3be 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>  	else {
>  		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
>  								*nodes);
> -		pol->w.cpuset_mems_allowed = tmp;
> +		pol->w.cpuset_mems_allowed = *nodes;
>  	}
>  
>  	if (nodes_empty(tmp))
> 

