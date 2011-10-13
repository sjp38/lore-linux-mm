Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AE4106B002F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 08:23:53 -0400 (EDT)
Message-ID: <4E96D852.9060507@parallels.com>
Date: Thu, 13 Oct 2011 16:23:46 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Slab objects identifiers
References: <4E8DD5B9.4060905@parallels.com>	<alpine.DEB.2.00.1110071159540.11042@router.home>	<4E92C6FA.2050609@parallels.com>	<CAOJsxLGctbXuXNuCWukH6LayZkuKH=aTx1L7uk87gVbVOJ_MKg@mail.gmail.com>	<4E96CAC3.3040402@parallels.com> <CAOJsxLFKPyzr48z8Z-c4za6tcZjjTgDXxSkr32aracfF7VrPEw@mail.gmail.com>
In-Reply-To: <CAOJsxLFKPyzr48z8Z-c4za6tcZjjTgDXxSkr32aracfF7VrPEw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@gentwo.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

>>> Does this ID thing need to happen in the slab layer?
>>
>> Not necessarily, of course, but if we're going to show some identifier of an object
>> we have 2 choices - either we generate this ID independently (with e.g. IDA), but
>> this is slow, or we use some knowledge of an object as a bunch of bytes in memory.
>> These slab IDs thing is an attempt to implement the 2nd approach.
> 
> Why is the first approach slow? I fully agree that unique IDs are probably the
> way to go here but why don't you just add a new member to struct mm_struct and
> initialize it in mm_alloc() and mm_dup()?

For several reasons:

1. I will need the same for fdtable, fs, files (the struct file can be shared by two
   different fdtables), namespaces, etc and try to make it more generic.
2. IDA allocation for mm will slowdown the fork() (for other objects - other operations).
3. My trick with increasing percpu will require 64-bit field on each object which is
   probably acceptable for mm_struct, but is critical for struct file and fs_struct, as
   they are already quite small.

>> The question I'm trying to answer with this is - do task A and task B have their mm
>> shared or not? Showing an ID answers one. Maybe there exists another way, but I haven't
>> invented it yet and decided to send this set out for discussion (the "release early"
>> idiom). If slab maintainers say "no, we don't accept this at all ever", then of course
>> I'll have to think further, but if the concept is suitable, but needs some refinement -
>> let's do it.
> 
> Oh, I much appreciate that you sent this early. I'm not completely against doing
> this in the slab layer but I need much more convincing. I expect most distros to
> enable checkpoint/restart so this ID mechanism is going to be default
> on for slab.
> 
>                             Pekka
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
