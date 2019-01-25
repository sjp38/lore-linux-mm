Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 034C18E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 14:10:37 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id f12so5059119ybp.0
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:10:36 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i23si2045185ybj.308.2019.01.25.11.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 11:10:35 -0800 (PST)
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal
 RAM
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
 <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
 <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
 <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
 <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <dc7d8190-2c94-9bdb-fb5b-a80a3fb55822@oracle.com>
Date: Fri, 25 Jan 2019 11:10:22 -0800
MIME-Version: 1.0
In-Reply-To: <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Du, Fan" <fan.du@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de" <tiwai@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, "zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Huang, Ying" <ying.huang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>


On 1/25/2019 10:20 AM, Verma, Vishal L wrote:
> 
> On Fri, 2019-01-25 at 09:18 -0800, Dan Williams wrote:
>> On Fri, Jan 25, 2019 at 12:20 AM Du, Fan <fan.du@intel.com> wrote:
>>> Dan
>>>
>>> Thanks for the insights!
>>>
>>> Can I say, the UCE is delivered from h/w to OS in a single way in
>>> case of machine
>>> check, only PMEM/DAX stuff filter out UC address and managed in its
>>> own way by
>>> badblocks, if PMEM/DAX doesn't do so, then common RAS workflow will
>>> kick in,
>>> right?
>>
>> The common RAS workflow always kicks in, it's just the page state
>> presented by a DAX mapping needs distinct handling. Once it is
>> hot-plugged it no longer needs to be treated differently than "System
>> RAM".
>>
>>> And how about when ARS is involved but no machine check fired for
>>> the function
>>> of this patchset?
>>
>> The hotplug effectively disconnects this address range from the ARS
>> results. They will still be reported in the libnvdimm "region" level
>> badblocks instance, but there's no safe / coordinated way to go clear
>> those errors without additional kernel enabling. There is no "clear
>> error" semantic for "System RAM".
>>
> Perhaps as future enabling, the kernel can go perform "clear error" for
> offlined pages, and make them usable again. But I'm not sure how
> prepared mm is to re-accept pages previously offlined.
> 

Offlining a DRAM backed page due to an UC makes sense because
  a. the physical DRAM cell might still have an error
  b. power cycle, scrubing could potentially 'repair' the DRAM cell,
making the page usable again.

But for a PMEM backed page, neither is true. If a poison bit is set in
a page, that indicates the underlying hardware has completed the repair 
work, all that's left is for software to recover.  Secondly, because 
poison is persistent, unless software explicitly clear the bit,
the page is permanently unusable.

thanks,
-jane
