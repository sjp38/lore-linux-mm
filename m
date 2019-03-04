Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 149FDC4360F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 18:57:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C779C20663
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 18:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C779C20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68DCB8E0003; Mon,  4 Mar 2019 13:57:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 615628E0001; Mon,  4 Mar 2019 13:57:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DE6B8E0003; Mon,  4 Mar 2019 13:57:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20EBF8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 13:57:03 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id l11so9371795ywl.18
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 10:57:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G5rTsdLogr4Pn426CZ4doead2CWwStaw19gK8aVjylU=;
        b=KX66PTpNDRYmvSosr9vupAjdOOvowwiqv/hEQ1XsURzSTz0wB97wVMPAQvv82JKINv
         Y0EIbkGQSD4PQ9qlEiD2Wzzn7cRNrx40J/wUzf90Fyx7RBK/saup+oJI/867m1diw21V
         oW6TQvyyRvc1FBOks8699kIwpElNM6bhBMEtLzQ5gUdBxJoZKMxTvPdwB2ufqexKDR/J
         AYeeIIjgD9wY83N8XICyL9J0+hEZnIevmniGmtq/G9rtlItHUgrKWWIhIkaBEvQJtzqy
         V0pupd6Np0EHabu877ZJZ0FFpNsQW+D9JyN5ECJb5rz5uK13DRszCCmwzQSXSjd3gcDc
         QDrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVZd5Zfy2iXDywDgJ/72zNLKUoJ/aAV5r8z92rHLlIKRgD41Xk8
	FnZD/6zWlDVXQ+fEUZM047qrrGQWV7XxPbonWzcd7h2IX9E/7quil9lpKu8R4mhHNqjjusd0jBz
	hPSdcmFHVC3F5vTfXZU5so60faIgEXzIXwJc37NniW3/p/ixQtNfZrbrYoeVz9T6sVjHbFLz9a0
	IiwRPgkGS9PYNDRZuxIe72mcK9qcFkbcphEJHP2qVJRETYlt6DZeKP7mKCNZewbIHLkH4rcR8nL
	6xkIHlIvxw2VunrQb4eByfs7wyYbuxF8KUc5zRhLc/Gf6qkoq/+zPRl82LRhJLX4UNB3w5v5e8/
	fVEjl8UY1ACkJUpQGR07uOMeHr9uuMsYjGtvoLkDaLRIOlvCRtLDrafnbNrZf9gS4aR7kaa+4A=
	=
X-Received: by 2002:a25:e45:: with SMTP id 66mr16386684ybo.519.1551725822849;
        Mon, 04 Mar 2019 10:57:02 -0800 (PST)
X-Received: by 2002:a25:e45:: with SMTP id 66mr16386626ybo.519.1551725821664;
        Mon, 04 Mar 2019 10:57:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551725821; cv=none;
        d=google.com; s=arc-20160816;
        b=kg0QTxxjCyuQdYsxZIdF0RGoTjI75e9p58JaP34+8sYnvK2zvd9WwW5TCOa4vZUOM+
         CwTTSdjnrgQhQ4QBF0RnbPxYsWRyvNbbTs3fb2UDqv+cNyRhqD6pp48zreUYvtoLgOdr
         DT39iPAoWiauwK9vBV2u3ziQypez7QUv+2MchqBi4JmfN7MlF4leva+vDbD0NM0eQaeu
         h2SyNa+TgI5jCd27DSUErnPfdc2yjkVH3fe2psTDkFCo0mtLq7+pPTMpnkxoUoMikPKs
         DaUxeWApVXXy6ZQHC6PZ80RNRtNE+1K1VzeVSjEs6k656IS+gZYvs3+eERUBdzzcXRD0
         /Z8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G5rTsdLogr4Pn426CZ4doead2CWwStaw19gK8aVjylU=;
        b=FJYhdc6dvlxmsnk6WwfZFZ92gQXTMhBplUImHKxO/CPokewNBrhuejS/3rBDIWYJ+V
         /CmYAl7N3PAg84oScSveooObSFUDXV75P2iZTwju8reIUGNhIP4w/ZfUu9h7M93vMC6n
         yoritySnUkmOGVh3mi3m1qeb8/A4N+6nK7oRuzMCNF5VthZzW8ANBD2ckQjn03dzonAd
         aDkovf/OBk4SXzQaUHIY5GBX6Ncqx9pKVZzezxlETOc/wioDtHTvmECI5Y6J4Ex/skeg
         nD8xqJOChWPJAQYI07VJAF2I6RNHUcX4L81XlD3HDGpnrkq9TdWn8hVO3dbTS40fJdEw
         /ESQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j127sor3370422ybj.150.2019.03.04.10.57.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 10:57:01 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqztRwnWv3pEawsYV9qGAllROIkrxq4e/0Xg9sZbcOXkL9oitOsG1/kCKgLP8oeAMJulyQT5bg==
X-Received: by 2002:a25:949:: with SMTP id u9mr15934919ybm.98.1551725821353;
        Mon, 04 Mar 2019 10:57:01 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::1:8d76])
        by smtp.gmail.com with ESMTPSA id d85sm3189818ywd.96.2019.03.04.10.56.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 10:57:00 -0800 (PST)
Date: Mon, 4 Mar 2019 13:56:57 -0500
From: "dennis@kernel.org" <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 2/2] percpu: pcpu_next_md_free_region: inclusive check
 for PCPU_BITMAP_BLOCK_BITS
Message-ID: <20190304185657.GA17970@dennisz-mbp.dhcp.thefacebook.com>
References: <20190304104541.25745-1-peng.fan@nxp.com>
 <20190304104541.25745-2-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304104541.25745-2-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peng,

On Mon, Mar 04, 2019 at 10:33:55AM +0000, Peng Fan wrote:
> If the block [contig_hint_start, contig_hint_start + contig_hint)
> matches block->right_free area, need use "<=", not "<".
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
> 
> V1:
>   Based on https://patchwork.kernel.org/cover/10832459/ applied linux-next
>   boot test on qemu aarch64
> 
>  mm/percpu.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 5ee90fc34ea3..0f91f1d883c6 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -390,7 +390,8 @@ static void pcpu_next_md_free_region(struct pcpu_chunk *chunk, int *bit_off,
>  		 */
>  		*bits = block->contig_hint;
>  		if (*bits && block->contig_hint_start >= block_off &&
> -		    *bits + block->contig_hint_start < PCPU_BITMAP_BLOCK_BITS) {
> +		    *bits + block->contig_hint_start <=
> +		    PCPU_BITMAP_BLOCK_BITS) {
>  			*bit_off = pcpu_block_off_to_off(i,
>  					block->contig_hint_start);
>  			return;
> -- 
> 2.16.4
> 

This is wrong. This iterator is for updating contig hints and not for
finding fit.

Have you tried reproducing and proving the issue you are seeing? In
general, making changes to percpu carries a lot of risk. I really only
want to be taking code that is provably solving a problem and not
supported by just code inspection. Boot testing for a change like this
is really not enough as we need to be sure changes like these are
correct.

Thanks,
Dennis

