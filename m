Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C0B9C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F972186A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:56:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="C4tTREA7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F972186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCC0C8E018A; Mon, 11 Feb 2019 17:56:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C55058E0189; Mon, 11 Feb 2019 17:56:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7038E018A; Mon, 11 Feb 2019 17:56:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6947D8E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:56:22 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a23so569146pfo.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:56:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HpEhd1hjAxTw2MvV1T4BxjxIfyr9u34ZDCNveDCt9pw=;
        b=Wi9pwbQODVUa7nJ8C66LHidDXcHDnOjDxfY6kYNfQgp0udHBQD9m3dKUsM43ETfcI2
         arPidafFnWIeX2XD7JCftgLPe9Kd4cWf3EyUK0YX3DEhMrb3LP8tGX3Fr+0I2asxYdVT
         UAH2+z4IO6nvEsCpuxtvcdclPAJSxRzJ7/uYYwH6pZgEG0bl1K0oqVd+eZcEaC+46QG7
         iePnDyu/r5cEMhitrr0jc2gv6v4vYDoBZKIYfvSZmW1vESj25Pv+PiGCob1Q9IY/RrXd
         vyPhGxRvXCg8RFL3g3xGwL+zTfCpQD/oXz1FyhLjEV2OJFm2So4MiesCrIkc6MoWCNwG
         n8tA==
X-Gm-Message-State: AHQUAuYEPPE9Znh8ySJDIP2eTR2EULPGjzB+xT6gB4wzrY5TZ5CxkRdp
	9PMsW8yzoRpydPXktzOe7F3U3AUzJrykV4qx2+GzkcQez0ycd3S9RckLgukHL/8GCI/8X1npjOs
	Axx0qiPJW6/OgmMoh5H3d255xkWLisUJnaApHKuRrbVumzC0VdH7e+MGGnN17LDSUdxRIsex0So
	BatxEI0lLfoSWH2SV6AZ1OlCCLHJpJd91Q8v+JmgulUQEaNk05fkBuK9ieOTchBx6T5Yrm++rIU
	qUA3x8aHSo3UUpIT6eOWP37VDJK40iI0HOvxlp+FY2wIYtq5uHpcp0b77vrxzvmnzzaDra51O1H
	UtciKcjXfQFeZAKmtr9r6XiWJoEfc7fSmDtGuxRItNficFnbltNTi+0yf6DQT8WipIV8YL9d6zT
	3
X-Received: by 2002:a65:4bcd:: with SMTP id p13mr621462pgr.422.1549925782110;
        Mon, 11 Feb 2019 14:56:22 -0800 (PST)
X-Received: by 2002:a65:4bcd:: with SMTP id p13mr621429pgr.422.1549925781509;
        Mon, 11 Feb 2019 14:56:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925781; cv=none;
        d=google.com; s=arc-20160816;
        b=aJ5IbQ0kRsI6nCw1sL+vyOmHlFWlBGEWicOevU6Pd9Jf0oUstkNl1nDDXfzzK9/EXh
         AaGv8NXGimZ2YHr4/qh3mx7TLHcfSyV8W+obBs166smfWv3UDsgKF6K/NIuW2FBIJZzH
         JfDHv6wEu15727lYPuYjpEQQiUe8wL5I1ykJTnldrT3d0RP7bnjc1MyAGkC5Hs8yJyaq
         FTwsGoJgdm0k760FWVwoJCiwqg4LBI4h4qGwYOH0KOTBCjNJ8zepDIOy+164YARMo/3e
         d2hvXUCr23/p4VzQr/hnFdzJsbyt0MAxRRrcRdMYxA2KOL+pjpke3vWOSRznmmmEvmIi
         6l+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HpEhd1hjAxTw2MvV1T4BxjxIfyr9u34ZDCNveDCt9pw=;
        b=TI2Vyc9GZkKE8uj7ZuA3hPVv1vgwiqcf943nIj3eDurf+vf0xbeQqaCs5eLmnlYj/p
         qUuZqjuugyNTX7Drxd2GrXsf0mwF4WEEflbxc7oNp0PVVUAqw6DwOomQcPo2Jnwxe9YR
         ivZZvPsRx4pSn7zNVejLpjyV99E73WfSPkr4uckMeMtsOkVx0egrg5u89zKuf+S9BEF2
         A71KbOOv5w9/q8mgH6ICBqPEoKP0FEX5/zsowaTP9joaTCzp6i2n1Pv61cgskOR4y2kB
         eDsC/uRuIkPqrjkcRdEpqfBL6kGba8Ivns7XNpmzMkPqS5z/GUsZSLcuDJMTYxyomOCI
         PY+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=C4tTREA7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor16504703pls.2.2019.02.11.14.56.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:56:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=C4tTREA7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HpEhd1hjAxTw2MvV1T4BxjxIfyr9u34ZDCNveDCt9pw=;
        b=C4tTREA7HJPtDyU1uVPrhGE+tenWueSaGN0k0ef/Kh8wHOc+eeRjHW4eNci/W1sNVZ
         nYdNIvPBh0jkuMGegVaVI7ZknSEEmTYjVQ9lkUqwq808jxLyjhyYKUS7PTcL9UCxtB/s
         it+yq0CUlai76H0E960zYXqbQR8MnnrS6MK8skX1EzEWnStU+4GlmKuGyXCUjmhBbpIA
         ESTHk+JdGDgc7/Ph4KMGJJYmCHTvk5TWeSG1yrZVMPtAk3pw1nN/51xgX4GuqGMCDsdQ
         v3NegYxwcxTIMySPBLYjq6QADfr8Cbj0sw8JmSoiCEdCAL1NAbCqVFX55zltezDUhzh9
         STEQ==
