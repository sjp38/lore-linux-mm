Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id CD1216B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:32:57 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id m20so5115899qcx.7
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:32:57 -0700 (PDT)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
        by mx.google.com with ESMTPS id c3si2540765qan.224.2014.04.10.16.32.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 16:32:57 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id a108so4735014qge.31
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:32:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4SsCFTpiKBPbOUD0M+Nfs2hsnLW44RfsgbQvbFCfeZuvA@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net>
 <20140410203246.GB31614@thunk.org> <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
 <CANq1E4RofJ7CUWWBPW1Qb4pX3rxYHCh1CPtbtX241KtJO+=Qhw@mail.gmail.com>
 <CALCETrXVzLcVVSuPMFUgoRvpQgcQNy2_rW6=11CJAME0W2GyYQ@mail.gmail.com>
 <CANq1E4Qa8N0G8whyW5OWQS4x9=CVOF0PpcLhDi4j3wGTHX0==w@mail.gmail.com>
 <CALCETrXFJfoD9xrYpu6UjsHF74kYm3_o-xLNKjqh-OF2x-nyFQ@mail.gmail.com> <CANq1E4SsCFTpiKBPbOUD0M+Nfs2hsnLW44RfsgbQvbFCfeZuvA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Apr 2014 16:32:36 -0700
Message-ID: <CALCETrUyWKtnX_fxn0WYn=Q_mVcxy3KQrRMkuJRGPjnhzMor9w@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-kernel <linux-kernel@vger.kernel.org>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, Apr 10, 2014 at 4:16 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Fri, Apr 11, 2014 at 1:05 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> /proc/pid/fd is a really weird corner case in which the mode of an
>> inode that doesn't have a name matters.  I suspect that almost no one
>> will ever want to open one of these things out of /proc/self/fd, and
>> those who do should be made to think about it.
>
> I'm arguing in the context of memfd, and there's no security leak if
> people get access to the underlying inode (at least I'm not aware of
> any).

I'm not sure what you mean.

> As I said, context information is attached to the inode, not
> file context, so I'm fine if people want to open multiple file
> contexts via /proc. If someone wants to forbid open(), I want to hear
> _why_. I assume the memfd object has uid==uid-of-creator and
> mode==(777 & ~umask) (which usually results in X00, so no access for
> non-owners). I cannot see how /proc is a security issue here.

On further reflection, my argument for 000 is crap.  As far as I can
see, the only time that the mode matters at all when playing with
/proc/pid/fd, and they only way to get a non-O_RDWR memfd is using
/proc/pid/fd, so I'll argue for 0600 instead.

Argument why 0600 is better than 0600 & ~umask: either callers don't
care because the inode mode simply doesn't matter or they're using
/proc/pid/fd to *reduce* permissions, in which case they'd probably
like to avoid having to play with umask or call fchmod.

Argument why 0600 is better than 0777 & ~umask: People /prod/pid/fd
are the only ones who care, in which case they probably prefer for the
permissions not be increased by other users if they give them a
reduced-permission fd.

Anyway, this is all mostly unimportant.  Some text in the man page is
probably sufficient, but I still think that 0600 is trivial to
implement and a little bit more friendly.

--Andy

>
> Thanks
> David



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
