Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 289456B00C6
	for <linux-mm@kvack.org>; Mon, 18 May 2015 11:20:49 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so71174292qkg.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 08:20:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d7si8514425qka.121.2015.05.18.08.20.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 08:20:48 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CALq1K=KTGd5Xdj88PmQM3H3aSpakLbUdG=usi+7g9zmN+Ms4Xw@mail.gmail.com>
References: <CALq1K=KTGd5Xdj88PmQM3H3aSpakLbUdG=usi+7g9zmN+Ms4Xw@mail.gmail.com> <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com> <7254.1431945085@warthog.procyon.org.uk> <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com> <23799.1431955741@warthog.procyon.org.uk>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <28900.1431962436.1@warthog.procyon.org.uk>
Date: Mon, 18 May 2015 16:20:36 +0100
Message-ID: <28901.1431962436@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: dhowells@redhat.com, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

Leon Romanovsky <leon@leon.nu> wrote:

> >> Additionally, It looks like the output of these macros can be viewed by
> >> ftrace mechanism.
> >
> > *blink* It can?
> I was under strong impression that "function" and "function_graph"
> tracers will give similar kenter/kleave information. Do I miss
> anything important, except the difference in output format?
> 
> >
> >> Maybe we should delete them from mm/nommu.c as was pointed by Joe?
> >
> > Why?
> If ftrace is sufficient to get the debug information, there will no
> need to duplicate it.

It isn't sufficient.  It doesn't store the parameters or the return value, it
doesn't distinguish the return path in a function when there's more than one,
eg.:

		kleave(" = %d [val]", ret);

vs:

	kleave(" = %lx", result);

in do_mmap_pgoff() and it doesn't permit you to retrieve data from where the
argument pointers that you don't have pointed to, eg.:

	kenter("%p{%d}", region, region->vm_usage);

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
