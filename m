Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACF582F6B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 03:25:43 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t184so144243607qkh.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:25:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s201si772783qke.3.2016.04.21.00.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 00:25:42 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line options to set the default onlining policy
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
	<20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
	<alpine.DEB.2.10.1604061512460.10401@chino.kir.corp.google.com>
	<87y48phkk2.fsf@vitty.brq.redhat.com>
	<alpine.DEB.2.10.1604181437220.10562@chino.kir.corp.google.com>
	<87zisq2h0o.fsf@vitty.brq.redhat.com>
	<alpine.DEB.2.10.1604201430280.4829@chino.kir.corp.google.com>
Date: Thu, 21 Apr 2016 09:25:36 +0200
In-Reply-To: <alpine.DEB.2.10.1604201430280.4829@chino.kir.corp.google.com>
	(David Rientjes's message of "Wed, 20 Apr 2016 14:35:52 -0700 (PDT)")
Message-ID: <87oa931kzz.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

David Rientjes <rientjes@google.com> writes:

> On Tue, 19 Apr 2016, Vitaly Kuznetsov wrote:
>
>> > I'd personally disagree that we need more and more config options to take 
>> > care of something that an initscript can easily do and most distros 
>> > already have their own initscripts that this can be added to.  I don't see 
>> > anything that the config option adds.
>> 
>> Yes, but why does every distro need to solve the exact same issue by 
>> a distro-specific init script when we can allow setting reasonable
>> default in kernel?
>> 
>
> No, only distros that want to change the long-standing default which is 
> "offline" since they apparently aren't worried about breaking existing 
> userspace.
>
> Changing defaults is always risky business in the kernel, especially when 
> it's long standing.  If the default behavior is changeable, userspace 
> needs to start testing for that and acting accordingly if it actually 
> wants to default to offline (and there are existing tools that suppose the 
> long-standing default).  The end result is that the kernel default doesn't 
> matter anymore, we've just pushed it to userspace to either online or 
> offline at the time of hotplug.
>

"We don't break userspace". Yes, I know, but is there an example of such
userspace which is going to break?

E.g. RHEL7 ships the following udev rule by default:
# Memory hotadd request
SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

which is not very smart but it does the job (with issues I'm trying to
solve). I'm not aware of any breakages reported after it was introduced.

My understanding is that the legacy default 'offline' was introduced
before memory hotplug became a frequently used feature in virtual
machines. When you hotplug physical memory you go to your server room,
open your server, insert memory dimm, ... - in this scenario 'offline'
is a reasonable default. But in VMs mempory hotplug is usually an
automatic from host side -- we address high memory pressure/tenant
requests.

>> If the config option itself is a problem (though I don't understand why)
>> we can get rid of it making the default 'online' and keeping the command
>> line parameter to disable it for cases when something goes wrong but why
>> not leave an option for those who want it the other way around?
>> 
>
> That could break existing userspace that assumes the default is offline; 
> if users are currently hotadding memory and then onlining it when needed 
> rather than immediately, they break.  So that's not a possibility.
>

Yes, so I introduce a config option. Next thing we do we enable it in
'bleeding edge' distros, e.g. Fedora and see who complains. My guess is
that nobody is going to complain.

>> Other than the above, let's imagine a 'unikernel' scenario when there
>> are no initscripts and we're in a virtualized environment. We may want to
>> have memory hotplug there too, but where would we put the 'onlining'
>> logic? In every userspace we want to run? This doesn't sound right.
>> 
>
> Nobody is resisting hotplug notifiers.

Yes, but we need to teach memory hotplug to every userspace instead.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
