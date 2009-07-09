Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 207996B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:22:15 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so82343rvb.26
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 14:41:45 -0700 (PDT)
Message-ID: <4A566414.7060805@codemonkey.ws>
Date: Thu, 09 Jul 2009 16:41:40 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <c0e57d57-3f36-4405-b3f1-1a8c48089394@default>
In-Reply-To: <c0e57d57-3f36-4405-b3f1-1a8c48089394@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:
> CMM2's focus is on increasing the number of VM's that
> can run on top of the hypervisor.  To do this, it
> depends on hints provided by Linux to surreptitiously
> steal memory away from Linux.  The stolen memory still
> "belongs" to Linux and if Linux goes to use it but the
> hypervisor has already given it to another Linux, the
> hypervisor must jump through hoops to give it back.
>   

It depends on how you define "jump through hoops".

> If it guesses wrong and overcommits too aggressively,
> the hypervisor must swap some memory to a "hypervisor
> swap disk" (which btw has some policy challenges).
> IMHO this is more of a "mainframe" model.
>   

No, not at all.  A guest marks a page as being "volatile", which tells 
the hypervisor it never needs to swap that page.  It can discard it 
whenever it likes.

If the guest later tries to access that page, it will get a special 
"discard fault".  For a lot of types of memory, the discard fault 
handler can then restore that page transparently to the code that 
generated the discard fault.

AFAICT, ephemeral tmem has the exact same characteristics as volatile 
CMM2 pages.  The difference is that tmem introduces an API to explicitly 
manage this memory behind a copy interface whereas CMM2 uses hinting and 
a special fault handler to allow any piece of memory to be marked in 
this way.

> In other words, CMM2, despite its name, is more of a
> "subservient" memory management system (Linux is
> subservient to the hypervisor) and tmem is more
> collaborative (Linux and the hypervisor share the
> responsibilities and the benefits/costs).
>   

I don't really agree with your analysis of CMM2.  We can map CMM2 
operations directly to ephemeral tmem interfaces so tmem is a subset of 
CMM2, no?

What's appealing to me about CMM2 is that it doesn't change the guest 
semantically but rather just gives the VMM more information about how 
the VMM is using it's memory.  This suggests that it allows greater 
flexibility in the long term to the VMM and more importantly, provides 
an easier implementation across a wide range of guests.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
