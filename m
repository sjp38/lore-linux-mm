Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAE9D6B0007
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 12:01:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t24so6883435pfe.20
        for <linux-mm@kvack.org>; Sat, 17 Mar 2018 09:01:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y4-v6si8390169pll.413.2018.03.17.09.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Mar 2018 09:01:21 -0700 (PDT)
Subject: Re: [PATCH 1/3] x86, pkeys: do not special case protection key 0
References: <20180316214654.895E24EC@viggo.jf.intel.com>
 <20180316214656.0E059008@viggo.jf.intel.com>
 <alpine.DEB.2.21.1803171011100.1509@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6e0c687d-f465-5433-10be-db04489278a9@intel.com>
Date: Sat, 17 Mar 2018 09:01:20 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1803171011100.1509@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 03/17/2018 02:12 AM, Thomas Gleixner wrote:
>> This is a bit nicer than what Ram proposed because it is simpler
>> and removes special-casing for pkey 0.  On the other hand, it does
>> allow applciations to pkey_free() pkey-0, but that's just a silly
>> thing to do, so we are not going to protect against it.
> What's the consequence of that? Application crashing and burning itself or
> something more subtle?

You would have to:

	pkey_free(0)
	... later
	new_key = pkey_alloc();
	// now new_key=0
	pkey_deny_access(new_key); // or whatever

At which point most apps would probably croak because its stack is
inaccessible.  The free itself does not make the key inaccessible, *but*
we could also do that within the existing ABI if we want.  I think I
called out that behavior as undefined in the manpage.
