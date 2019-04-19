Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBD6C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 12:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 748652229E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 12:54:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 748652229E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C09E26B0003; Fri, 19 Apr 2019 08:54:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB9456B0006; Fri, 19 Apr 2019 08:54:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A834A6B0007; Fri, 19 Apr 2019 08:54:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56EED6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 08:54:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m47so2824008edd.15
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 05:54:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Oil0T49urUPmzyyKnYAt5hq+rYN2/Qchuj84Awe7jkI=;
        b=gaIHqbDW77AR9+Tej0IYflRR2KkvbmbXuDcliPF/CEHKYJ8qg2NmWVStNn6b4w5jB2
         o3H9WYVvxr+5LObiyc7vqSJsM+L3Yo+1HJARpLHgYLsoXTSU1iS9wLTC3BM4rZjxRomU
         6cX/Z7KonsRpc9vCRxY82n9YPlMeecxde/UvJEGxUVd/qSDWs+WY8q+Nv9+uSva8quSU
         zGiVmPCPSJ33/+Q1zZQX6EoTGIK4YUwPIGaQWt1Ya6K7xvMG35ygLzp1gucwHGAVzCKn
         i3Oj+r2mAdTEJFqK3npsb9XHQ7xXfjZJg8ASsayGA6sIB1tqzHfGJZZO55g19frm9WlK
         5AgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWo4BFTiSacfBydnr58TZxPhtzVb1Sm8Sn4ccTiF+HeJsho8Jhm
	mWSIMx2T7sFjfl7r04RK/s0lIVOQHsMpha8XrKzYffdSjIreHKQRjtxGn7tVtLOgU8oAij+MtBd
	UC4koRQz1W0o4pAXMFWiX1vkYH7t02z1G3QU96xIU13mVul5KOxInvFHQxq4CgIqekw==
X-Received: by 2002:a05:6402:390:: with SMTP id o16mr2268333edv.156.1555678488684;
        Fri, 19 Apr 2019 05:54:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRFnB1Jd6bqFODaGkMKuLWV3lfh7U2ZbiukxdykQLh1ooXExMHQjOVOIpa2dLk14pXHh2A
X-Received: by 2002:a05:6402:390:: with SMTP id o16mr2268289edv.156.1555678487516;
        Fri, 19 Apr 2019 05:54:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555678487; cv=none;
        d=google.com; s=arc-20160816;
        b=C/g1SKPTD4Odcdd6qY65QY8LMRKIJ98i3E9WIdyLyRCyAqPxfVYIq/Eam7Jv9rM8FD
         kP9Qr3r1QuPr7aRaFk/jNFI8fXQhqTjyOBIAHq4crjYImA/VXJuyPYQtcuA0sMQA+9K6
         PvONIvhU89/+CdlB/PA2li7ftil+29p9LqGPmX6HVdjnuZvMCvuqU9z2RDLIQrAgYhio
         PeqRyM4tev3Ku3/sC6BV36q2ATVdHstrooiST+s828OURyfeB6NbqTVx6VkmcCW8Pqom
         vBic/4XzUlgT4V/DajyIT/uUvyJcmt+eEvzOsJiLKGZzQXXNzDL0pmgLqBIebPwDhXQi
         A4MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Oil0T49urUPmzyyKnYAt5hq+rYN2/Qchuj84Awe7jkI=;
        b=I7nORxGISZ60TnNhR2IsUrHKtCKHAjY2SJuNkknsPG8VSmXFLFxlBa3VRyUXC//fWj
         RpyzHcM9S5JQw53iajctA4v1nt9XCcqA/7ztbWTCe7bWowIU/cl6Q0BTqJ/WHv6nhwRO
         cwGlNx/2PBEmf9BGpDjnQIRwCxjrEO42966pxTG+0IHGtcQ4HB+Q0t47Dgl4Kic5ZC1x
         91AoGJuS48DaGDRO/cmraO1yzbMPACF8Yu5csRfJgCeJW1p6bZ6tLajISRU1xepNzc5/
         oAzZK4HCDxWJuXWK5lN4jYdmelk+xa/d+EFGCZQBQk4x3Vfm3ouLXC6zaVj7OvtPvyUl
         UmcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si2250155eds.357.2019.04.19.05.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 05:54:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73BB6AB7D;
	Fri, 19 Apr 2019 12:54:46 +0000 (UTC)
