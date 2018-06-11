Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 180116B0003
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:36:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o7-v6so6502209pgc.23
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:36:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 63-v6si35537155pfx.61.2018.06.11.10.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 10:35:58 -0700 (PDT)
Date: Mon, 11 Jun 2018 10:35:58 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Message-ID: <20180611173558.GB11953@tassilo.jf.intel.com>
References: <20180605141104.GF19202@dhcp22.suse.cz>
 <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz>
 <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz>
 <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
 <20180611075004.GH13364@dhcp22.suse.cz>
 <CAPcyv4gSTMEi5XdzLQZqxMMKCcwF=me02wCiRtAAXSiy2CPGJA@mail.gmail.com>
 <20180611145636.GP13364@dhcp22.suse.cz>
 <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Jun 11, 2018 at 08:19:54AM -0700, Dan Williams wrote:
> On Mon, Jun 11, 2018 at 7:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 11-06-18 07:44:39, Dan Williams wrote:
> > [...]
> >> I'm still trying to understand the next level of detail on where you
> >> think the design should go next? Is it just the HWPoison page flag?
> >> Are you concerned about supporting greater than PAGE_SIZE poison?
> >
> > I simply do not want to check for HWPoison at zillion of places and have
> > each type of page to have some special handling which can get wrong very
> > easily. I am not clear on details here, this is something for users of
> > hwpoison to define what is the reasonable scenarios when the feature is
> > useful and turn that into a feature list that can be actually turned
> > into a design document. See the different from let's put some more on
> > top approach...
> >
> 
> So you want me to pay the toll of writing a design document justifying
> all the existing use cases of HWPoison before we fix the DAX bugs, and
> the design document may or may not result in any substantive change to
> these patches?
> 
> Naoya or Andi, can you chime in here?

A new document doesn't make any sense. We have the commit messages and
the code comments as design documents, and as usual the ultimative authority is
what the code does.

The guiding light for new memory recovery code is just these sentences (taken
from the beginning of the main file):

 * In general any code for handling new cases should only be added iff:
 * - You know how to test it.
 * - You have a test that can be added to mce-test
 *   https://git.kernel.org/cgit/utils/cpu/mce/mce-test.git/
 * - The case actually shows up as a frequent (top 10) page state in
 *   tools/vm/page-types when running a real workload.

Since persistent memory is so big it makes sense to add support
for it in common code paths. That is usually just kernel copies and
user space execution.

-Andi
