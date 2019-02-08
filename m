Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6AD1C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:01:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A342321916
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:01:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="JyxKUrN5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A342321916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4448D8E0085; Fri,  8 Feb 2019 04:01:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F23F8E0083; Fri,  8 Feb 2019 04:01:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BB4E8E0085; Fri,  8 Feb 2019 04:01:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C700B8E0083
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 04:01:57 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f193so834830wme.8
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 01:01:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=fooRh1gZ6IpLFzGD2jk4xEF8/2O5k1pY3XR60x9luIk=;
        b=XNVkWzMrMGRwQU9aW4N3N+9BRsLRtMv4mNOqv/EWCmtO7KlZ+8145LlqgcR4NEBku6
         V+oktQ585l5VZOTGuPpRYwm0TcHTmFQC+40WH06QdUWRFmm0ZdyJsc2khhFc2+R+KX0i
         7K1XeLsh05MRI8SCI2xZiuRalGznkhrSCRCmZHYkMU2bC2FHGstEHx7w9RRC6VXLQUtC
         7W/hbGk5bTRDsebEIC0nXvcIELhGvifldqOGtwS//UIRS390K91JNWF4zbi+YyhpptxX
         52rJPo18e0jlusKIxywA6zpMZfBfq0c9uXc6vrVLIhfe/pFbzQ0UBF5UPJ5b+AL4rLmc
         CS9Q==
X-Gm-Message-State: AHQUAua1H09eo1pEOuuLQ+yoDeM3t6pzNFzSWJleEC9W3WxelcLky5n1
	St1M601i4FLHRDzyszidq0bVrjvnlEMsg23CYoiFh72o6qIic105MVOlOIXYcl4kS+YXIrsQctm
	cuYO8R7CtZzTTBcAxrU4RgUo/zI3h36zQIJPWcUofGq1XLbqyjkqKWkyRuuq4lQYLuw==
X-Received: by 2002:adf:c5cc:: with SMTP id v12mr15104049wrg.176.1549616517070;
        Fri, 08 Feb 2019 01:01:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUFmZn00BrXWaSf69qB/wudfFUT3SFC51pxgiYfl52AyyhicMs3rlYiywGbFcpkKpgPCb2
