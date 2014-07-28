Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8076C6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 19:12:23 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so4516001igc.0
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 16:12:23 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id au4si20203410igc.59.2014.07.28.16.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 16:12:22 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so4500230iga.10
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 16:12:22 -0700 (PDT)
Date: Mon, 28 Jul 2014 16:12:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory hotplug: update the variables after memory
 removed
In-Reply-To: <53D6685C.1060509@intel.com>
Message-ID: <alpine.DEB.2.02.1407281610340.8998@chino.kir.corp.google.com>
References: <1406550617-19556-1-git-send-email-zhenzhang.zhang@huawei.com> <53D642E5.2010305@huawei.com> <53D6685C.1060509@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Zhang Zhen <zhenzhang.zhang@huawei.com>, shaohui.zheng@intel.com, mgorman@suse.de, mingo@redhat.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, wangnan0@huawei.com, akpm@linux-foundation.org

On Mon, 28 Jul 2014, Dave Hansen wrote:

> On 07/28/2014 05:32 AM, Zhang Zhen wrote:
> > -static void  update_end_of_memory_vars(u64 start, u64 size)
> > +static void  update_end_of_memory_vars(u64 start, u64 size, bool flag)
> >  {
> > -	unsigned long end_pfn = PFN_UP(start + size);
> > -
> > -	if (end_pfn > max_pfn) {
> > -		max_pfn = end_pfn;
> > -		max_low_pfn = end_pfn;
> > -		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> > +	unsigned long end_pfn;
> > +
> > +	if (flag) {
> > +		end_pfn = PFN_UP(start + size);
> > +		if (end_pfn > max_pfn) {
> > +			max_pfn = end_pfn;
> > +			max_low_pfn = end_pfn;
> > +			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> > +		}
> > +	} else {
> > +		end_pfn = PFN_UP(start);
> > +		if (end_pfn < max_pfn) {
> > +			max_pfn = end_pfn;
> > +			max_low_pfn = end_pfn;
> > +			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> > +		}
> >  	}
> >  }
> 
> I would really prefer not to see code like this.
> 
> This patch takes a small function that did one thing, copies-and-pastes
> its code 100%, subtly changes it, and makes it do two things.  The only
> thing to tell us what the difference between these two subtly different
> things is a variable called 'flag'.  So the variable is useless in
> trying to figure out what each version is supposed to do.
> 
> But, this fixes a pretty glaring deficiency in the memory remove code.
> 
> I would suggest making two functions.  Make it clear that one is to be
> used at remove time and the other at add time.  Maybe
> 
> 	move_end_of_memory_vars_down()
> and
> 	move_end_of_memory_vars_up()
> 

I agree, but I'm not sure the suggestion is any better than the patch.  I 
think it would be better to just figure out whether anything needs to be 
updated in the caller and then call a generic function.

So in arch_add_memory(), do

	end_pfn = PFN_UP(start + size);
	if (end_pfn > max_pfn)
		update_end_of_memory_vars(end_pfn);

and in arch_remove_memory(),

	end_pfn = PFN_UP(start);
	if (end_pfn < max_pfn)
		update_end_of_memory_vars(end_pfn);

and then update_end_of_memory_vars() becomes a three-liner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
