Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36A936B0003
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 15:05:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h33so7274917wrh.10
        for <linux-mm@kvack.org>; Sat, 17 Mar 2018 12:05:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j3si862866edh.300.2018.03.17.12.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 17 Mar 2018 12:05:22 -0700 (PDT)
Date: Sat, 17 Mar 2018 20:05:12 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/3] x86, pkeys: do not special case protection key 0
In-Reply-To: <6e0c687d-f465-5433-10be-db04489278a9@intel.com>
Message-ID: <alpine.DEB.2.21.1803172004130.1509@nanos.tec.linutronix.de>
References: <20180316214654.895E24EC@viggo.jf.intel.com> <20180316214656.0E059008@viggo.jf.intel.com> <alpine.DEB.2.21.1803171011100.1509@nanos.tec.linutronix.de> <6e0c687d-f465-5433-10be-db04489278a9@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Sat, 17 Mar 2018, Dave Hansen wrote:
> On 03/17/2018 02:12 AM, Thomas Gleixner wrote:
> >> This is a bit nicer than what Ram proposed because it is simpler
> >> and removes special-casing for pkey 0.  On the other hand, it does
> >> allow applciations to pkey_free() pkey-0, but that's just a silly
> >> thing to do, so we are not going to protect against it.
> > What's the consequence of that? Application crashing and burning itself or
> > something more subtle?
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

As long as its documented and the change only allows people to shoot them
more in the foot, we're all good.

Thanks,

	tglx