X-Google-Smtp-Source: AHgI3IZZHskA3za69Xpd8+FHO3LEV/xrV2vOJSA9kBqr3FxTMFSCZDXTbx2Vmep3HV1eRHv9cAoOVw==
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr677704plz.75.1549925781226;
        Mon, 11 Feb 2019 14:56:21 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id e65sm16713492pfc.184.2019.02.11.14.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:56:20 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtKUu-0003Rw-6N; Mon, 11 Feb 2019 15:56:20 -0700
Date: Mon, 11 Feb 2019 15:56:20 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz,
	cl@linux.com, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org,
	alex.williamson@redhat.com, paulus@ozlabs.org,
	benh@kernel.crashing.org, mpe@ellerman.id.au, hao.wu@intel.com,
	atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to
 account pinned pages
Message-ID: <20190211225620.GO24692@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-2-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211224437.25267-2-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:44:33PM -0500, Daniel Jordan wrote:
> Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
> pages"), locked and pinned pages are accounted separately.  Type1
> accounts pinned pages to locked_vm; use pinned_vm instead.
> 
> pinned_vm recently became atomic and so no longer relies on mmap_sem
> held as writer: delete.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>  drivers/vfio/vfio_iommu_type1.c | 31 ++++++++++++-------------------
>  1 file changed, 12 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index 73652e21efec..a56cc341813f 100644
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -257,7 +257,8 @@ static int vfio_iova_put_vfio_pfn(struct vfio_dma *dma, struct vfio_pfn *vpfn)
>  static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
>  {
>  	struct mm_struct *mm;
> -	int ret;
> +	s64 pinned_vm;
> +	int ret = 0;
>  
>  	if (!npage)
>  		return 0;
> @@ -266,24 +267,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
>  	if (!mm)
>  		return -ESRCH; /* process exited */
>  
> -	ret = down_write_killable(&mm->mmap_sem);
> -	if (!ret) {
> -		if (npage > 0) {
> -			if (!dma->lock_cap) {
> -				unsigned long limit;
> -
> -				limit = task_rlimit(dma->task,
> -						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> +	pinned_vm = atomic64_add_return(npage, &mm->pinned_vm);
>  
> -				if (mm->locked_vm + npage > limit)
> -					ret = -ENOMEM;
> -			}
> +	if (npage > 0 && !dma->lock_cap) {
> +		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
> +
> -					PAGE_SHIFT;

I haven't looked at this super closely, but how does this stuff work?

do_mlock doesn't touch pinned_vm, and this doesn't touch locked_vm...

Shouldn't all this be 'if (locked_vm + pinned_vm < RLIMIT_MEMLOCK)' ?

Otherwise MEMLOCK is really doubled..

Jason

