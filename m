Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14FE58E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:20:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so5869022plr.8
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:20:51 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w185si4457311pfw.122.2019.01.25.00.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:20:49 -0800 (PST)
From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH 5/5] dax: "Hotplug" persistent memory for use like
 normal RAM
Date: Fri, 25 Jan 2019 08:20:45 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
 <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
In-Reply-To: <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, Jane Chu <jane.chu@oracle.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Takashi Iwai <tiwai@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?Q?J=E9r=3Fme_Glisse?= <jglisse@redhat.com>, Borislav Petkov <bp@suse.de>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Ross Zwisler <zwisler@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Du,
 Fan" <fan.du@intel.com>

Dan

Thanks for the insights!

Can I say, the UCE is delivered from h/w to OS in a single way in case of m=
achine
check, only PMEM/DAX stuff filter out UC address and managed in its own way=
 by
badblocks, if PMEM/DAX doesn't do so, then common RAS workflow will kick in=
,
right?

And how about when ARS is involved but no machine check fired for the funct=
ion
of this patchset?

>-----Original Message-----
>From: Linux-nvdimm [mailto:linux-nvdimm-bounces@lists.01.org] On Behalf
>Of Dan Williams
>Sent: Friday, January 25, 2019 2:28 PM
>To: Jane Chu <jane.chu@oracle.com>
>Cc: Tom Lendacky <thomas.lendacky@amd.com>; Michal Hocko
><mhocko@suse.com>; linux-nvdimm <linux-nvdimm@lists.01.org>; Takashi
>Iwai <tiwai@suse.de>; Dave Hansen <dave.hansen@linux.intel.com>; Huang,
>Ying <ying.huang@intel.com>; Linux Kernel Mailing List
><linux-kernel@vger.kernel.org>; Linux MM <linux-mm@kvack.org>; J=E9r=F4me
>Glisse <jglisse@redhat.com>; Borislav Petkov <bp@suse.de>; Yaowei Bai
><baiyaowei@cmss.chinamobile.com>; Ross Zwisler <zwisler@kernel.org>;
>Bjorn Helgaas <bhelgaas@google.com>; Andrew Morton
><akpm@linux-foundation.org>; Wu, Fengguang <fengguang.wu@intel.com>
>Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like
>normal RAM
>
>On Thu, Jan 24, 2019 at 10:13 PM Jane Chu <jane.chu@oracle.com> wrote:
>>
>> Hi, Dave,
>>
>> While chatting with my colleague Erwin about the patchset, it occurred
>> that we're not clear about the error handling part. Specifically,
>>
>> 1. If an uncorrectable error is detected during a 'load' in the hot
>> plugged pmem region, how will the error be handled?  will it be
>> handled like PMEM or DRAM?
>
>DRAM.
>
>> 2. If a poison is set, and is persistent, which entity should clear
>> the poison, and badblock(if applicable)? If it's user's responsibility,
>> does ndctl support the clearing in this mode?
>
>With persistent memory advertised via a static logical-to-physical
>storage/dax device mapping, once an error develops it destroys a
>physical *and* logical part of a device address space. That loss of
>logical address space makes error clearing a necessity. However, with
>the DRAM / "System RAM" error handling model, the OS can just offline
>the page and map a different one to repair the logical address space.
>So, no, ndctl will not have explicit enabling to clear volatile
>errors, the OS will just dynamically offline problematic pages.
>_______________________________________________
>Linux-nvdimm mailing list
>Linux-nvdimm@lists.01.org
>https://lists.01.org/mailman/listinfo/linux-nvdimm
