Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9216AC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38C0D21873
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:06:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="Z0EfrHRu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38C0D21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC8956B0007; Mon, 17 Jun 2019 00:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C79AF8E0003; Mon, 17 Jun 2019 00:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8ECD8E0001; Mon, 17 Jun 2019 00:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90AB86B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:06:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so6265086pfk.14
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:06:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=e0do0XeY5On1T95cJdLX7/Y/awSGVRo4MXaFFcTQICI=;
        b=cyDIdzslWxnrZPP6emEm36Pubq+3ZQc/T0eOPTjPTzbPmfPt+tms5GpKrKtR0Kkcte
         PNfJMyZl8f6gMTLiL1JVbPBWSrOlt02F1XuRG55EctPFwK8P8pHYLTxSsOHXGbuhjH2Q
         EOQMZMCuAGRw51ku12BsL7xyWzGTFuIeOutvnujyEAEbdZvyY5w3qTB+rWpQll+/3IbU
         sj5z5BK9Jjvr4C6p20OZRt86Opa6xRWjNDl4GfwMUJD4Mpx9ScTdE3Rh00DLtk4VWwYv
         3EQwYICo7jLMixs5b4/BV3ZwCguBQP/Y6AR51wCg7Kqz6IjUZ2ZHJSsGFa1obeJcdO6Z
         mjZQ==
X-Gm-Message-State: APjAAAVHAoOkTYe0TYu9PFNSR9t2qFuxFI+vpzoBxKKJea0iOhFO2wt1
	CKqBhkJ25RWaHk4hdug5+hAA/ix5EOl9ILHyV9zBrAaDRdkXC9HM56WUo90PFL/twvOnD1I0qYo
	NzR/CRgZW+gZ6w35p7Ln7Pve4oYN9DmsdPMTdKTgB/E2xjEftCfcYC8utE+UUYwsr1g==
X-Received: by 2002:a62:14c4:: with SMTP id 187mr37742940pfu.241.1560744400152;
        Sun, 16 Jun 2019 21:06:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3gtDJJ2/BaU2ORdpXhqK7Pc25Z9ivqWVGqqWwkTmng9WGGaapUScnPlcur9kaNawqhLMk
X-Received: by 2002:a62:14c4:: with SMTP id 187mr37742910pfu.241.1560744399514;
        Sun, 16 Jun 2019 21:06:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560744399; cv=none;
        d=google.com; s=arc-20160816;
        b=GjlnVJ1nbTR4Hv91YUDN4DLVwNBs6FY7zw63FisKdINB6ROYn4Vmye72T+EaLhK965
         BN6xZk1eI20tnT8o269aalXPC+ynb/HC89oKXZzEviQXfuQJvw+6BTCloDDPZWjHt7Dy
         ljmiaGecWsCtb85KPjM+1dZFqev0wLXPbYy0oTQYuYrE1CCSwCbuvQd6pxOY6rMQDAjk
         1/2UzsTX1F3oDbhvp3blTGkAz0nXjrxz18k18rqy3i0ihjXiv1XjIETMXZZV/+v/RMlJ
         OB1GuF8X25j1h7auAmktFXl1tNoa65cG19PIX0/wCdOaVR5wJrtojUNXcofS9gf1Vh3H
         BnLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=e0do0XeY5On1T95cJdLX7/Y/awSGVRo4MXaFFcTQICI=;
        b=N0fXybL2pjANxWMHiQMz3ZNkAPpnN2X7Q2PW2/TaHnSEXRiUs/2jezM72r9bTI54uh
         +MrBLbTqJIMliDcnD/kCAI+YWZ7LJhDq+buTHZaQsHh7ID/yeOmLAoPkpkZEyqu+HBPl
         iFG8biBCXeXur1xFpGURP4OJ7T8stJgIqTOFyK9eyBRg+MXFYjiBH44Wu7QXb/FXcX0+
         M8c5J2K1LcyTIXyNqD/xg0tJWEj5Vvzh5qXA/ltJnhtRzFIeReAgcBhIEQjKXLbmlOT6
         NvhsKCrQFU/YhT3aZfPURie1CwZC/J5fTLuZ2p/9XSC/LaPv/J7d47jMshE89c/t3D5g
         sR9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=Z0EfrHRu;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id m13si9651548pgv.398.2019.06.16.21.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 21:06:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=Z0EfrHRu;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 45RyMJ6YWDz9sDX; Mon, 17 Jun 2019 14:06:36 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1560744396; bh=0cKzGdt6WGsAZB+3r9paweiXCWroPIbVCKopag+ojKg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Z0EfrHRuzCrzprrirgHeOsXdN2MtYJKGs6jXEhmiug8dsUK12ukgYg32hkFCb32M/
	 SEWnO0nlsdQrwLeL95aLHsYI9wNrhfo+dt7avrzQ3v6WFTsS3n8LqE1+R1ZoH1wVOB
	 XhRxaQpvwDQ+wOyiTLrg4oBAuxXIPQbr1gLS9PdXzmBOK3h0TTrb8o7c4DwqDiEDij
	 BtF6DgIrxDxJ3ODFdTsYKOQVtKq7em0JyemWTaH0hwIzAMfahUUjv2X1YXLbU8b0Hk
	 exxEagml3AklSQK/5L6IAQtiDBLPPDNXXL2MENQvKE2dFxXAr28p+NlONIhtySetgU
	 yElL5UmUA4eOQ==
Date: Mon, 17 Jun 2019 14:06:32 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [RFC PATCH v4 6/6] kvmppc: Support reset of secure guest
Message-ID: <20190617040632.jiq73ogxqyccvfjl@oak.ozlabs.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-7-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528064933.23119-7-bharata@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 12:19:33PM +0530, Bharata B Rao wrote:
> Add support for reset of secure guest via a new ioctl KVM_PPC_SVM_OFF.
> This ioctl will be issued by QEMU during reset and in this ioctl,
> we ask UV to terminate the guest via UV_SVM_TERMINATE ucall,
> reinitialize guest's partitioned scoped page tables and release all
> HMM pages of the secure guest.
> 
> After these steps, guest is ready to issue UV_ESM call once again
> to switch to secure mode.

Since you are adding a new KVM ioctl, you need to add a description of
it to Documentation/virtual/kvm/api.txt.

Paul.

