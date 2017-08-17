Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E57D6B02B4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:44:32 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id n140so127456584ywd.13
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:44:32 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id j125si1154944ywd.225.2017.08.17.14.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:44:31 -0700 (PDT)
Date: Thu, 17 Aug 2017 17:44:29 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCHv3 2/2] extract early boot entropy from the passed cmdline
Message-ID: <20170817214429.wt7zly2e3bmnlfyp@thunk.org>
References: <20170816231458.2299-1-labbott@redhat.com>
 <20170816231458.2299-3-labbott@redhat.com>
 <20170817033148.ownsmbdzk2vhupme@thunk.org>
 <1502943802.3986.38.camel@gmail.com>
 <1503003427.1514.6.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503003427.1514.6.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 17, 2017 at 04:57:07PM -0400, Daniel Micay wrote:
> > I did say 'external attacker' but it could be made clearer.
> 
> Er, s/say/mean to imply/

Right, that's why I had suggested modifying the first few lines of the
commit description to read something like this:

  Feed the boot command-line as to the /dev/random entropy pool

  Existing Android bootloaders usually pass data which may not be known
  by an external attacker on the kernel command-line.  It may also be
  the case on other embedded systems.  Sample command-line from a Google
  Pixel running CopperheadOS:

(Or something like that.)

> I'll look into having the kernel stash some entropy in pstore soon since
> that seems like it could be a great improvement. I'm not sure how often
> / where it should hook into for regularly refreshing it though. Doing it
> only on powering down isn't ideal.

One thing we could do is to agree on a standard place where the
entropy would be stashed, and then have the kernel remove it from
being visible in /proc/cmdline.  That's not a perfect answer, since
the user might be able to look at the command line via other
mechanisms.  (For example, on x86, by looking at GRUB while the system
is booting.)

However, an attacker who is merely running code on the local system is
not likely to be gain access to that value --- so it's definitely an
improvement.

Refreshing the entry immediately after boot, and before a clean
shutdown would be ideal from a security perspective.  I don't know if
there are write endurance issues with updating the pstore that
frequently, though.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
