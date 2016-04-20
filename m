Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA736B029F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 17:35:55 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so39971788pab.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 14:35:55 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id vh16si18574311pab.164.2016.04.20.14.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 14:35:54 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id r5so19518817pag.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 14:35:54 -0700 (PDT)
Date: Wed, 20 Apr 2016 14:35:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line
 options to set the default onlining policy
In-Reply-To: <87zisq2h0o.fsf@vitty.brq.redhat.com>
Message-ID: <alpine.DEB.2.10.1604201430280.4829@chino.kir.corp.google.com>
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com> <20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org> <alpine.DEB.2.10.1604061512460.10401@chino.kir.corp.google.com> <87y48phkk2.fsf@vitty.brq.redhat.com>
 <alpine.DEB.2.10.1604181437220.10562@chino.kir.corp.google.com> <87zisq2h0o.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

On Tue, 19 Apr 2016, Vitaly Kuznetsov wrote:

> > I'd personally disagree that we need more and more config options to take 
> > care of something that an initscript can easily do and most distros 
> > already have their own initscripts that this can be added to.  I don't see 
> > anything that the config option adds.
> 
> Yes, but why does every distro need to solve the exact same issue by 
> a distro-specific init script when we can allow setting reasonable
> default in kernel?
> 

No, only distros that want to change the long-standing default which is 
"offline" since they apparently aren't worried about breaking existing 
userspace.

Changing defaults is always risky business in the kernel, especially when 
it's long standing.  If the default behavior is changeable, userspace 
needs to start testing for that and acting accordingly if it actually 
wants to default to offline (and there are existing tools that suppose the 
long-standing default).  The end result is that the kernel default doesn't 
matter anymore, we've just pushed it to userspace to either online or 
offline at the time of hotplug.

> If the config option itself is a problem (though I don't understand why)
> we can get rid of it making the default 'online' and keeping the command
> line parameter to disable it for cases when something goes wrong but why
> not leave an option for those who want it the other way around?
> 

That could break existing userspace that assumes the default is offline; 
if users are currently hotadding memory and then onlining it when needed 
rather than immediately, they break.  So that's not a possibility.

> Other than the above, let's imagine a 'unikernel' scenario when there
> are no initscripts and we're in a virtualized environment. We may want to
> have memory hotplug there too, but where would we put the 'onlining'
> logic? In every userspace we want to run? This doesn't sound right.
> 

Nobody is resisting hotplug notifiers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
