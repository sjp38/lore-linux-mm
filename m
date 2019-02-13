Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D2D2C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:19:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 567E321904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:19:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sfnRNTN6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 567E321904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E61DA8E0003; Wed, 13 Feb 2019 11:19:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10ED8E0001; Wed, 13 Feb 2019 11:19:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFFFE8E0003; Wed, 13 Feb 2019 11:19:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A99E58E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:19:19 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id r24so2541200otk.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:19:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=6cgydVzEMe2hY+xvoZbvAXaDHt8Fvtz1odtZkVMvLmU=;
        b=V8pg1HNqWbsDUBYe/ORHGxiRV6L8Afyk2kRs5/9U8Dx++vY3Z4DCTNkvj/ZVdPtlHI
         SUaNvsjHH0skpCDO6EcqQYoOqpK1nBI3JGdKAIk/OUAXAnKLwrFdx0LJtF3jsX15/LR3
         +HJTEWx1AzuvBrBArg/IJck2JRR93up908Jsdsyqqe5YBLG9GAUZBojJcp1GPq7dQaZn
         1eWshEO1VGQqo1dTlHVUSrswENedjb7a8cc0FNDcPAittLRJtMDuR92KX2jvj2UV8fx+
         R9MWhFikj6CKnDTTokJfQrcQvUcgl/Hgq7/zSPSnIAEakAvaUltpEE1imK3lXq29nanP
         xUfw==
X-Gm-Message-State: AHQUAuashKRXYgyfP21jIpIvwi4weglkWLwChzAEPX8fBd4tlvD6PrcR
	Ct0ReEZq0TLsrGf7+q1PyCVMheZV786Ia4kMlVFpraGDvQ0Dl3uFfduwGxmVQ3jg/Sw50DfO93+
	68wQIjJ3aQ9TUMyH2v7I89LrCyarwouAAo3B4mSbMguqavxSHpqWLSE+atEHSD8YdFleVlhsj4e
	I67ucciHC0AAxki+SQe5gx8JSeU2wrOHIGOWMAOxSu3CQ3/bBopKnDwcsjiufCTQJt9JjketTh7
	FCEBBSgcL3W3uOoX8p9FZbb0DkvQwqxRnztuTtvvI/UjiOrqAurMqZxIWBbPiDlsfcyJisohsn0
	aJVi6liMibts52gDlPMoB3BTdaMdEYZt76EgeOFkfHvr4QhvILyux2Uuk6N8E1bxLmfrZMfq7EQ
	b
X-Received: by 2002:aca:b1c3:: with SMTP id a186mr721494oif.8.1550074759286;
        Wed, 13 Feb 2019 08:19:19 -0800 (PST)
X-Received: by 2002:aca:b1c3:: with SMTP id a186mr721426oif.8.1550074757919;
        Wed, 13 Feb 2019 08:19:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550074757; cv=none;
        d=google.com; s=arc-20160816;
        b=LOu0A5V8gcwR3/bLdrnnGTnIPZkN6d4tySaXXBCD6RCqGI3G/UkV+PfgNF4JIFtua0
         nMdMveBXEi07LGxKXAhln3cECs5q2JqCuihAct/Gi700oOLGfQsobkNl1GlVreIN1lEo
         Wh8Xw1mT86J5AWqH28adQbM/2ANjo7TNBG6Fn4cXBvoJGAIh4up72K9B6KqisaWgw9jD
         1VR2LYrKGYi9Ig0SReQPu9cfKVkBazgld3l6+8ktOofgW3UCXkF44BNrf9ETSmXjmXZb
         RB9Rx592K5ur9rNBG63LUXKvRDZhUFnoKA74co4DrFd7CR2NxMMMXGTJgD3YyEnAuyOw
         RxSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6cgydVzEMe2hY+xvoZbvAXaDHt8Fvtz1odtZkVMvLmU=;
        b=grBl05d/CvOXdfMqw4COJ0u9e4EMUxYt+gYiL5E+4w95xCld8bVD7GisFr3lDw46k2
         u5uDEAeL/vtHQnRl6z7KhYFQtKpmtM+IOBCYbCwZEjMf7uAYbjteJSxOhq4o6LQ+Z9sI
         hbb/nczgiFtGtUg84vpFjU/n6XptiQadTHS7FoXD1MOa9j41d6vfnGiEDisYz6Wmftwf
         WoYFd7Vk2nszCFNNqAGd/Kek3RJYT1WRRJY81HMFLrZVXXvlC97zIga+wlAF3XBXuI22
         JYK2eTDXttc3Qaa7uoFEa5apQDrVSs1TB7A3mZJAa9iMdjAJuihBIM67pBeFt/Ex60FA
         xavQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sfnRNTN6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor10144978otl.27.2019.02.13.08.19.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 08:19:17 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sfnRNTN6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=6cgydVzEMe2hY+xvoZbvAXaDHt8Fvtz1odtZkVMvLmU=;
        b=sfnRNTN67G5hJbWbDrOvTOiV7JaDoiYNtomEZeOJ2Cg4RlKrQAEZMEE8GCPO7UvHLj
         GPR1r1bWUfYVEaEFMOnYaAhZI6P89ivWehuRk8b/h3lxf0FMXyQus6ly/WmBXLgZ7FKK
         nZf9v/JUojwBuy+JU1zQG9561ufog6r5xqzb49IyJ9eeCQYclpkzOy4k1rk6vfBCgWKI
         LRqtSKqS+C2zF4D/l40stip5td6J68ixu8Rdkni6LBIMJ2cxPeCwpsJFKuQX/o7UppsS
         w246TVXJ0ZPjWFXpjH397vBDcGrhTS+1jBO9ulGUL8ph3D2poHRcI1JqC51oXpX3n/8u
         Viog==
