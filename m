Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C223E6B0006
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 15:32:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i81-v6so33332261pfj.1
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:32:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91-v6sor13347661plh.52.2018.10.19.12.32.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 12:32:20 -0700 (PDT)
Date: Fri, 19 Oct 2018 12:32:17 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Message-ID: <20181019193217.GA181176@joelaf.mtv.corp.google.com>
References: <20181018065908.254389-1-joel@joelfernandes.org>
 <42922.1539970322@turing-police.cc.vt.edu>
 <CAEXW_YTS2n2tOpXs3eVQZhYu7tmM_at0ZBA-04qYkHw4UE80nw@mail.gmail.com>
 <118792.1539974951@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <118792.1539974951@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: valdis.kletnieks@vt.edu
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org, linux-kselftest <linux-kselftest@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Oct 19, 2018 at 02:49:11PM -0400, valdis.kletnieks@vt.edu wrote:
> On Fri, 19 Oct 2018 10:57:31 -0700, Joel Fernandes said:
> > On Fri, Oct 19, 2018 at 10:32 AM,  <valdis.kletnieks@vt.edu> wrote:
> > > What is supposed to happen if some other process has an already existing R/W
> > > mmap of the region?  (For that matter, the test program doesn't seem to
> > > actually test that the existing mmap region remains writable?)
> 
> > Why would it not remain writable? We don't change anything in the
> > mapping that prevents it from being writable, in the patch.
> 
> OK, if the meaning here is "if another process races and gets its own R/W mmap
> before we seal our mmap, it's OK".  Seems like somewhat shaky security-wise - a
> possibly malicious process can fail to get a R/W map because we just sealed it,
> but if it had done the attempt a few milliseconds earlier it would have its own
> R/W mmap to do as it pleases...
> 
> On the other hand, decades of trying have proven that trying to do any sort
> of revoke() is a lot harder to do than it looks...
> 

No it is not a security issue. The issue you bring up can happen even with
the existing F_SEAL_WRITE where someone else races to mmap it.

And if someone else could race and do an mmap on the memfd, then they somehow
goes the fd at which point that is a security issue anyway. That is the whole
point of memfd, that it can be securely sent over IPC to another process.
Also, before sending it to the receiving/racing process, the memfd would have
already been sealed with the F_SEAL_FUTURE_WRITE so there is no question of a
race on the receiving side.

- Joel
