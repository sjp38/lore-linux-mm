Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D638EC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A05EB2070B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A05EB2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399638E0003; Mon,  4 Mar 2019 14:13:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 322D08E0001; Mon,  4 Mar 2019 14:13:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EC758E0003; Mon,  4 Mar 2019 14:13:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5C5C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:13:48 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id c188so9540733ywf.14
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:13:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aK0M0EiBqkVrwI5zhtbHcvzqiuEwqS72VfobOx94u04=;
        b=UdtiNdYZClTRsMFNuiK6kVZKv9NTSNLMZDkZDKTvkeRVKbKmPzTEB/okwDIv2uKOU1
         D02gyjM20d0Jo5dr/ZO56lcAXw5NoLD54LKRh7QTLsc/XLyE05jCytfAG3dG/hos/DfJ
         vkSsY+t2MLcs24L4WxzCR4dkhsSlK344V1+fXjTSE9Pib4btQy28/LTHUhP8qHOIPLVV
         rkmsHImzEt8I1SmWj6lKpvXWTJu1Fvk0hakN/W3VuaVXjj6giefD4Bp/vcSbhQUyZta3
         keZLgJjQaG2RR8m5BS7X+EKN4JCs9Iw9ZbNIya96gcwbRoYWPCBLaI0B+Y8Y1fkaqasT
         4kUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVh6YIp19kATUS1Q6AXNUyBVzRYaEHvcAAOUvt7iSdo6pRzeqYE
	UAWeaKMWdgSb8QA7WMoFwk8UP3g1nKdWHB+2fk9H62K00TShFq9jxXm14FUvFXAMomjrcgbpXUZ
	T6uzW+5ZCtgZmsRO1Upr6DlVVhz9q0qQIFtvQ/gNejRAKuViMzoacbfUfr/Oa+7kcuVquU9eQg+
	p6czvUvxoH6zrNtxEnCPvRlMS7PtQG6k9z21moyd3FcSCRo9cNcHcFMllTT99dDxxp6vLWTqRsT
	4zLSTsjXK9ut9azbl0RSElc84vlAls0R8XCbVTm0qscLFgqr7uvOeVqHnEy3kAf/TvENk44uprA
	2HiB6VKlohyaHizbIW6hZCO0Pq3ZZhaxA/fbuQUyGPQUavlqy5qSDuPkcm/rIy6M/M2DLJMv/Q=
	=
X-Received: by 2002:a25:abe6:: with SMTP id v93mr6138900ybi.378.1551726828587;
        Mon, 04 Mar 2019 11:13:48 -0800 (PST)
X-Received: by 2002:a25:abe6:: with SMTP id v93mr6138861ybi.378.1551726827972;
        Mon, 04 Mar 2019 11:13:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551726827; cv=none;
        d=google.com; s=arc-20160816;
        b=0za7cqpDVrc1DQZ8uzycIvOonWgqEJoABQQNwpyoEd1cjJZKC2gfwppcAiQm3ThbHs
         q3qRLRgeraBSfw9S53G/QBwehhoG31DkziWyFsryGpxXLpHTtpxCA73k03sdk/U0WxPg
         hZTmqumz99YcAyf0fiujTaqG7Fx8b/4nH+ivyDSpo6Lb7vqxkXZqodEMVpL9xz18j7DJ
         NFNEbJclgm51v/ZgQ8udUEiOpkyaa1aKmiGzlZ3evAOEUfQAXR5jVx8/Lj0w6ob5TLTu
         jdnykWCwmfMJh6pfYHHnfmMC1czv1g7rNXOV7b17lYIKSA6a7ShsYY2vcWHgDHGMkLQn
         QBiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aK0M0EiBqkVrwI5zhtbHcvzqiuEwqS72VfobOx94u04=;
        b=TUfkkW2oRRG3dL8KLMo/C28hQh9uyLiMZU9zsDbVOVNSTkj39zOOFywVMVk6VRZqZv
         X4UUr37pfHFZYcwuoz0skZO/MawxyxRJvgilOYBFL8t2cT8yUZgtHmZIAT3FzwTWbjAS
         eWUWLMGki2CI+XRkVs95mLQdkxDhmFa5rRpNE5su+QvFwxq2umM7Rp/ycjsoMgHhWxdZ
         AsROc+YiRgnALlas+9uNuTeITMxtYMX975InXOEdLwCTX+6D76FZwvO+BUZUpqC+LDz6
         uUu/o486o6rWMLhlKWlGV1f9m98INKSb6J5AWg3Yz+fx3wdmdUcB52v6mPLW9RDEdgbH
         NbNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o13sor3077548ybp.24.2019.03.04.11.13.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 11:13:47 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqx3uSLSfjeKLSN4KzA85sxETmTJc3iojCUNRzzqn3SqaXb3qkSgnP+LcswtZobNlwlYzUER3g==
X-Received: by 2002:a25:2f91:: with SMTP id v139mr9660229ybv.407.1551726827678;
        Mon, 04 Mar 2019 11:13:47 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::1:8d76])
        by smtp.gmail.com with ESMTPSA id s186sm2989973yws.13.2019.03.04.11.13.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:13:46 -0800 (PST)
Date: Mon, 4 Mar 2019 14:13:44 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 1/2] perpcu: correct pcpu_find_block_fit comments
Message-ID: <20190304191344.GB17970@dennisz-mbp.dhcp.thefacebook.com>
References: <20190304104541.25745-1-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304104541.25745-1-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 10:33:52AM +0000, Peng Fan wrote:
> pcpu_find_block_fit is not find block index, it is to find
> the bitmap off in a chunk.
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
> 
> V1:
>   Based on https://patchwork.kernel.org/cover/10832459/ applied linux-next
> 
>  mm/percpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 7f630d5469e8..5ee90fc34ea3 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1061,7 +1061,7 @@ static bool pcpu_is_populated(struct pcpu_chunk *chunk, int bit_off, int bits,
>  }
>  
>  /**
> - * pcpu_find_block_fit - finds the block index to start searching
> + * pcpu_find_block_fit - finds the offset in chunk bitmap to start searching
>   * @chunk: chunk of interest
>   * @alloc_bits: size of request in allocation units
>   * @align: alignment of area (max PAGE_SIZE bytes)
> -- 
> 2.16.4
> 

So really the block index is encoded in the bit offset. I'm not super
happy with either wording because the point of the function really is to
find a block(s) that can support this allocation and it happens the
output is a chunk offset.

Thanks,
Dennis

