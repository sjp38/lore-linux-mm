Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 71AB86B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 17:16:26 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j5so4506646qaq.28
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:16:25 -0700 (PDT)
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
        by mx.google.com with ESMTPS id 50si2447225qgh.127.2014.04.10.14.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 14:16:24 -0700 (PDT)
Received: by mail-qa0-f41.google.com with SMTP id j5so4499929qaq.14
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:16:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4RofJ7CUWWBPW1Qb4pX3rxYHCh1CPtbtX241KtJO+=Qhw@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net>
 <20140410203246.GB31614@thunk.org> <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
 <CANq1E4RofJ7CUWWBPW1Qb4pX3rxYHCh1CPtbtX241KtJO+=Qhw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Apr 2014 14:16:03 -0700
Message-ID: <CALCETrXVzLcVVSuPMFUgoRvpQgcQNy2_rW6=11CJAME0W2GyYQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, Apr 10, 2014 at 1:49 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Thu, Apr 10, 2014 at 10:37 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> It occurs to me that, before going nuts with these kinds of flags, it
>> may pay to just try to fix the /proc/self/fd issue for real -- we
>> could just make open("/proc/self/fd/3", O_RDWR) fail if fd 3 is
>> read-only.  That may be enough for the file sealing thing.
>
> For the sealing API, none of this is needed. As long as the inode is
> owned by the uid who creates the memfd, you can pass it around and
> no-one besides root and you can open /proc/self/fd/$fd (assuming chmod
> 700). If you share the fd with someone with the same uid as you,
> you're screwed anyway. We don't protect users against themselves (I
> mean, they can ptrace you, or kill()..). Therefore, I'm not really
> convinced that we want this for memfd. At least no-one has provided a
> _proper_ use-case for this so far.

Hmm.  Fair enough.

Would it make sense for the initial mode on a memfd inode to be 000?
Anyone who finds this to be problematic could use fchmod to fix it.

I might even go so far as to suggest that the default uid on the inode
should be 0 (i.e. global root), since there is the odd corner case of
root setting euid != 0, creating a memfd, and setting euid back to 0.
The latter might cause resource accounting issues, though.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