Subject: Re: v5.1-rc5 s390x WARNING
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Li Wang <liwang@redhat.com>, Minchan Kim <minchan@kernel.org>,
 linux-mm <linux-mm@kvack.org>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
 <20190418135452.GF18914@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <bc039ea9-c047-5385-36c1-00b706cfb91e@suse.cz>
Date: Fri, 19 Apr 2019 14:51:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418135452.GF18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 3:54 PM, Mel Gorman wrote:
> On Wed, Apr 17, 2019 at 10:54:38AM +0200, Vlastimil Babka wrote:
>> On 4/17/19 10:35 AM, Li Wang wrote:
>>> Hi there,
>>>
>>> I catched this warning on v5.1-rc5(s390x). It was trggiered in fork & malloc & memset stress test, but the reproduced rate is very low. I'm working on find a stable reproducer for it. 
>>>
>>> Anyone can have a look first?
>>>
>>> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190
>>
>> This means compaction was either skipped or deferred, yet it captured a
>> page. We have some registers with value 1 and 2, which is
>> COMPACT_SKIPPED and COMPACT_DEFERRED, so it could be one of those.
>> Probably COMPACT_SKIPPED. I think a race is possible:
>>
>> - compact_zone_order() sets up current->capture_control
>> - compact_zone() calls compaction_suitable() which returns
>> COMPACT_SKIPPED, so it also returns
>> - interrupt comes and its processing happens to free a page that forms
>> high-order page, since 'current' isn't changed during interrupt (IIRC?)
>> the capture_control is still active and the page is captured
>> - compact_zone_order() does *capture = capc.page
>>
>> What do you think, Mel, does it look plausible?
> 
> It's plausible, just extremely unlikely. I think the most likely result
> was that a page filled the per-cpu lists and a bunch of pages got freed
> in a batch from interrupt context.

Sure, good point. Per-cpu lists make the scenario even more rare, but
once it's full, there's a higher change the batch free from the
interrupt will result in high-order page being formed.

>> Not sure whether we want
>> to try avoiding this scenario, or just remove the warning and be
>> grateful for the successful capture :)
>>
> 
> Avoiding the scenario is pointless because it's not wrong. The check was
> initially meant to catch serious programming errors such as using a
> stale page pointer so I think the right patch is below. Li Wang, how
> reproducible is this and would you be willing to test it?
> 
> ---8<---
> mm, page_alloc: Always use a captured page regardless of compaction result
> 
> During the development of commit 5e1f0f098b46 ("mm, compaction: capture
> a page under direct compaction"), a paranoid check was added to ensure
> that if a captured page was available after compaction that it was
> consistent with the final state of compaction. The intent was to catch
> serious programming bugs such as using a stale page pointer and causing
> corruption problems.
> 
> However, it is possible to get a captured page even if compaction was
> unsuccessful if an interrupt triggered and happened to free pages in
> interrupt context that got merged into a suitable high-order page. It's
> highly unlikely but Li Wang did report the following warning on s390
> 
> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190
> [ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
>  nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
>  des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
>  libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
>  ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
> [ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1
> 
> This patch simply removes the check entirely instead of trying to be
> clever about pages freed from interrupt context. If a serious programming
> error was introduced, it is highly likely to be caught by prep_new_page()
> instead.
> 
> Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct compaction")
> Reported-by: Li Wang <liwang@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Yup, no need for a Cc: stable on a very rare WARN_ON_ONCE. So the AI
will pick it anyway...

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..cfaba3889fa2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	memalloc_noreclaim_restore(noreclaim_flag);
>  	psi_memstall_leave(&pflags);
>  
> -	if (*compact_result <= COMPACT_INACTIVE) {
> -		WARN_ON_ONCE(page);
> -		return NULL;
> -	}
> -
>  	/*
>  	 * At least in one zone compaction wasn't deferred or skipped, so let's
>  	 * count a compaction stall
> 

