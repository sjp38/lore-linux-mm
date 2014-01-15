Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CCF8B6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:35:36 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so359344pde.28
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:35:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ll1si1970698pab.173.2014.01.14.16.35.34
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 16:35:35 -0800 (PST)
Date: Tue, 14 Jan 2014 16:35:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-Id: <20140114163533.ab191e118e82ca7b4d499551@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401141621560.3375@chino.kir.corp.google.com>
References: <52C5AA61.8060701@intel.com>
	<20140103033303.GB4106@localhost.localdomain>
	<52C6FED2.7070700@intel.com>
	<20140105003501.GC4106@localhost.localdomain>
	<20140106164604.GC27602@dhcp22.suse.cz>
	<20140108101611.GD27937@dhcp22.suse.cz>
	<20140110081744.GC9437@dhcp22.suse.cz>
	<20140114200720.GM4106@localhost.localdomain>
	<20140114155241.7891fce1fb2b9dfdcde15a8c@linux-foundation.org>
	<alpine.DEB.2.02.1401141621560.3375@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Tue, 14 Jan 2014 16:25:10 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Tue, 14 Jan 2014, Andrew Morton wrote:
> 
> > This is all a bit nasty, isn't it?  THP goes and alters min_free_kbytes
> > to improve its own reliability, but min_free_kbytes is also
> > user-modifiable.  And over many years we have trained a *lot* of users
> > to alter min_free_kbytes.  Often to prevent nasty page allocation
> > failure warnings from net drivers.
> > 
> 
> I can vouch for kernel logs that are spammed with tons of net page 
> allocation failure warnings, in fact we're going through and adding 
> __GFP_NOWARN to most of these.
> 
> > So there are probably quite a lot of people out there who are manually
> > rubbing out THP's efforts.  And there may also be people who are
> > setting min_free_kbytes to a value which is unnecessarily high for more
> > recent kernels.
> > 
> 
> Indeed, we have initscripts that modified min_free_kbytes before thp was 
> introduced but luckily they were comparing their newly computed value to 
> the existing value and only writing if the new value is greater.  
> Hopefully most users are doing the same thing.

I've been waiting 10+ years for us to decide to delete that warning due
to the false positives.  Hasn't happened yet, and the warning does
find bugs/issues/misconfigurations/etc.

But I do worry this has led to users unnecessarily increasing
min_free_kbytes just to shut the warnings up.  Net result: they have
less memory available for cache, etc.

> Would it be overkill to save the kernel default both with and without thp 
> and then doing a WARN_ON_ONCE() if a user-written value is ever less?

Well, min_free_kbytes is a userspace thing, not a kernel thing - maybe
THP shouldn't be dinking with it.  What effect is THP trying to achieve
and can we achieve it by other/better means?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
