Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63A706B0006
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 06:15:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f65-v6so741786wmd.2
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 03:15:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j53-v6si1637692eda.76.2018.06.08.03.15.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jun 2018 03:15:54 -0700 (PDT)
Date: Fri, 8 Jun 2018 12:15:51 +0200
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Message-ID: <20180608121551.3c151e0c@naga.suse.cz>
In-Reply-To: <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
 <20180608023441.GA5573@ram.oc3035372033.ibm.com>
 <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Ram Pai <linuxram@us.ibm.com>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, 8 Jun 2018 07:53:51 +0200
Florian Weimer <fweimer@redhat.com> wrote:

> On 06/08/2018 04:34 AM, Ram Pai wrote:
> >>
> >> So the remaining question at this point is whether the Intel
> >> behavior (default-deny instead of default-allow) is preferable.  
> > 
> > Florian, remind me what behavior needs to fixed?  
> 
> See the other thread.  The Intel register equivalent to the AMR by 
> default disallows access to yet-unallocated keys, so that threads
> which are created before key allocation do not magically gain access
> to a key allocated by another thread.
> 

That does not make any sense. The threads share the address space so
they should also share the keys.

Or in other words the keys are supposed to be acceleration of
mprotect() so if mprotect() magically gives access to threads that did
not call it so should pkey functions. If they cannot do that then they
fail the primary purpose.

And in any case what semantic that makes sense will you ever get by
threads not magically getting new keys?

Suppose you will spawn some threads, then allocate a new key, associate
it with a piece of protected data, etc.

Now the old threads do not have access to the protected data at all. So
if they want to access it they have to call into a management thread
that created the access key to give them the data. Which means they
need to call into the kernel to switch to the management thread. Which
completely defeats the purpose of the acceleration of mprotect() which
was to avoid calling into the kernel to access the data. In other words
you can as well spawn a management process and use shared memory.

What's worse, if you wanted to opt out of this feature and give the old
threads the new key that's going to be quite a bit of fiddling.

That said there might be an enhancement that kind of makes sense. For
example if you allocate a key to associate with an area that you want
to read most of the time and update occasionally it might make sense to
tell the kernel: make the read bit on this key process-global, make the
write bit on this key thread-local, and do not allow setting the
execute bit at all. Then a thread calling a function to update the data
will get write access but other threads will continue to have read
access unless they also call a function to update the data.

Thanks

Michal