X-Google-Smtp-Source: AHgI3IZ9CIAGGslUXr2nx86tN/Mvd9GJImhvz5Oimwf9LiErsS9Mz+SJ8i51KWePKhVC3iZgZBWXQIlfh48mI/s6BKo=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr748863ota.229.1550074757434;
 Wed, 13 Feb 2019 08:19:17 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr> <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
 <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr> <CAPcyv4jF7ZyKaFDw7nb04UvWkVWGJdLGkZDQ1g=X7i+kdu7JRg@mail.gmail.com>
 <a3bfe739-228e-26fe-90f7-4a4f8ceb3a9a@inria.fr> <CAPcyv4jJ=C7ZEsJqBxzBMsQWz4+C8BZmWuk7OkztOebprd2rMg@mail.gmail.com>
 <057ad938-e745-02f7-edce-e19bd326da6a@inria.fr> <eb58cb96-1f61-2dd2-b1ab-5a7d4df78297@inria.fr>
In-Reply-To: <eb58cb96-1f61-2dd2-b1ab-5a7d4df78297@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Feb 2019 08:19:05 -0800
Message-ID: <CAPcyv4iAex_rgPXfhsjWjbvKX79s0ZoieE2NeX14_F56WoQ_7A@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Takashi Iwai <tiwai@suse.de>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 5:07 AM Brice Goglin <Brice.Goglin@inria.fr> wrote:
>
>
> Le 13/02/2019 =C3=A0 09:43, Brice Goglin a =C3=A9crit :
> > Le 13/02/2019 =C3=A0 09:24, Dan Williams a =C3=A9crit :
> >> On Wed, Feb 13, 2019 at 12:12 AM Brice Goglin <Brice.Goglin@inria.fr> =
wrote:
> >>> Le 13/02/2019 =C3=A0 01:30, Dan Williams a =C3=A9crit :
> >>>> On Tue, Feb 12, 2019 at 11:59 AM Brice Goglin <Brice.Goglin@inria.fr=
> wrote:
> >>>>> # ndctl disable-region all
> >>>>> # ndctl zero-labels all
> >>>>> # ndctl enable-region region0
> >>>>> # ndctl create-namespace -r region0 -t pmem -m devdax
> >>>>> {
> >>>>>   "dev":"namespace0.0",
> >>>>>   "mode":"devdax",
> >>>>>   "map":"dev",
> >>>>>   "size":"1488.37 GiB (1598.13 GB)",
> >>>>>   "uuid":"ad0096d7-3fe7-4402-b529-ad64ed0bf789",
> >>>>>   "daxregion":{
> >>>>>     "id":0,
> >>>>>     "size":"1488.37 GiB (1598.13 GB)",
> >>>>>     "align":2097152,
> >>>>>     "devices":[
> >>>>>       {
> >>>>>         "chardev":"dax0.0",
> >>>>>         "size":"1488.37 GiB (1598.13 GB)"
> >>>>>       }
> >>>>>     ]
> >>>>>   },
> >>>>>   "align":2097152
> >>>>> }
> >>>>> # ndctl enable-namespace namespace0.0
> >>>>> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> >>>>> <hang>
> >>>>>
> >>>>> I tried with and without dax_pmem_compat loaded, but it doesn't hel=
p.
> >>>> I think this is due to:
> >>>>
> >>>>   a9f1ffdb6a20 device-dax: Auto-bind device after successful new_id
> >>>>
> >>>> I missed that this path is also called in the remove_id path. Thanks
> >>>> for the bug report! I'll get this fixed up.
> >>> Now that remove_id is fixed, things fails later in Dave's procedure:
> >>>
> >>> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> >>> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> >>> # echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> >> In the current version of the code the bind is not necessary, so the
> >> lack of error messages here means the bind succeeded.
>
>
> It looks like "unbind" is required to make the PMEM appear as a new
> node. If I remove_id from devdax and new_id to kmem without "unbind" in
> the middle, nothing appears.
>
> Writing to "kmem/bind" didn't seem necessary.

Yes, in short:

device_dax/remove_id: not required, this driver attaches to any and
all device-dax devices by default
device_dax/unbind: required, nothing else will free the device for
kmem to attach
kmem/new_id: required, it will attach if the device is currently
unbound otherwise the device must be unbound before proceeding
kmem/bind: only required if the device was busy / attached to
device_dax when new_id was written.

