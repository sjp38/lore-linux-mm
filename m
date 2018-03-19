Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 139536B0003
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 01:51:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o61-v6so9837700pld.5
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 22:51:04 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 97-v6si11432777pld.142.2018.03.18.22.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 18 Mar 2018 22:51:02 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/3] x86, pkeys: do not special case protection key 0
In-Reply-To: <6e0c687d-f465-5433-10be-db04489278a9@intel.com>
References: <20180316214654.895E24EC@viggo.jf.intel.com> <20180316214656.0E059008@viggo.jf.intel.com> <alpine.DEB.2.21.1803171011100.1509@nanos.tec.linutronix.de> <6e0c687d-f465-5433-10be-db04489278a9@intel.com>
Date: Mon, 19 Mar 2018 16:50:56 +1100
Message-ID: <877eq8hav3.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

Dave Hansen <dave.hansen@intel.com> writes:

> On 03/17/2018 02:12 AM, Thomas Gleixner wrote:
>>> This is a bit nicer than what Ram proposed because it is simpler
>>> and removes special-casing for pkey 0.  On the other hand, it does
>>> allow applciations to pkey_free() pkey-0, but that's just a silly
>>> thing to do, so we are not going to protect against it.
>> What's the consequence of that? Application crashing and burning itself or
>> something more subtle?
>
> You would have to:
>
> 	pkey_free(0)
> 	... later
> 	new_key = pkey_alloc();
> 	// now new_key=0
> 	pkey_deny_access(new_key); // or whatever
>
> At which point most apps would probably croak because its stack is
> inaccessible.  The free itself does not make the key inaccessible, *but*
> we could also do that within the existing ABI if we want.  I think I
> called out that behavior as undefined in the manpage.

Allowing key 0 to be freed introduces some pretty weird API IMHO. For
example this part of the manpage:

  An application should not call pkey_free() on any protection key
  which has been assigned to an address range by pkey_mprotect(2)
  and which is still in use. The behavior in this case is undefined
  and may result in an error.

You basically can't avoid hitting undefined behaviour with pkey 0,
because even if you never assigned pkey 0 to an address range, it *is
still in use* - because it's used as the default key for every address
range that doesn't have another key.

So I don't really think it makes sense to allow pkey 0 to be freed. But
I won't die in a ditch over it, I just look forward to a manpage update
that can sensibly describe the semantics.

cheers
