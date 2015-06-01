Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE536B0073
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 18:27:49 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so117749601pdb.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 15:27:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bz4si23344339pab.196.2015.06.01.15.27.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 15:27:48 -0700 (PDT)
Date: Mon, 1 Jun 2015 15:27:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/3] Allow user to request memory to be locked on
 page fault
Message-Id: <20150601152746.abbbbb9d479c0e2dbdec2aaf@linux-foundation.org>
In-Reply-To: <1432908808-31150-1-git-send-email-emunson@akamai.com>
References: <1432908808-31150-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Fri, 29 May 2015 10:13:25 -0400 Eric B Munson <emunson@akamai.com> wrote:

> mlock() allows a user to control page out of program memory, but this
> comes at the cost of faulting in the entire mapping when it is
> allocated.  For large mappings where the entire area is not necessary
> this is not ideal.
> 
> This series introduces new flags for mmap() and mlockall() that allow a
> user to specify that the covered are should not be paged out, but only
> after the memory has been used the first time.

I almost applied these, but the naming issue (below) stopped me.

A few things...

- The 0/n changelog should reveal how MAP_LOCKONFAULT interacts with
  rlimit(RLIMIT_MEMLOCK).

  I see the implementation is "as if the entire mapping will be
  faulted in" (for mmap) and "as if it was MCL_FUTURE" (for mlockall)
  which seems fine.  Please include changelog text explaining and
  justifying these decisions.  This stuff will need to be in the
  manpage updates as well.

- I think I already asked "why not just use MCL_FUTURE" but I forget
  the answer ;) In general it is a good idea to update changelogs in
  response to reviewer questions, because other people will be
  wondering the same things.  Or maybe I forgot to ask.  Either way,
  please address this in the changelogs.

- I can perhaps see the point in mmap(MAP_LOCKONFAULT) (other
  mappings don't get lock-in-memory treatment), but what's the benefit
  in mlockall(MCL_ON_FAULT) over MCL_FUTURE?  (Add to changelog also,
  please).

- Is there a manpage update?

- Can we rename patch 1/3 from "add flag to ..." to "add mmap flag to
  ...", to distinguish from 2/3 "add mlockall flag ..."?

- The MAP_LOCKONFAULT versus MCL_ON_FAULT inconsistency is
  irritating!  Can we get these consistent please: switch to either
  MAP_LOCK_ON_FAULT or MCL_ONFAULT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
