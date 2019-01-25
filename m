Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF1B58E007A
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:12:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so3001175edd.11
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 17:12:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21-v6sor13906197ejh.52.2019.01.24.17.12.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 17:12:27 -0800 (PST)
Date: Fri, 25 Jan 2019 01:12:25 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190125011225.2vtcjtt64wrv36di@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
 <20190122151628.GI4087@dhcp22.suse.cz>
 <20190122155628.eu4sxocyjb5lrcla@master>
 <20190123095503.GR4087@dhcp22.suse.cz>
 <20190124141341.au6a7jpwccez5vc7@master>
 <20190124143008.GO4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124143008.GO4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, Jan 24, 2019 at 03:30:08PM +0100, Michal Hocko wrote:
>On Thu 24-01-19 14:13:41, Wei Yang wrote:
>> On Wed, Jan 23, 2019 at 10:55:03AM +0100, Michal Hocko wrote:
>> >On Tue 22-01-19 15:56:28, Wei Yang wrote:
>> >> 
>> >> I think the answer is yes.
>> >> 
>> >>   * it reduce the code from 6 lines to 3 lines, 50% off
>> >>   * by reducing calculation back and forth, it would be easier for
>> >>     audience to catch what it tries to do
>> >
>> >To be honest, I really do not see this sufficient to justify touching
>> >the code unless the resulting _generated_ code is better/more efficient.
>> 
>> Tried objdump to compare two version.
>> 
>>                Base       Patched      Reduced
>> Code Size(B)   48         39           18.7%
>> Instructions   12         10           16.6%
>
>How have you compiled the code? (compiler version, any specific configs).
>Because I do not see any difference.

Yes, of course I have hacked and compiled the code.

I guess you compile the code on x86, which by default SPARSEMEM is
configured. This means those changes are not compiled. 

To get the result, I have hacked the code to add the definition to
mm/sparse.c and call this new function to make sure compile will not
optimize this out.

Below is the result from readelf -S mm/sparse.o

>
>CONFIG_CC_OPTIMIZE_FOR_SIZE:
>   text    data     bss     dec     hex filename
>  47087    2085      72   49244    c05c mm/page_alloc.o
>  47087    2085      72   49244    c05c mm/page_alloc.o.prev

text: 0x2c7 -> 0x2be   reduced 9 bytes

>
>CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE:
>   text    data     bss     dec     hex filename
>  55046    2085      72   57203    df73 mm/page_alloc.o
>  55046    2085      72   57203    df73 mm/page_alloc.o.prev

text: 0x35b -> 0x34b   reduced 16 bytes

>
>And that would actually match my expectations because I am pretty sure
>the compiler can figure out what to do with those operations even
>without any help.
>
>Really, is this really worth touching and spending a non-trivial time to
>discuss? I do not see the benefit.

I thought this is a trivial change and we have the same taste of the
code.

I agree to put an end to this thread.

Thanks for your time.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
