Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA4F1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A51A92184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:32:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A51A92184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B9B38E000F; Tue, 26 Feb 2019 12:32:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369848E0001; Tue, 26 Feb 2019 12:32:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25A028E000F; Tue, 26 Feb 2019 12:32:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8F088E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:32:42 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id i129so9278936ywf.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:32:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YPrsT0iUOY7Hfj5aR8jhnnzYbP/I7ueC+KO4Fv97uXg=;
        b=TCOF0Y4WcD8w+W4WuyKtKNoNyWN/2hjgDCG9n8j6jEuQBrX9mYPeI4FQmacyf3fAeu
         cqW7NT4G7GddopINoLKjNTCPWQ0aZbKLjCAWFXpfRA2611B3u8Lgu7fN9qqbfLuWCPAR
         JuKnOiSX4xSk9IFqyP003OwCG4SySVDjqxxFenO5mEyBYabSDKuHzlfrOhnf3alvIQCW
         BFIPG4iZjRspzhGCk4yFygpOK5lnhG12HLlBKC3fpTZtr1Sa0nDb/kMqDkhF6/up6HF8
         hKvShR4EC1HAnwPkaT6aZDJemT9OlDviGmf4MZjOLI3sB/O/zNKorbHldhuy0rbhn/pC
         WxrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZOjlfJMFw+nX/7gAkj07CVsrWsO8e+pGYeO2KHs2isXEdx7W3/
	xHYe8DCN46hzwyUnDtGI+w3GdCio7Y757MsH51UKH6mL2m65+U7DdJRNvOT9avYW2VKuSQl5Z3Y
	TbAkzFgGvSbV2gWdca9AoMUaqoTSOTHzi3YyspcW9uhMPNFCPPSEQhf48qiQG9kh/X658g7SWyS
	9xAnkFJR+AxNx8oZgOvUv1EQtzGixPDFTVV4OFYhXRlW6cgT8uUq1+vYuxeCz7oizb5ppNx5C+w
	XYrfFG96LoTRQeVAeFDuBjAAFCT4F+7mxthD5J6Z9xsZRz5DrDmzCGMnDWd3ynLta8kvbvRF/vu
	6wLLSUFQDIgZlde4CO8FmoPCfFKdtVPgbZFIAElOp0AVc7dfoCsGKi3sCVd3hGIorkZj+1LKPg=
	=
X-Received: by 2002:a25:e0c5:: with SMTP id x188mr6556130ybg.376.1551202362603;
        Tue, 26 Feb 2019 09:32:42 -0800 (PST)
X-Received: by 2002:a25:e0c5:: with SMTP id x188mr6556075ybg.376.1551202361863;
        Tue, 26 Feb 2019 09:32:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551202361; cv=none;
        d=google.com; s=arc-20160816;
        b=VQzxbTsLRvEYLChDaph4DGCsHLHE2S4ZsrbV6reSFMkRFz038ELrqxPCYErvEfl/AF
         FuApbfXkwvizaOo2vP/gdDHGrKLYOu/VKyKxgc6EGfwQSQdBTGFgyJyrqekyh+tf2Ock
         HGvIiimnqKmbQztNjDR+LgXrPD9j8lhAYM+dg8gXKAfCYfc0chV1SWC7H2JbMoiKLgcy
         o1V0uabNHEtUc7aTl9mhgCJNVK2OrFPh/kZd0IazeEKbNLcf1Kc7vAEQLpwT+bcr6V9m
         kO5vYagnX57j1mSARpRm073b/7hsVUiqxKwarJ2b9b9Mckqt94Kta2Z7KLzZsu1XSXal
         V9DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YPrsT0iUOY7Hfj5aR8jhnnzYbP/I7ueC+KO4Fv97uXg=;
        b=CL6t3fyG3jeiVoDt9DylPZY9ab/yIHtdQrCzsz5pwwKCBL+m4dls1peN5KF9dEsgwd
         F1L84tr9lhNIcS0MaNQrhmLCMUmB3yGEiewYBI4EjW4yxaQU3FQZ9mkEMUNJfXyhcBlw
         JrHkpyqQfPu6/DeEn0FiHvV1kXhyHlYhqRALe6odz85TwWlcS+N/1E7AgFPwzTFLH8K5
         +/iAmi+do44rK2Gl70LCrsKA/UKNXMgHAUDUQl2SYT5Nl7HPracvp7pW0w9uPcSADpOt
         6KkYG9faDDor+Wl1nfF0pvoNJonA0bpI2nE8f+6ZzY8bih2WBFVJHMhhQrBbGjEyOhK6
         L4RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b18sor6020222ybk.8.2019.02.26.09.32.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 09:32:41 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbpWGDG7vBxnzM6stZTh/e/ZSGPj5DrSdOTWwDbhT6+QaALuc9u8ORlAEJ8/fV8JjyZ5/ttEA==
X-Received: by 2002:a25:484:: with SMTP id 126mr16832681ybe.409.1551202361314;
        Tue, 26 Feb 2019 09:32:41 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::2:7f17])
        by smtp.gmail.com with ESMTPSA id x130sm4295523ywa.78.2019.02.26.09.32.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:32:40 -0800 (PST)
