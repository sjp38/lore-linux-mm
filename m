Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A96B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:56:21 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id k76so3618051oih.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:56:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor1119286otr.58.2019.01.17.08.56.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:56:19 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
 <5A90DA2E42F8AE43BC4A093BF06788482571FCB1@SHSMSX103.ccr.corp.intel.com>
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF06788482571FCB1@SHSMSX103.ccr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 08:56:08 -0800
Message-ID: <CAPcyv4heNGQf4NHYrMzUdBRw2n3tE08bMaVKzgYrPYVaVDWE9Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Du, Fan" <fan.du@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "dave@sr71.net" <dave@sr71.net>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "mhocko@suse.com" <mhocko@suse.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "tiwai@suse.de" <tiwai@suse.de>, "zwisler@kernel.org" <zwisler@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, "Huang, Ying" <ying.huang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "bp@suse.de" <bp@suse.de>

On Wed, Jan 16, 2019 at 9:21 PM Du, Fan <fan.du@intel.com> wrote:
[..]
> >From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> >Currently, a persistent memory region is "owned" by a device driver,
> >either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> >allow applications to explicitly use persistent memory, generally
> >by being modified to use special, new libraries.
> >
> >However, this limits persistent memory use to applications which
> >*have* been modified.  To make it more broadly usable, this driver
> >"hotplugs" memory into the kernel, to be managed ad used just like
> >normal RAM would be.
> >
> >To make this work, management software must remove the device from
> >being controlled by the "Device DAX" infrastructure:
> >
> >       echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> >       echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> >
> >and then bind it to this new driver:
> >
> >       echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> >       echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
>
> Is there any plan to introduce additional mode, e.g. "kmem" in the userspace
> ndctl tool to do the configuration?
>

Yes, but not to ndctl. The daxctl tool will grow a helper for this.
The policy of what device-dax instances should be hotplugged at system
init will be managed by a persistent configuration file and udev
rules.
