Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 773A38E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:59:42 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id l1so3720332wrn.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:59:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor23830735wmy.3.2019.01.16.13.59.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:59:41 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
 <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com> <f786481c-d38d-5129-318b-cb61b6251c47@intel.com>
In-Reply-To: <f786481c-d38d-5129-318b-cb61b6251c47@intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 16 Jan 2019 15:59:28 -0600
Message-ID: <CAErSpo6xjELcvj1jZ20UZS-rEHr-kNioPFTjWR9K3CuZq8ecmw@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave@sr71.net>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>

On Wed, Jan 16, 2019 at 3:53 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/16/19 1:16 PM, Bjorn Helgaas wrote:
> >> +       /*
> >> +        * Set flags appropriate for System RAM.  Leave ..._BUSY clear
> >> +        * so that add_memory() can add a child resource.
> >> +        */
> >> +       new_res->flags = IORESOURCE_SYSTEM_RAM;
> > IIUC, new_res->flags was set to "IORESOURCE_MEM | ..." in the
> > devm_request_mem_region() path.  I think you should keep at least
> > IORESOURCE_MEM so the iomem_resource tree stays consistent.
>
> I went to look at fixing this.  It looks like "IORESOURCE_SYSTEM_RAM"
> includes IORESOURCE_MEM:
>
> > #define IORESOURCE_SYSTEM_RAM           (IORESOURCE_MEM|IORESOURCE_SYSRAM)
>
> Did you want the patch to expand this #define, or did you just want to
> ensure that IORESORUCE_MEM got in there somehow?

The latter.  Since it's already included, forget I said anything :)
Although if your intent is only to clear IORESOURCE_BUSY, maybe it
would be safer to just clear that bit instead of overwriting
everything?  That might also help people grepping for IORESOURCE_BUSY
usage.
