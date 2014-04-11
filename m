Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 735A56B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 12:24:24 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so5578169pbc.24
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 09:24:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ep2si4549627pbb.131.2014.04.11.09.24.23
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 09:24:23 -0700 (PDT)
Message-ID: <53481724.8020304@intel.com>
Date: Fri, 11 Apr 2014 09:24:04 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] drivers/base/node.c: export physical address range of
 given node (Re: NUMA node information for pages)
References: <87eh1ix7g0.fsf@x240.local.i-did-not-set--mail-host-address--so-tickle-me> <533a1563.ad318c0a.6a93.182bSMTPIN_ADDED_BROKEN@mx.google.com> <CAOPLpQc8R2SfTB+=BsMa09tcQ-iBNJHg+tGnPK-9EDH1M47MJw@mail.gmail.com> <5343806c.100cc30a.0461.ffffc401SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404091734060.1857@chino.kir.corp.google.com> <5345fe27.82dab40a.0831.0af9SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com> <53474709.e59ec20a.3bd5.3b91SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: drepper@gmail.com, anatol.pomozov@gmail.com, jkosina@suse.cz, akpm@linux-foundation.org, xemul@parallels.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/11/2014 04:00 AM, David Rientjes wrote:
> On Thu, 10 Apr 2014, Naoya Horiguchi wrote:
>> > Yes, that's right, but it seems to me that just node_start_pfn and node_end_pfn
>> > is not enough because there can be holes (without any page struct backed) inside
>> > [node_start_pfn, node_end_pfn), and it's not aware of memory hotplug.
>> > 
> So?  Who cares if there are non-addressable holes in part of the span?  
> Ulrich, correct me if I'm wrong, but it seems you're looking for just a 
> address-to-nodeid mapping (or pfn-to-nodeid mapping) and aren't actually 
> expecting that there are no holes in a node for things like acpi or I/O or 
> reserved memory.
...
> I think trying to represent holes and handling different memory models and 
> hotplug in special ways is complete overkill.

This isn't just about memory hotplug or different memory models.  There
are systems out there today, in production, that have layouts like this:

|------Node0-----|
     |------Node1-----|

and this:

|------Node0-----|
     |-Node1-|

For those systems, this interface has no meaning.  Given a page in the
shared-span areas, this interface provides no way to figure out which
node it is in.

If you want a non-portable hack that just works on one system, I'd
suggest parsing the existing firmware tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
