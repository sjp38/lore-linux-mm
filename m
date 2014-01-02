Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 77DF56B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 18:48:43 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so14961166pbb.17
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 15:48:43 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ye6si43870516pbc.80.2014.01.02.15.48.41
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 15:48:42 -0800 (PST)
Message-ID: <52C5FAD3.6080808@intel.com>
Date: Thu, 02 Jan 2014 15:48:35 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
References: <20140101002935.GA15683@localhost.localdomain> <52C5AA61.8060701@intel.com> <alpine.DEB.2.02.1401021357360.21537@chino.kir.corp.google.com> <52C5E3C2.6020205@intel.com> <alpine.DEB.2.02.1401021534320.492@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401021534320.492@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 01/02/2014 03:36 PM, David Rientjes wrote:
> On Thu, 2 Jan 2014, Dave Hansen wrote:
>> Let's say enabling THP made my system behave badly.  How do I get it
>> back to the state before I enabled THP?  The user has to have gone and
>> recorded what their min_free_kbytes was before turning THP on in order
>> to get it back to where it was.  Folks also have to either plan in
>> advance (archiving *ALL* the sysctl settings), somehow *know* somehow
>> that THP can affect min_free_kbytes, or just plain be clairvoyant.
>> 
> How is this different from some initscript changing the value?  We should 
> either specify that min_free_kbytes changed from its default, which may 
> change from kernel version to kernel version itself, in all cases or just 
> leave it as it currently is.  There's no reason to special-case thp in 
> this way if there are other ways to change the value.

Ummm....  It's different because one is the kernel changing it and the
other is userspace.  If I wonder how the heck this got set:

	kernel.core_pattern = |/usr/share/apport/apport %p %s %c

I do:

$ grep -r /usr/share/apport/apport /etc/
/etc/init/apport.conf:        /usr/share/apport/apportcheckresume || true
/etc/init/apport.conf:    echo "|/usr/share/apport/apport %p %s %c" >
/proc/sys/kernel/core_pattern

There's usually a record of how it got set, somewhere, if it happened
from userspace.  Printing messages like this in the kernel does the
same: it gives the sysadmin a _chance_ of finding out what happened.
Doing it silently (like it's done today) isn't very nice.

You're arguing that "if userspace can set it arbitrarily, then the
kernel should be able to do it silently too."  That's nonsense.

It would be nice to have tracepoints explicitly for tracing who messed
with sysctl values, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
