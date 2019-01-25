Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7471B8E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:24:45 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p9so8598220pfj.3
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:24:45 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 91si3594960ply.222.2019.01.25.13.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 13:24:44 -0800 (PST)
Subject: Re: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource
 code
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231444.38182DD8@viggo.jf.intel.com>
 <CAErSpo4oSjQAxeRy8Tz_Jvo+cRovBvVx9WBeNb_P6PxT-A_XhA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b191ad4a-da4e-9bc7-4468-d6e4a8b3d66f@intel.com>
Date: Fri, 25 Jan 2019 13:24:43 -0800
MIME-Version: 1.0
In-Reply-To: <CAErSpo4oSjQAxeRy8Tz_Jvo+cRovBvVx9WBeNb_P6PxT-A_XhA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jerome Glisse <jglisse@redhat.com>

On 1/25/19 1:18 PM, Bjorn Helgaas wrote:
> On Thu, Jan 24, 2019 at 5:21 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>> diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
>> --- a/kernel/resource.c~move-request_region-check       2019-01-24 15:13:14.453199539 -0800
>> +++ b/kernel/resource.c 2019-01-24 15:13:14.458199539 -0800
>> @@ -1123,6 +1123,16 @@ struct resource * __request_region(struc
>>                 conflict = __request_resource(parent, res);
>>                 if (!conflict)
>>                         break;
>> +               /*
>> +                * mm/hmm.c reserves physical addresses which then
>> +                * become unavailable to other users.  Conflicts are
>> +                * not expected.  Be verbose if one is encountered.
>> +                */
>> +               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
>> +                       pr_debug("Resource conflict with unaddressable "
>> +                                "device memory at %#010llx !\n",
>> +                                (unsigned long long)start);
> 
> I don't object to the change, but are you really OK with this being a
> pr_debug() message that is only emitted when enabled via either the
> dynamic debug mechanism or DEBUG being defined?  From the comments, it
> seems more like a KERN_INFO sort of message.

I left it consistent with the original message that was in the code.
I'm happy to change it, though, if the consumers of it (Jerome,
basically) want something different.

> Also, maybe the message would be more useful if it included the
> conflicting resource as well as the region you're requesting?  Many of
> the other callers of request_resource_conflict() have something like
> this:
> 
>   dev_err(dev, "resource collision: %pR conflicts with %s %pR\n",
>         new, conflict->name, conflict);

Seems sane.  I was just trying to change as little as possible.