Date: Tue, 26 Feb 2019 12:32:38 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "dennis@kernel.org" <dennis@kernel.org>,
	"tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
Message-ID: <20190226173238.GA51080@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224092838.3417-1-peng.fan@nxp.com>
 <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB448161D9ED7D152AD58B53E9887B0@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB448161D9ED7D152AD58B53E9887B0@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 12:09:28AM +0000, Peng Fan wrote:
> Hi Dennis,
> 
> > -----Original Message-----
> > From: dennis@kernel.org [mailto:dennis@kernel.org]
> > Sent: 2019年2月25日 23:24
> > To: Peng Fan <peng.fan@nxp.com>
> > Cc: tj@kernel.org; cl@linux.com; linux-mm@kvack.org;
> > linux-kernel@vger.kernel.org; van.freenix@gmail.com
> > Subject: Re: [RFC] percpu: decrease pcpu_nr_slots by 1
> > 
> > On Sun, Feb 24, 2019 at 09:17:08AM +0000, Peng Fan wrote:
> > > Entry pcpu_slot[pcpu_nr_slots - 2] is wasted with current code logic.
> > > pcpu_nr_slots is calculated with `__pcpu_size_to_slot(size) + 2`.
> > > Take pcpu_unit_size as 1024 for example, __pcpu_size_to_slot will
> > > return max(11 - PCPU_SLOT_BASE_SHIFT + 2, 1), it is 8, so the
> > > pcpu_nr_slots will be 10.
> > >
> > > The chunk with free_bytes 1024 will be linked into pcpu_slot[9].
> > > However free_bytes in range [512,1024) will be linked into
> > > pcpu_slot[7], because `fls(512) - PCPU_SLOT_BASE_SHIFT + 2` is 7.
> > > So pcpu_slot[8] is has no chance to be used.
> > >
> > > According comments of PCPU_SLOT_BASE_SHIFT, 1~31 bytes share the
> > same
> > > slot and PCPU_SLOT_BASE_SHIFT is defined as 5. But actually 1~15 share
> > > the same slot 1 if we not take PCPU_MIN_ALLOC_SIZE into consideration,
> > > 16~31 share slot 2. Calculation as below:
> > > highbit = fls(16) -> highbit = 5
> > > max(5 - PCPU_SLOT_BASE_SHIFT + 2, 1) equals 2, not 1.
> > >
> > > This patch by decreasing pcpu_nr_slots to avoid waste one slot and let
> > > [PCPU_MIN_ALLOC_SIZE, 31) really share the same slot.
> > >
> > > Signed-off-by: Peng Fan <peng.fan@nxp.com>
> > > ---
> > >
> > > V1:
> > >  Not very sure about whether it is intended to leave the slot there.
> > >
> > >  mm/percpu.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/mm/percpu.c b/mm/percpu.c index
> > > 8d9933db6162..12a9ba38f0b5 100644
> > > --- a/mm/percpu.c
> > > +++ b/mm/percpu.c
> > > @@ -219,7 +219,7 @@ static bool pcpu_addr_in_chunk(struct pcpu_chunk
> > > *chunk, void *addr)  static int __pcpu_size_to_slot(int size)  {
> > >  	int highbit = fls(size);	/* size is in bytes */
> > > -	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
> > > +	return max(highbit - PCPU_SLOT_BASE_SHIFT + 1, 1);
> > >  }
> > 
> > Honestly, it may be better to just have [1-16) [16-31) be separate. I'm working
> > on a change to this area, so I may change what's going on here.
> > 
> > >
> > >  static int pcpu_size_to_slot(int size) @@ -2145,7 +2145,7 @@ int
> > > __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> > >  	 * Allocate chunk slots.  The additional last slot is for
> > >  	 * empty chunks.
> > >  	 */
> > > -	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
> > > +	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 1;
> > >  	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
> > >  				   SMP_CACHE_BYTES);
> > >  	for (i = 0; i < pcpu_nr_slots; i++)
> > > --
> > > 2.16.4
> > >
> > 
> > This is a tricky change. The nice thing about keeping the additional
> > slot around is that it ensures a distinction between a completely empty
> > chunk and a nearly empty chunk.
> 
> Are there any issues met before if not keeping the unused slot?
> From reading the code and git history I could not find information.
> I tried this code on aarch64 qemu and did not meet issues.
> 

This change would require verification that all paths lead to power of 2
chunk sizes and most likely a BUG_ON if that's not the case.

So while this would work, we're holding onto an additional slot also to
be used for chunk reclamation via pcpu_balance_workfn(). If a chunk was
not a power of 2 resulting in the last slot being entirely empty chunks
we could free stuff a chunk with addresses still in use.

> > It happens to be that the logic creates
> > power of 2 chunks which ends up being an additional slot anyway. 
> 
> 
> So,
> > given that this logic is tricky and architecture dependent, 
> 
> Could you share more information about architecture dependent?
> 

The crux of the logic is in pcpu_build_alloc_info(). It's been some time
since I've thought deeply about it, but I don't believe there is a
guarantee that it will be a power of 2 chunk.

Thanks,
Dennis