X-Received: by 2002:adf:c5cc:: with SMTP id v12mr15103986wrg.176.1549616516025;
        Fri, 08 Feb 2019 01:01:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549616516; cv=none;
        d=google.com; s=arc-20160816;
        b=ZfAFcSnEiRw8jlFjyGaey+9dJ97tRVrxJhELb4SNj3Uv8pHZs/GXhTfWQZcGXJyQP0
         0QntD/SiyMHVJFjP/Njp+omg3ZG5SpxB40Lb76yprdjO04rsiA/ifRjMn4Q60YvvIJgD
         OB+VInWMMCxgoQfDbFa+prEdR/jnxfWjgCL5N2b/fXNyj65BVzO+W/UZNyErlwSnIxwc
         p0lv+LrPxlWGpBuzjSzs8fdyAHdGWjGCx4mg3YYKais2YIfWTsehdS8AwPWN4lUG56i5
         xHWA2+kRKz4pluNr8unseqJoiGD3EN70P6D46HV9vx2c5C9hMoC6qKZOVEkC+c6CWCZj
         kdbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=fooRh1gZ6IpLFzGD2jk4xEF8/2O5k1pY3XR60x9luIk=;
        b=t4Am2OIlHgbVP/pvq5WExoOfYttV637CbyUX4loabPOQYts5h9KAhkdLAYrTBt6HJ+
         R+LsNz1uEQa686N4Hyb8cwgpVEkB1iiUnOAzTInr2YrVUj/QJPkBvahE6AxmeC1F8pho
         /IrFf8IXG5mOjm0LNDLYcRNFL1oER1HiVbhkcLMdKWmGWD/6sth84JtvgfHKTeeNmx0z
         L5eVHQk/aJV9icah/P1yqsGbUtociJPDY7g/yCuhou+JndKMR5dm5rbvqlRTeq1rWZEL
         +0HPjk9uNgOItMd3UbFPMfRgZBzZxGAAKVfaHF0UpNQDE2GTvS616764RL4hv4fqVVU0
         qVcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=JyxKUrN5;
       spf=neutral (google.com: 2a01:238:20a:202:5301::4 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::4])
        by mx.google.com with ESMTPS id p1si1017248wro.173.2019.02.08.01.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 01:01:55 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::4 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::4;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=JyxKUrN5;
       spf=neutral (google.com: 2a01:238:20a:202:5301::4 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549616515;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:References:Cc:To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=fooRh1gZ6IpLFzGD2jk4xEF8/2O5k1pY3XR60x9luIk=;
	b=JyxKUrN570XeFlERGNOGx09arnzdpkrnNk5PGyrw02Wmu2m5nzmdZ1EBY1qZ0wrFkC
	090mKWJMCXDIbs7l7wh0yJ3tGPBmPp3lGrw3YkiVVInYhLbMGog1xRTI7Oo/+vdgIraZ
	DcBdKgtUUo1ANhigDKp06wfNQIQeowH9fjGbfToxbHrvsYPc4AvdW7iW5NH2HfO36Ywy
	XC5474fpBeUSS/Hq/93CHlzrWXfTQH0VrQjrh0II6l0AbD9azONsTOReKh81Bf9FzJPi
	XEV+VoqzrefS/a4TB64JwurDUyrE2xA3v018NqZ3FteCjRZuYf+/kGw//d6QdNSui38g
	vVLA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CkGj+Y7E+ydJaUNFx8xLfqBQFoUyw=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:914e:ec0c:daf0:5a2a]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1891k4iY
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Fri, 8 Feb 2019 10:01:46 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
 <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
 <20190201080456.GA15456@lst.de>
 <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
 <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
 <20190204075616.GA5408@lst.de>
 <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
 <20190204123852.GA10428@lst.de>
 <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
 <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
 <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
Message-ID: <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
Date: Fri, 8 Feb 2019 10:01:46 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Your new patch fixes the problems with the P.A. Semi Ethernet! :-)

Thanks,
Christian


On 07 February 2019 at 05:34AM, Christian Zigotzky wrote:
> Hi Christoph,
>
> I also didn’t notice the 32-bit DMA mask in your patch. I have to read your patches and descriptions carefully in the future. I will test your new patch at the weekend.
>
> Thanks,
> Christian
>
> Sent from my iPhone
>
>> On 6. Feb 2019, at 16:16, Christoph Hellwig <hch@lst.de> wrote:
>>
>>> On Wed, Feb 06, 2019 at 04:15:05PM +0100, Christoph Hellwig wrote:
>>> The last good one was 29e7e2287e196f48fe5d2a6e017617723ea979bf
>>> ("dma-direct: we might need GFP_DMA for 32-bit dma masks"), if I
>>> remember correctly.  powerpc/dma: use the dma_direct mapping routines
>>> was the one that you said makes the pasemi ethernet stop working.
>>>
>>> Can you post the dmesg from the failing runs?
>> But I just noticed I sent you a wrong patch - the pasemi ethernet
>> should set a 64-bit DMA mask, not 32-bit.  Updated version below,
>> 32-bit would just keep the previous status quo.
>>
>> commit 6c8f88045dee35933337b9ce2ea5371eee37073a
>> Author: Christoph Hellwig <hch@lst.de>
>> Date:   Mon Feb 4 13:38:22 2019 +0100
>>
>>     pasemi WIP
>>
>> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
>> index 8a31a02c9f47..2d7d1589490a 100644
>> --- a/drivers/net/ethernet/pasemi/pasemi_mac.c
>> +++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
>> @@ -1716,6 +1716,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>         err = -ENODEV;
>>         goto out;
>>     }
>> +    dma_set_mask(&mac->dma_pdev->dev, DMA_BIT_MASK(64));
>>
>>     mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
>>     if (!mac->iob_pdev) {


