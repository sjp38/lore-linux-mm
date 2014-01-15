Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 654CB6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:25:14 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id b6so339502yha.22
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:25:14 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id v1si2788212yhg.124.2014.01.14.16.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 16:25:13 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so54185yha.12
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:25:13 -0800 (PST)
Date: Tue, 14 Jan 2014 16:25:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
In-Reply-To: <20140114155241.7891fce1fb2b9dfdcde15a8c@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401141621560.3375@chino.kir.corp.google.com>
References: <52C5AA61.8060701@intel.com> <20140103033303.GB4106@localhost.localdomain> <52C6FED2.7070700@intel.com> <20140105003501.GC4106@localhost.localdomain> <20140106164604.GC27602@dhcp22.suse.cz> <20140108101611.GD27937@dhcp22.suse.cz>
 <20140110081744.GC9437@dhcp22.suse.cz> <20140114200720.GM4106@localhost.localdomain> <20140114155241.7891fce1fb2b9dfdcde15a8c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Tue, 14 Jan 2014, Andrew Morton wrote:

> This is all a bit nasty, isn't it?  THP goes and alters min_free_kbytes
> to improve its own reliability, but min_free_kbytes is also
> user-modifiable.  And over many years we have trained a *lot* of users
> to alter min_free_kbytes.  Often to prevent nasty page allocation
> failure warnings from net drivers.
> 

I can vouch for kernel logs that are spammed with tons of net page 
allocation failure warnings, in fact we're going through and adding 
__GFP_NOWARN to most of these.

> So there are probably quite a lot of people out there who are manually
> rubbing out THP's efforts.  And there may also be people who are
> setting min_free_kbytes to a value which is unnecessarily high for more
> recent kernels.
> 

Indeed, we have initscripts that modified min_free_kbytes before thp was 
introduced but luckily they were comparing their newly computed value to 
the existing value and only writing if the new value is greater.  
Hopefully most users are doing the same thing.

Would it be overkill to save the kernel default both with and without thp 
and then doing a WARN_ON_ONCE() if a user-written value is ever less?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
